import Foundation
import AVFoundation
import React

// MARK: - Error Codes

enum VideoProcessorError: Error {
    case fileNotFound
    case unsupportedFormat
    case exportFailed
    case insufficientSpace
    case invalidParameters
    case cancelled
    
    var code: String {
        switch self {
        case .fileNotFound: return "FILE_NOT_FOUND"
        case .unsupportedFormat: return "UNSUPPORTED_FORMAT"
        case .exportFailed: return "EXPORT_FAILED"
        case .insufficientSpace: return "INSUFFICIENT_SPACE"
        case .invalidParameters: return "INVALID_PARAMETERS"
        case .cancelled: return "CANCELLED"
        }
    }
    
    var message: String {
        switch self {
        case .fileNotFound: return "Input file does not exist"
        case .unsupportedFormat: return "Unsupported video format"
        case .exportFailed: return "Video export failed"
        case .insufficientSpace: return "Insufficient disk space"
        case .invalidParameters: return "Invalid parameters provided"
        case .cancelled: return "Processing was cancelled"
        }
    }
}

// MARK: - Speed Segment Model

struct SpeedSegment {
    let start: Double
    let end: Double?
    let speed: Double
    let pitchCorrection: String
    
    init?(from dict: [String: Any]) {
        guard let start = dict["start"] as? Double,
              let speed = dict["speed"] as? Double else {
            return nil
        }
        
        self.start = start
        self.end = dict["end"] as? Double
        self.speed = speed
        self.pitchCorrection = dict["pitchCorrection"] as? String ?? "highQuality"
    }
    
    var pitchAlgorithm: AVAudioTimePitchAlgorithm {
        switch pitchCorrection {
        case "voice":
            return .spectral
        case "highQuality":
            return .spectral
        case "none":
            return .varispeed
        default:
            return .spectral
        }
    }
}

// MARK: - Main VideoProcessor Class

@objc(VideoProcessor)
class VideoProcessor: RCTEventEmitter {
    
    private var currentExportSession: AVAssetExportSession?
    private var progressTimer: Timer?
    
    // MARK: - RCTEventEmitter Overrides
    
    override func supportedEvents() -> [String]! {
        return ["VideoProcessorProgress"]
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    // MARK: - Process Video with Speed Adjustment
    
    @objc
    func processVideo(
        _ input: String,
        output: String,
        segments: [[String: Any]],
        outputFormat: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        Task {
            do {
                let result = try await processVideoAsync(
                    input: input,
                    output: output,
                    segments: segments,
                    outputFormat: outputFormat
                )
                resolve(result)
            } catch let error as VideoProcessorError {
                reject(error.code, error.message, error)
            } catch {
                reject("EXPORT_FAILED", error.localizedDescription, error)
            }
        }
    }
    
    private func processVideoAsync(
        input: String,
        output: String,
        segments: [[String: Any]],
        outputFormat: String
    ) async throws -> String {
        // Validate input file
        let inputURL = URL(fileURLWithPath: input)
        guard FileManager.default.fileExists(atPath: input) else {
            throw VideoProcessorError.fileNotFound
        }
        
        // Parse segments
        let speedSegments = segments.compactMap { SpeedSegment(from: $0) }
        guard !speedSegments.isEmpty else {
            throw VideoProcessorError.invalidParameters
        }
        
        // Load asset
        let asset = AVAsset(url: inputURL)
        
        // Load duration and tracks using modern async API
        let duration = try await asset.load(.duration)
        let tracks = try await asset.load(.tracks)
        
        guard !tracks.isEmpty else {
            throw VideoProcessorError.unsupportedFormat
        }
        
        // Create mutable composition
        let composition = AVMutableComposition()
        
        // Add video and audio tracks
        try await addTracksToComposition(
            composition: composition,
            asset: asset,
            segments: speedSegments,
            duration: duration
        )
        
        // Create audio mix for pitch correction
        let audioMix = createAudioMix(
            composition: composition,
            segments: speedSegments
        )
        
        // Set up export session
        let outputURL = URL(fileURLWithPath: output)
        
        // Remove existing file if present
        try? FileManager.default.removeItem(at: outputURL)
        
        // Determine export preset
        let preset = AVAssetExportPresetHighestQuality
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: preset
        ) else {
            throw VideoProcessorError.exportFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.audioMix = audioMix
        
        // Store for cancellation
        self.currentExportSession = exportSession
        
        // Start progress monitoring
        startProgressMonitoring(exportSession: exportSession)
        
        // Export
        try await exportSession.export(to: outputURL, as: .mp4)
        
        // Stop progress monitoring
        stopProgressMonitoring()
        
        // Check export status
        guard exportSession.status == .completed else {
            if exportSession.status == .cancelled {
                throw VideoProcessorError.cancelled
            }
            throw VideoProcessorError.exportFailed
        }
        
        return output
    }
    
    // MARK: - Track Composition
    
    private func addTracksToComposition(
        composition: AVMutableComposition,
        asset: AVAsset,
        segments: [SpeedSegment],
        duration: CMTime
    ) async throws {
        // Get video and audio tracks
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        
        // Add video track
        if let videoTrack = videoTracks.first {
            let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
            
            try await addSegmentsToTrack(
                compositionTrack: compositionVideoTrack!,
                sourceTrack: videoTrack,
                segments: segments,
                duration: duration
            )
        }
        
        // Add audio track
        if let audioTrack = audioTracks.first {
            let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
            
            try await addSegmentsToTrack(
                compositionTrack: compositionAudioTrack!,
                sourceTrack: audioTrack,
                segments: segments,
                duration: duration
            )
        }
    }
    
    private func addSegmentsToTrack(
        compositionTrack: AVMutableCompositionTrack,
        sourceTrack: AVAssetTrack,
        segments: [SpeedSegment],
        duration: CMTime
    ) async throws {
        var currentTime = CMTime.zero
        let durationSeconds = duration.seconds
        
        for (index, segment) in segments.enumerated() {
            let startTime = CMTime(seconds: segment.start, preferredTimescale: 600)
            
            // Determine end time
            let endTimeSeconds: Double
            if let segmentEnd = segment.end {
                endTimeSeconds = min(segmentEnd, durationSeconds)
            } else if index < segments.count - 1 {
                endTimeSeconds = segments[index + 1].start
            } else {
                endTimeSeconds = durationSeconds
            }
            
            let endTime = CMTime(seconds: endTimeSeconds, preferredTimescale: 600)
            let segmentDuration = endTime - startTime
            
            guard segmentDuration.seconds > 0 else { continue }
            
            // Calculate scaled duration
            let scaledDuration = CMTimeMultiplyByFloat64(
                segmentDuration,
                multiplier: 1.0 / segment.speed
            )
            
            // Insert time range
            let timeRange = CMTimeRange(start: startTime, duration: segmentDuration)
            
            try compositionTrack.insertTimeRange(
                timeRange,
                of: sourceTrack,
                at: currentTime
            )
            
            // Scale time range
            compositionTrack.scaleTimeRange(
                CMTimeRange(start: currentTime, duration: segmentDuration),
                toDuration: scaledDuration
            )
            
            currentTime = CMTimeAdd(currentTime, scaledDuration)
        }
    }
    
    // MARK: - Audio Mix Creation
    
    private func createAudioMix(
        composition: AVMutableComposition,
        segments: [SpeedSegment]
    ) -> AVMutableAudioMix {
        let audioMix = AVMutableAudioMix()
        var audioMixParams: [AVMutableAudioMixInputParameters] = []
        
        for track in composition.tracks(withMediaType: .audio) {
            let params = AVMutableAudioMixInputParameters(track: track)
            
            // Use the pitch algorithm from the first segment
            // (In a more sophisticated implementation, you'd handle multiple algorithms)
            if let firstSegment = segments.first {
                params.audioTimePitchAlgorithm = firstSegment.pitchAlgorithm
            }
            
            audioMixParams.append(params)
        }
        
        audioMix.inputParameters = audioMixParams
        return audioMix
    }
    
    // MARK: - Progress Monitoring
    
    private func startProgressMonitoring(exportSession: AVAssetExportSession) {
        DispatchQueue.main.async { [weak self] in
            self?.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                let progress = exportSession.progress
                self?.sendEvent(
                    withName: "VideoProcessorProgress",
                    body: ["progress": Double(progress)]
                )
            }
        }
    }
    
    private func stopProgressMonitoring() {
        DispatchQueue.main.async { [weak self] in
            self?.progressTimer?.invalidate()
            self?.progressTimer = nil
            
            // Send final progress
            self?.sendEvent(
                withName: "VideoProcessorProgress",
                body: ["progress": 1.0]
            )
        }
    }
    
    // MARK: - Trim Video
    
    @objc
    func trimVideo(
        _ input: String,
        output: String,
        startTime: Double,
        endTime: Double,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        Task {
            do {
                let result = try await trimVideoAsync(
                    input: input,
                    output: output,
                    startTime: startTime,
                    endTime: endTime
                )
                resolve(result)
            } catch let error as VideoProcessorError {
                reject(error.code, error.message, error)
            } catch {
                reject("EXPORT_FAILED", error.localizedDescription, error)
            }
        }
    }
    
    private func trimVideoAsync(
        input: String,
        output: String,
        startTime: Double,
        endTime: Double
    ) async throws -> String {
        let inputURL = URL(fileURLWithPath: input)
        guard FileManager.default.fileExists(atPath: input) else {
            throw VideoProcessorError.fileNotFound
        }
        
        let asset = AVAsset(url: inputURL)
        let outputURL = URL(fileURLWithPath: output)
        
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw VideoProcessorError.exportFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        // Set time range
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let end = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: start, end: end)
        exportSession.timeRange = timeRange
        
        self.currentExportSession = exportSession
        startProgressMonitoring(exportSession: exportSession)
        
        try await exportSession.export(to: outputURL, as: .mp4)
        
        stopProgressMonitoring()
        
        guard exportSession.status == .completed else {
            throw VideoProcessorError.exportFailed
        }
        
        return output
    }
    
    // MARK: - Get Metadata
    
    @objc
    func getMetadata(
        _ input: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        Task {
            do {
                let metadata = try await getMetadataAsync(input: input)
                resolve(metadata)
            } catch let error as VideoProcessorError {
                reject(error.code, error.message, error)
            } catch {
                reject("EXPORT_FAILED", error.localizedDescription, error)
            }
        }
    }
    
    private func getMetadataAsync(input: String) async throws -> [String: Any] {
        let inputURL = URL(fileURLWithPath: input)
        guard FileManager.default.fileExists(atPath: input) else {
            throw VideoProcessorError.fileNotFound
        }
        
        let asset = AVAsset(url: inputURL)
        
        // Load properties asynchronously
        let duration = try await asset.load(.duration)
        let tracks = try await asset.load(.tracks)
        
        var metadata: [String: Any] = [:]
        metadata["duration"] = duration.seconds
        
        // Get video track info
        if let videoTrack = try? await asset.loadTracks(withMediaType: .video).first {
            let naturalSize = try await videoTrack.load(.naturalSize)
            let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)
            
            metadata["width"] = Int(naturalSize.width)
            metadata["height"] = Int(naturalSize.height)
            metadata["frameRate"] = Double(nominalFrameRate)
            
            // Get codec
            if let formatDescriptions = try? await videoTrack.load(.formatDescriptions) as? [CMFormatDescription],
               let formatDescription = formatDescriptions.first {
                let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
                metadata["videoCodec"] = fourCCToString(codecType)
            }
        }
        
        // Get audio track info
        if let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first {
            if let formatDescriptions = try? await audioTrack.load(.formatDescriptions) as? [CMFormatDescription],
               let formatDescription = formatDescriptions.first {
                let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
                metadata["audioCodec"] = fourCCToString(codecType)
            }
        }
        
        // Get file size
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: input)[.size] as? Int {
            metadata["fileSize"] = fileSize
        }
        
        return metadata
    }
    
    // MARK: - Generate Thumbnail
    
    @objc
    func generateThumbnail(
        _ input: String,
        output: String,
        time: Double,
        maxWidth: NSNumber?,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        Task {
            do {
                let result = try await generateThumbnailAsync(
                    input: input,
                    output: output,
                    time: time,
                    maxWidth: maxWidth?.intValue
                )
                resolve(result)
            } catch let error as VideoProcessorError {
                reject(error.code, error.message, error)
            } catch {
                reject("EXPORT_FAILED", error.localizedDescription, error)
            }
        }
    }
    
    private func generateThumbnailAsync(
        input: String,
        output: String,
        time: Double,
        maxWidth: Int?
    ) async throws -> String {
        let inputURL = URL(fileURLWithPath: input)
        guard FileManager.default.fileExists(atPath: input) else {
            throw VideoProcessorError.fileNotFound
        }
        
        let asset = AVAsset(url: inputURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        if let maxWidth = maxWidth {
            imageGenerator.maximumSize = CGSize(width: maxWidth, height: maxWidth)
        }
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        
        let cgImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
        
        #if os(macOS)
        let image = NSImage(cgImage: cgImage, size: .zero)
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let imageData = bitmapImage.representation(using: .jpeg, properties: [:]) else {
            throw VideoProcessorError.exportFailed
        }
        #else
        let image = UIImage(cgImage: cgImage)
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw VideoProcessorError.exportFailed
        }
        #endif
        
        let outputURL = URL(fileURLWithPath: output)
        try imageData.write(to: outputURL)
        
        return output
    }
    
    // MARK: - Adjust Volume
    
    @objc
    func adjustVolume(
        _ input: String,
        output: String,
        volume: Double,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        Task {
            do {
                let result = try await adjustVolumeAsync(
                    input: input,
                    output: output,
                    volume: volume
                )
                resolve(result)
            } catch let error as VideoProcessorError {
                reject(error.code, error.message, error)
            } catch {
                reject("EXPORT_FAILED", error.localizedDescription, error)
            }
        }
    }
    
    private func adjustVolumeAsync(
        input: String,
        output: String,
        volume: Double
    ) async throws -> String {
        let inputURL = URL(fileURLWithPath: input)
        guard FileManager.default.fileExists(atPath: input) else {
            throw VideoProcessorError.fileNotFound
        }
        
        let asset = AVAsset(url: inputURL)
        let composition = AVMutableComposition()
        
        // Add all tracks
        let duration = try await asset.load(.duration)
        let timeRange = CMTimeRange(start: .zero, duration: duration)
        
        for track in try await asset.loadTracks(withMediaType: .video) {
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
            try compositionTrack?.insertTimeRange(timeRange, of: track, at: .zero)
        }
        
        var audioMixParams: [AVMutableAudioMixInputParameters] = []
        
        for track in try await asset.loadTracks(withMediaType: .audio) {
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
            try compositionTrack?.insertTimeRange(timeRange, of: track, at: .zero)
            
            // Set volume
            let params = AVMutableAudioMixInputParameters(track: compositionTrack)
            params.setVolume(Float(volume), at: .zero)
            audioMixParams.append(params)
        }
        
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = audioMixParams
        
        let outputURL = URL(fileURLWithPath: output)
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw VideoProcessorError.exportFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.audioMix = audioMix
        
        self.currentExportSession = exportSession
        startProgressMonitoring(exportSession: exportSession)
        
        try await exportSession.export(to: outputURL, as: .mp4)
        
        stopProgressMonitoring()
        
        guard exportSession.status == .completed else {
            throw VideoProcessorError.exportFailed
        }
        
        return output
    }
    
    // MARK: - Cancel Processing
    
    @objc
    func cancelProcessing() {
        currentExportSession?.cancelExport()
        stopProgressMonitoring()
    }
    
    // MARK: - Helpers
    
    private func fourCCToString(_ fourCC: FourCharCode) -> String {
        let bytes: [UInt8] = [
            UInt8((fourCC >> 24) & 0xFF),
            UInt8((fourCC >> 16) & 0xFF),
            UInt8((fourCC >> 8) & 0xFF),
            UInt8(fourCC & 0xFF)
        ]
        return String(bytes: bytes, encoding: .ascii) ?? "Unknown"
    }
}

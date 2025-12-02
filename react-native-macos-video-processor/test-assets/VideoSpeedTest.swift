import Foundation
import AVFoundation

// MARK: - Video Speed Processor Test
// Tests the core speed processing logic from VideoProcessor.swift

@available(macOS 12.0, *)
@main
struct VideoSpeedTest {
    static func main() async {
        print("🎬 Video Speed Processing Test")
        print("================================\n")
        
        // Get arguments
        guard CommandLine.arguments.count >= 4 else {
            print("Usage: VideoSpeedTest <input-video> <output-video> <speed>")
            print("\nExample:")
            print("  VideoSpeedTest experience.mov output.mov 2.0")
            print("\nSpeed range: 0.1 - 32.0")
            print("  0.5  = half speed (slow motion)")
            print("  1.0  = normal speed")
            print("  2.0  = double speed")
            print("  16.0 = timelapse")
            exit(1)
        }
        
        let inputPath = CommandLine.arguments[1]
        let outputPath = CommandLine.arguments[2]
        let speedString = CommandLine.arguments[3]
        
        guard let speed = Double(speedString), speed >= 0.1 && speed <= 32.0 else {
            print("❌ Error: Speed must be between 0.1 and 32.0")
            exit(1)
        }
        
        let inputURL = URL(fileURLWithPath: (inputPath as NSString).expandingTildeInPath)
        let outputURL = URL(fileURLWithPath: (outputPath as NSString).expandingTildeInPath)
        
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            print("❌ Error: Input file not found at \(inputURL.path)")
            exit(1)
        }
        
        print("📂 Input:  \(inputURL.lastPathComponent)")
        print("📂 Output: \(outputURL.lastPathComponent)")
        print("⚡ Speed:  \(speed)x")
        print("")
        
        do {
            try await processVideo(input: inputURL, output: outputURL, speed: speed)
            print("\n✅ Success! Video processed at \(speed)x speed")
            print("📁 Output saved to: \(outputURL.path)")
            exit(0)
        } catch {
            print("\n❌ Error: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    static func processVideo(input: URL, output: URL, speed: Double) async throws {
        let asset = AVAsset(url: input)
        
        // Load duration
        let duration = try await asset.load(.duration)
        print("⏱️  Original duration: \(String(format: "%.2f", duration.seconds))s")
        
        let newDuration = duration.seconds / speed
        print("⏱️  New duration: \(String(format: "%.2f", newDuration))s")
        print("")
        
        // Create composition
        let composition = AVMutableComposition()
        
        // Add video track
        if let videoTrack = try? await asset.loadTracks(withMediaType: .video).first {
            print("📹 Processing video track...")
            let compositionVideoTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )!
            
            let timeRange = CMTimeRange(start: .zero, duration: duration)
            try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
            
            // Scale the time
            let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / speed)
            compositionVideoTrack.scaleTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                toDuration: scaledDuration
            )
        }
        
        // Add audio track with pitch correction
        var audioMix: AVMutableAudioMix?
        if let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first {
            print("🔊 Processing audio track with pitch correction...")
            
            let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )!
            
            let timeRange = CMTimeRange(start: .zero, duration: duration)
            try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
            
            // Scale the time
            let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / speed)
            compositionAudioTrack.scaleTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                toDuration: scaledDuration
            )
            
            // Create audio mix for pitch correction
            let audioMixParams = AVMutableAudioMixInputParameters(track: compositionAudioTrack)
            audioMixParams.audioTimePitchAlgorithm = .spectral // High quality pitch correction
            
            let mix = AVMutableAudioMix()
            mix.inputParameters = [audioMixParams]
            audioMix = mix
        }
        
        // Remove existing output file
        try? FileManager.default.removeItem(at: output)
        
        // Create export session
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw NSError(domain: "VideoSpeedTest", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create export session"
            ])
        }
        
        exportSession.outputURL = output
        exportSession.outputFileType = .mov
        exportSession.audioMix = audioMix
        
        print("🎬 Exporting video...")
        print("")
        
        // Start export with progress monitoring
        let progressTask = Task {
            while !Task.isCancelled {
                let progress = Int(exportSession.progress * 100)
                print("\r⏳ Progress: \(progress)%", terminator: "")
                fflush(stdout)
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
        }
        
        // Export  
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            exportSession.exportAsynchronously {
                if exportSession.status == .completed {
                    continuation.resume()
                } else if let error = exportSession.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "VideoSpeedTest", code: 3, userInfo: [
                        NSLocalizedDescriptionKey: "Export failed with status: \(exportSession.status.rawValue)"
                    ]))
                }
            }
        }
        
        progressTask.cancel()
        
        print("\r✅ Progress: 100%")
    }
}

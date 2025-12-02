import Foundation
import AVFoundation

// MARK: - Standalone Video Metadata Extractor
// This tests the core AVFoundation logic without React Native

@available(macOS 12.0, *)
@main
struct VideoMetadataTest {
    static func main() async {
        print("🎬 Video Metadata Test Tool")
        print("============================\n")
        
        // Get video path from command line
        guard CommandLine.arguments.count > 1 else {
            print("Usage: VideoMetadataTest <path-to-video-file>")
            print("\nExample:")
            print("  VideoMetadataTest ~/Movies/sample.mp4")
            exit(1)
        }
        
        let videoPath = CommandLine.arguments[1]
        let videoURL = URL(fileURLWithPath: (videoPath as NSString).expandingTildeInPath)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            print("❌ Error: File not found at \(videoURL.path)")
            exit(1)
        }
        
        print("📂 Input: \(videoURL.path)\n")
        
        do {
            let metadata = try await extractMetadata(from: videoURL)
            printMetadata(metadata)
            print("\n✅ Success! Metadata extracted successfully.")
            exit(0)
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            exit(1)
        }
    }
    
    static func extractMetadata(from url: URL) async throws -> VideoMetadata {
        let asset = AVAsset(url: url)
        
        // Load properties asynchronously
        let duration = try await asset.load(.duration)
        
        var metadata = VideoMetadata()
        metadata.duration = duration.seconds
        
        // Get video track info
        if let videoTrack = try? await asset.loadTracks(withMediaType: .video).first {
            let naturalSize = try await videoTrack.load(.naturalSize)
            let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)
            
            metadata.width = Int(naturalSize.width)
            metadata.height = Int(naturalSize.height)
            metadata.frameRate = Double(nominalFrameRate)
            
            // Get codec
            if let formatDescriptions = try? await videoTrack.load(.formatDescriptions) as? [CMFormatDescription],
               let formatDescription = formatDescriptions.first {
                let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
                metadata.videoCodec = fourCCToString(codecType)
            }
        }
        
        // Get audio track info
        if let audioTrack = try? await asset.loadTracks(withMediaType: .audio).first {
            if let formatDescriptions = try? await audioTrack.load(.formatDescriptions) as? [CMFormatDescription],
               let formatDescription = formatDescriptions.first {
                let codecType = CMFormatDescriptionGetMediaSubType(formatDescription)
                metadata.audioCodec = fourCCToString(codecType)
            }
        }
        
        // Get file size
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int {
            metadata.fileSize = fileSize
        }
        
        return metadata
    }
    
    static func printMetadata(_ metadata: VideoMetadata) {
        print("📊 Video Metadata:")
        print("  Duration:     \(String(format: "%.2f", metadata.duration)) seconds")
        
        if let width = metadata.width, let height = metadata.height {
            print("  Resolution:   \(width) x \(height)")
        }
        
        if let frameRate = metadata.frameRate {
            print("  Frame Rate:   \(String(format: "%.2f", frameRate)) fps")
        }
        
        if let codec = metadata.videoCodec {
            print("  Video Codec:  \(codec)")
        }
        
        if let audioCodec = metadata.audioCodec {
            print("  Audio Codec:  \(audioCodec)")
        }
        
        if let fileSize = metadata.fileSize {
            let sizeMB = Double(fileSize) / 1024.0 / 1024.0
            print("  File Size:    \(String(format: "%.2f", sizeMB)) MB")
        }
    }
    
    static func fourCCToString(_ fourCC: FourCharCode) -> String {
        let bytes: [UInt8] = [
            UInt8((fourCC >> 24) & 0xFF),
            UInt8((fourCC >> 16) & 0xFF),
            UInt8((fourCC >> 8) & 0xFF),
            UInt8(fourCC & 0xFF)
        ]
        return String(bytes: bytes, encoding: .ascii) ?? "Unknown"
    }
}

struct VideoMetadata {
    var duration: Double = 0
    var width: Int?
    var height: Int?
    var frameRate: Double?
    var videoCodec: String?
    var audioCodec: String?
    var fileSize: Int?
}

# Product Requirements Document (PRD)
## React Native macOS Video Processor

### 1. Overview
A high-performance, native macOS module for React Native that leverages Apple's `AVFoundation` framework to process video files. The initial core feature is changing video playback speed (time scaling) while optionally preserving audio pitch.

### 2. Goals
- **Native Performance:** Use macOS hardware acceleration (VideoToolbox via AVFoundation) for fast encoding/decoding.
- **App Store Compliant:** Use only public Apple APIs to ensure acceptance on the Mac App Store.
- **Reusable Core:** Built as a standalone library (`react-native-macos-video-processor`) to be used in multiple projects.
- **User Experience:** Provide real-time progress updates to the UI during processing.

### 3. Key Features

#### 3.1 Video Speed Adjustment
- **Input:** Local file path (supported formats: `.mov`, `.mp4`, `.m4v`).
- **Functionality:** Change speed by a factor (e.g., 0.5x, 2.0x).
- **Audio Processing:**
    - Default: Preserve pitch using `AVAudioTimePitchAlgorithmSpectral` (high quality).
    - Option: Allow "chipmunk" effect (Varispeed) if requested (future scope).
- **Output:** Exported video file (default: `.mp4` or `.mov`).

#### 3.2 Progress Reporting
- Emit events from native side to JavaScript during export.
- Payload: `{ progress: 0.0 to 1.0 }`.

#### 3.3 Error Handling
- Robust error codes for common failures:
    - File not found.
    - Unsupported format.
    - Export session failure (disk space, permissions).

### 4. Technical Architecture

#### 4.1 Tech Stack
- **JavaScript/TypeScript:** React Native layer for API and types.
- **Swift:** Native macOS implementation.
- **AVFoundation:** Core framework for media manipulation.

#### 4.2 API Design (Target Spec)
```typescript
type SpeedSegment = {
  start: number;      // seconds
  end?: number;       // omit = until next segment or end of video
  speed: number;      // 0.1x – 32x
  pitchCorrection?: "voice" | "highQuality" | "none"; // Maps to AVAudioTimePitchAlgorithm
};

type ProcessingOptions = {
  input: string;
  output: string;
  segments?: SpeedSegment[];           // if omitted → single speed for whole video
  preset?: "2x-lecture" | "16x-timelapse" | "slowmo-sports"; // Maps to presets
  removeSilences?: boolean | { thresholdDb?: number; minDuration?: number }; // (V2 Feature)
  direction?: "forward" | "reverse"; // (V2 Feature)
  outputFormat?: "video" | "audio" | "both";
  onProgress?: (progress: number) => void;
};

// Main Method
function processVideo(options: ProcessingOptions): Promise<string>; // Returns taskId or output path
```

#### 4.3 Feasibility Notes
- **Segments:** Fully supported via `AVMutableComposition`.
- **Pitch Correction:** Supported via `AVMutableAudioMixInputParameters`. Note: Changing algorithms mid-stream requires splitting tracks.
- **Remove Silences:** Requires a pre-processing pass to analyze audio power levels (V2).
- **Reverse:** Requires frame-by-frame rewriting, computationally expensive (V2).


### 5. Research & Constraints

#### 5.1 Supported Formats (Import)
AVFoundation natively supports:
- H.264, HEVC (H.265)
- Containers: QuickTime (`.mov`), MPEG-4 (`.mp4`, `.m4v`)
- *Note: Does not support third-party codecs (e.g., MKV, AVI with non-standard codecs) without conversion.*

#### 5.2 Export Presets
We will use `AVAssetExportSession` with configurable presets:
- **Default:** `AVAssetExportPresetHighestQuality` (matches source resolution).
- **HEVC:** `AVAssetExportPresetHEVCHighestQuality` (better compression, requires newer hardware).

#### 5.3 Audio Pitch Correction
- **Algorithm:** `AVAudioTimePitchAlgorithmSpectral` is the recommended algorithm for maintaining high-quality audio pitch when changing duration.
- **Implementation:** Requires using `AVMutableAudioMix` applied to the export session.

#### 5.4 Testing Suite
Swift + AVFoundation is notoriously hard to unit test. We however should have a good coverage.

### 6. Potential "Low Hanging Fruit" Features
These features leverage the same `AVAsset` and `AVAssetExportSession` infrastructure and can be added with minimal extra effort:

#### 6.1 Trimming / Cutting
- **Why it's easy:** `AVAssetExportSession` has a `timeRange` property. We just pass start/end times.
- **Value:** Users almost always want to trim start/end when processing video.

#### 6.2 Metadata Extraction
- **Why it's easy:** `AVAsset` provides immediate access to duration, dimensions, and tracks.
- **Value:** Essential for UI (showing "Original Duration: 10s -> New Duration: 5s").

#### 6.3 Thumbnail Generation
- **Why it's easy:** `AVAssetImageGenerator` is a standard API to get a frame at a specific time.
- **Value:** Great for showing previews in the app list.

#### 6.4 Volume Control / Mute
- **Why it's easy:** `AVMutableAudioMix` (already used for pitch) allows setting volume ramps or muting tracks.

Accessibility & Localization. Progress reporting via native progress indicator.  App Store requires accessible progress for long operations.

### 7. Future Scope
- **Reversing:** (Requires complex frame-by-frame rewriting, not "free").
- **Merging multiple clips:** (Requires complex composition logic).
- **Watermarks/Overlays:** (Requires `AVVideoComposition` with Core Animation).



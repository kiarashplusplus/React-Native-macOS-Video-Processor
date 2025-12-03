# React Native macOS Video Processor

A production-ready React Native library that bridges JavaScript with Apple's AVFoundation framework to enable native-speed video processing on macOS. Built as a reusable npm package for creating high-performance video manipulation applications.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%2011%2B-lightgrey.svg)](https://www.apple.com/macos/)
[![React Native](https://img.shields.io/badge/React%20Native-0.68%2B-61dafb.svg)](https://reactnative.dev/)
[![npm version](https://img.shields.io/npm/v/react-native-macos-video-processor.svg?style=flat)](https://www.npmjs.com/package/react-native-macos-video-processor)

**Author**: Kiarash Adl  
**Contact**: kiarasha@alum.mit.edu | https://25x.codes  
**License**: Apache-2.0

---

## 🚀 Features

### Core Features
- ⚡ **Variable Speed Processing** (0.1x to 32x) with intelligent pitch correction
- 🎯 **Native Performance** using macOS hardware acceleration via AVFoundation
- 🍏 **App Store Compliant** - 100% public Apple APIs
- 📊 **Real-time Progress Reporting** with event-driven architecture
- 🔧 **TypeScript-first API** with comprehensive type definitions

### Quick-Win Features
- ✂️ **Video Trimming/Cutting** - Precise time-range extraction
- 📋 **Metadata Extraction** - Duration, dimensions, codec info
- 🖼️ **Thumbnail Generation** - Extract preview frames
- 🔊 **Volume Control** - Adjust or mute audio

---

## 📦 Installation

```bash
npm install react-native-macos-video-processor
# or
yarn add react-native-macos-video-processor
```

### macOS Setup

```bash
cd example/macos
pod install
```

---

## 🎯 Usage

### Process Video with Speed Adjustment

```typescript
import { processVideo } from 'react-native-macos-video-processor';

// Simple preset usage
await processVideo({
  input: '/path/to/input.mp4',
  output: '/path/to/output.mp4',
  preset: '2x-lecture', // '2x-lecture', '16x-timelapse', 'slowmo-sports'
  onProgress: (progress) => {
    console.log(`Progress: ${progress * 100}%`);
  },
});

// Custom speed segments
await processVideo({
  input: '/path/to/input.mp4',
  output: '/path/to/output.mp4',
  segments: [
    { start: 0, end: 10, speed: 2.0, pitchCorrection: 'voice' },
    { start: 10, end: 30, speed: 1.0 },
    { start: 30, speed: 16.0, pitchCorrection: 'none' },
  ],
  onProgress: (progress) => console.log(progress),
});
```

### Trim Video

```typescript
import { trimVideo } from 'react-native-macos-video-processor';

await trimVideo({
  input: '/path/to/input.mp4',
  output: '/path/to/trimmed.mp4',
  startTime: 10.5,
  endTime: 45.0,
  onProgress: (progress) => console.log(progress),
});
```

### Get Video Metadata

```typescript
import { getVideoMetadata } from 'react-native-macos-video-processor';

const metadata = await getVideoMetadata('/path/to/video.mp4');
console.log(`Duration: ${metadata.duration}s`);
console.log(`Resolution: ${metadata.width}x${metadata.height}`);
console.log(`Frame Rate: ${metadata.frameRate} fps`);
console.log(`Video Codec: ${metadata.videoCodec}`);
console.log(`File Size: ${metadata.fileSize} bytes`);
```

### Generate Thumbnail

```typescript
import { generateThumbnail } from 'react-native-macos-video-processor';

await generateThumbnail({
  input: '/path/to/video.mp4',
  output: '/path/to/thumbnail.jpg',
  time: 5.0, // Capture at 5 seconds
  maxWidth: 1920, // Optional: max width in pixels
});
```

### Adjust Volume

```typescript
import { adjustVolume } from 'react-native-macos-video-processor';

// Mute video
await adjustVolume({
  input: '/path/to/video.mp4',
  output: '/path/to/muted.mp4',
  volume: 0,
});

// Double volume
await adjustVolume({
  input: '/path/to/video.mp4',
  output: '/path/to/loud.mp4',
  volume: 2.0,
});
```

---

## 📚 API Reference

### `processVideo(options: ProcessingOptions): Promise<string>`

Process video with variable speed and pitch correction.

**Parameters:**
- `input: string` - Input file path (absolute path or file:// URI)
- `output: string` - Output file path
- `segments?: SpeedSegment[]` - Array of speed segments (optional)
- `preset?: ProcessingPreset` - Preset configuration: `'2x-lecture'`, `'16x-timelapse'`, `'slowmo-sports'`
- `outputFormat?: OutputFormat` - Output format: `'video'`, `'audio'`, or `'both'` (default: `'both'`)
- `onProgress?: (progress: number) => void` - Progress callback (0.0 to 1.0)

**Returns:** Promise that resolves to output file path

### `trimVideo(options: TrimOptions): Promise<string>`

Trim/cut video to specific time range.

**Parameters:**
- `input: string` - Input file path
- `output: string` - Output file path
- `startTime: number` - Start time in seconds
- `endTime: number` - End time in seconds
- `onProgress?: (progress: number) => void` - Progress callback

**Returns:** Promise that resolves to output file path

### `getVideoMetadata(filePath: string): Promise<VideoMetadata>`

Extract metadata from video file.

**Returns:** Promise that resolves to metadata object containing:
- `duration: number` - Duration in seconds
- `width: number` - Video width in pixels
- `height: number` - Video height in pixels
- `frameRate: number` - Frame rate (fps)
- `videoCodec: string` - Video codec name
- `audioCodec?: string` - Audio codec name (if present)
- `fileSize: number` - File size in bytes

### `generateThumbnail(options: ThumbnailOptions): Promise<string>`

Generate thumbnail image from video.

**Parameters:**
- `input: string` - Input file path
- `output: string` - Output image path (.jpg or .png)
- `time?: number` - Time in seconds to capture (default: 0)
- `maxWidth?: number` - Maximum width in pixels (maintains aspect ratio)

**Returns:** Promise that resolves to output image path

### `adjustVolume(options: VolumeOptions): Promise<string>`

Adjust video volume.

**Parameters:**
- `input: string` - Input file path
- `output: string` - Output file path
- `volume: number` - Volume multiplier (0.0 = mute, 1.0 = original, 2.0 = double)
- `onProgress?: (progress: number) => void` - Progress callback

**Returns:** Promise that resolves to output file path

### `cancelProcessing(): void`

Cancel ongoing video processing operation.

---

## 🎨 Types

### `SpeedSegment`

```typescript
interface SpeedSegment {
  start: number;              // Start time in seconds
  end?: number;               // End time (omit for "until next segment or end")
  speed: number;              // Speed multiplier (0.1 - 32.0)
  pitchCorrection?: 'voice' | 'highQuality' | 'none'; // Default: 'highQuality'
}
```

### Pitch Correction Algorithms

- `'voice'` - Optimized for voice/lectures (AVAudioTimePitchAlgorithmSpectral)
- `'highQuality'` - Best overall quality (AVAudioTimePitchAlgorithmSpectral)
- `'none'` - No correction, "chipmunk" effect (AVAudioTimePitchAlgorithmVarispeed)

### `VideoProcessorError`

All errors are instances of `VideoProcessorError` with the following codes:

```typescript
enum VideoProcessorErrorCode {
  FILE_NOT_FOUND = 'FILE_NOT_FOUND',
  UNSUPPORTED_FORMAT = 'UNSUPPORTED_FORMAT',
  EXPORT_FAILED = 'EXPORT_FAILED',
  INSUFFICIENT_SPACE = 'INSUFFICIENT_SPACE',
  INVALID_PARAMETERS = 'INVALID_PARAMETERS',
  CANCELLED = 'CANCELLED',
}
```

---

## 🔧 Technical Details

### Supported Formats

**Input:**
- H.264, HEVC (H.265)
- Containers: QuickTime (.mov), MPEG-4 (.mp4, .m4v)

**Output:**
- .mp4 (H.264 or HEVC)
- AVAssetExportPresetHighestQuality

### Requirements

- macOS 11.0 (Big Sur) or later
- React Native 0.68+
- Xcode 13+

### Architecture

- **Native Layer:** Swift using modern async/await AVFoundation APIs
- **JavaScript Layer:** TypeScript with comprehensive type definitions
- **Communication:** Event-driven progress reporting via NativeEventEmitter
- **Module Type:** Legacy Native Modules (upgrade path to TurboModules available)

---

## 🧪 Example App

The library includes a fully functional example app demonstrating all features:

```bash
cd example
npm install
cd macos
pod install
cd ..
npm run macos
```

---

## 📄 License

Apache-2.0

Copyright (c) 2025 Kiarash Adl

---

## 📞 Contact

**Kiarash Adl**  
Email: kiarasha@alum.mit.edu  
Website: https://25x.codes  
GitHub: [@kiarashplusplus](https://github.com/kiarashplusplus)

---

## 🙏 Acknowledgments

- React Native core team for the New Architecture
- Microsoft for maintaining React Native macOS
- Apple for AVFoundation framework
- Callstack for create-react-native-library

---

**Status**: 🚀 Ready for Production

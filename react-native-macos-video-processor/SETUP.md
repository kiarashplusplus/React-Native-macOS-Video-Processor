# Setup Guide

## Quick Start

### 1. Installation

```bash
npm install react-native-macos-video-processor
# or
yarn add react-native-macos-video-processor
```

### 2. macOS Configuration

Since this is a macOS-specific library, you need to ensure your React Native project supports macOS:

```bash
# Add macOS support to your React Native project
npx react-native-macos-init
```

### 3. Install Native Dependencies

```bash
cd macos  # or ios if using the shared directory
pod install
cd ..
```

### 4. Rebuild Your App

```bash
npx react-native run-macos
```

## Troubleshooting

### Module Not Found

If you get a "Module not found" error:

1. Make sure you ran `pod install`
2. Clean and rebuild:
   ```bash
   cd macos
   pod install
   cd ..
   rm -rf ~/Library/Developer/Xcode/DerivedData
   npx react-native run-macos
   ```

### Swift Compilation Errors

Ensure you have:
- Xcode 13+ installed
- macOS 11+ deployment target in your project

### File Not Found Errors

- Use absolute paths for video files
- Ensure files exist before processing
- Check file permissions

## Usage Examples

### Basic Speed Change

```typescript
import { processVideo } from 'react-native-macos-video-processor';

const speedUpVideo = async () => {
  try {
    await processVideo({
      input: '/Users/username/Videos/input.mp4',
      output: '/Users/username/Videos/output.mp4',
      preset: '2x-lecture', // 2x speed with voice optimization
      onProgress: (progress) => {
        console.log(`Progress: ${Math.round(progress * 100)}%`);
      },
    });
    console.log('Video processed successfully!');
  } catch (error) {
    console.error('Processing failed:', error.message);
  }
};
```

### Advanced: Multiple Speed Segments

```typescript
import { processVideo } from 'react-native-macos-video-processor';

const createHighlight = async () => {
  await processVideo({
    input: '/path/to/sports-game.mp4',
    output: '/path/to/highlight-reel.mp4',
    segments: [
      // Intro: normal speed
      { start: 0, end: 5, speed: 1.0 },
      // Boring parts: 8x speed
      { start: 5, end: 60, speed: 8.0, pitchCorrection: 'none' },
      // Action sequence: slow motion
      { start: 60, end: 75, speed: 0.5, pitchCorrection: 'highQuality' },
      // End: normal speed
      { start: 75, speed: 1.0 },
    ],
  });
};
```

### Get File Information

```typescript
import { getVideoMetadata } from 'react-native-macos-video-processor';

const analyzeVideo = async () => {
  const metadata = await getVideoMetadata('/path/to/video.mp4');
  
  console.log(`Duration: ${metadata.duration} seconds`);
  console.log(`Resolution: ${metadata.width}x${metadata.height}`);
  console.log(`Frame Rate: ${metadata.frameRate} fps`);
  console.log(`Size: ${(metadata.fileSize / 1024 / 1024).toFixed(2)} MB`);
};
```

## Performance Tips

1. **Use Presets for Common Use Cases**
   - Presets are optimized configurations
   - `2x-lecture`: Best for voice content
   - `16x-timelapse`: High-speed with no pitch correction
   - `slowmo-sports`: High-quality slow motion

2. **Monitor Progress**
   - Always implement `onProgress` callback
   - Update UI to show progress bar
   - Processing can take several minutes for large files

3. **Output File Management**
   - The library will overwrite existing output files
   - Ensure sufficient disk space (output can be larger than input)
   - Use descriptive filenames to track processed videos

4. **Error Handling**
   - Always wrap processing calls in try-catch
   - Check for specific error codes to handle different scenarios

## Common Use Cases

### Lecture Speed-Up
```typescript
await processVideo({
  input: lecture,
  output: outputPath,
  preset: '2x-lecture',
});
```

### Create Timelapse
```typescript
await processVideo({
  input: longRecording,
  output: timelapse,
  preset: '16x-timelapse',
});
```

### Trim and Speed Up
```typescript
// First trim
const trimmed = await trimVideo({
  input: original,
  output: trimmedPath,
  startTime: 30,
  endTime: 120,
});

// Then speed up
await processVideo({
  input: trimmed,
  output: final,
  preset: '2x-lecture',
});
```

## Next Steps

- See [README.md](./README.md) for complete API reference
- Check the [example app](./example) for UI implementation
- Read [CONTRIBUTING.md](./CONTRIBUTING.md) for development setup

## Support

For issues, questions, or feature requests:
- GitHub Issues: https://github.com/kiarashplusplus/react-native-macos-video-processor/issues
- Email: kiarasha@alum.mit.edu

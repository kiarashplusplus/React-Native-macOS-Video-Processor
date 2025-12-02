# Testing Guide

## Automated Tests Status

### ✅ TypeScript Compilation
- **Status**: PASSING
- **Command**: `npm run prepare`
- **Result**: All TypeScript files compile successfully
- **Output**: Type definitions generated in `lib/typescript/`

### 🔧 Next Steps for Testing

Since this is a native macOS library with AVFoundation dependencies, full testing requires:

1. **Build the native module in Xcode** to validate Swift compilation
2. **Run the example app** on macOS
3. **Test with actual video files**

## Manual Testing Checklist

### Prerequisites
- [ ] macOS 11+ system
- [ ] Xcode 13+ installed
- [ ] Sample video files (.mp4 or .mov)

### Test Cases

#### 1. Speed Processing
- [ ] Test 2x speed with lecture preset
- [ ] Test 16x speed with timelapse preset
- [ ] Test 0.5x slow motion
- [ ] Test custom speed segments
- [ ] Verify pitch correction quality
- [ ] Confirm progress reporting works

#### 2. Trimming
- [ ] Trim video to specific time range
- [ ] Verify output duration is correct
- [ ] Check no quality loss

#### 3. Metadata Extraction
- [ ] Get duration, dimensions, codecs
- [ ] Verify all metadata fields populated
- [ ] Test with different video formats (H.264,HEVC)

#### 4. Thumbnail Generation
- [ ] Generate thumbnail at specific time
- [ ] Test with maxWidth parameter
- [ ] Verify image quality

#### 5. Volume Control
- [ ] Mute video (volume: 0)
- [ ] Double volume (volume: 2.0)
- [ ] Half volume (volume: 0.5)

#### 6. Error Handling
- [ ] Test with non-existent file
- [ ] Test with unsupported format
- [ ] Test with invalid parameters
- [ ] Verify error codes are correct

## Quick Test Commands

### TypeScript/Lint
```bash
cd react-native-macos-video-processor
npm run typecheck   # ✅ PASSING
npm run lint        # Lint the code
```

### Build Library
```bash
npm run prepare     # ✅ PASSING - Builds TypeScript and generates types
```

### Native Build (requires macOS)
```bash
# In Xcode, open the example app's .xcworkspace
# Build the VideoProcessor Swift module
# Check for compilation errors
```

## Test Video Files

Create a directory for test assets:
```bash
mkdir test-assets
cd test-assets
# Add sample .mp4 or .mov files here
```

Recommended test files:
- Short lecture clip (~ 30s) for speed testing
- Long screencast (10+ min) for progress testing  
- High-resolution video for metadata testing
- Various codec files (H.264, HEVC)

## Current Status

✅ **Completed:**
- TypeScript API implementation
- Swift native module implementation  
- Example app UI
- TypeScript compilation verification
- Build system configuration

⏳ **Pending:**
- Swift compilation verification (requires Xcode build)
- macOS example app setup
- Manual testing with real video files
- Performance benchmarking

## Known Issues

1. **React Native macOS Init**: The `react-native-macos-init` command fails due to yarn workspace configuration. Manual macOS setup required for example app.

2. **Yarn Workspaces**: Project uses yarn workspaces but runs into conflicts. Using npm with `--legacy-peer-deps` works.

## Next Actions

1. Set up example app for macOS manually
2. Build native module in Xcode to verify Swift compilation
3. Create sample test videos
4. Run manual tests
5. Document any issues found
6. Update implementation based on test results

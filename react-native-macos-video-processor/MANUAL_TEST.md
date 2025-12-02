# Manual Testing Guide for macOS

## Prerequisites Met ✅
- macOS 13.7 Ventura
- Xcode 15.2
- CocoaPods installed

## Quick Testing Steps

### Step 1: Swift Syntax Check

First, let's verify the Swift code compiles:

```bash
cd react-native-macos-video-processor
./check-swift.sh
```

Expected: Syntax errors about missing React imports (normal - needs full build)

### Step 2: Create a Simple Test Video

Create a test video file or use an existing one:

```bash
# Create test-assets directory
mkdir -p test-assets

# Option 1: Download a sample video
# curl -o test-assets/sample.mp4 https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4

# Option 2: Use an existing video from your Mac
# cp ~/Movies/SomeVideo.mp4 test-assets/input.mp4

# For now, we'll need you to provide a video file
echo "Please add a test .mp4 or .mov file to test-assets/input.mp4"
```

### Step 3: Build a Standalone Test App

Since the example app needs React Native macOS setup (which is complex), let's create a minimal macOS app to test the Swift code:

```bash
# We'll create a simple Xcode project that uses the VideoProcessor Swift code
# This tests the Swift/AVFoundation logic without React Native complexity
```

### Step 4: Alternative - Test with Command Line Tool

Create a simple command-line tool to test the VideoProcessor logic:

```bash
# Create a standalone Swift test
cd test-assets
```

## Recommended Approach

The fastest path to testing is:

**Option A: Create Standalone Swift Test** (Recommended for now)
- Extract the core AVFoundation logic into a standalone Swift file
- Test video processing without React Native
- Verify: speed processing, trimming, metadata extraction

**Option B: Full React Native macOS Setup** (More complex)
- Install React Native macOS in example app
- Build in Xcode
- Test full integration

## What Would You Like to Test First?

1. **Quick validation**: I can create a standalone Swift command-line tool to test the video processing logic
2. **Full integration**: Set up the complete React Native macOS app (more time consuming)
3. **Core functionality**: Just verify one specific feature (e.g., metadata extraction)

Which approach would you prefer?

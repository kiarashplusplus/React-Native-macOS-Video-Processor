# Quick Start: Testing the Video Processor

## You have everything ready! Here's what to do:

### Step 1: Find a test video
```bash
# Look for videos on your Mac
ls -lh ~/Movies/*.{mp4,mov,m4v} ~/Desktop/*.{mp4,mov} 2>/dev/null

# Or check Downloads folder
ls -lh ~/Downloads/*.{mp4,mov} 2>/dev/null
```

**Don't have a video?** You can download a small sample:
```bash
# Download a tiny test video (1.3 MB, 10 seconds)
cd ~/Documents/React-Native-macOS-Video-Processor/react-native-macos-video-processor/test-assets
curl -L -o sample.mp4 "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
```

### Step 2: Build the test tool
```bash
cd ~/Documents/React-Native-macOS-Video-Processor/react-native-macos-video-processor/test-assets
./build-test.sh
```

### Step 3: Run the test
```bash
# Use the sample video
./VideoMetadataTest sample.mp4

# Or use your own video
./VideoMetadataTest ~/path/to/your/video.mp4
```

## Expected Output
```
🎬 Video Metadata Test Tool
============================

📂 Input: /path/to/video.mp4

📊 Video Metadata:
  Duration:     10.00 seconds
  Resolution:   1920 x 1080
  Frame Rate:   30.00 fps
  Video Codec:  avc1
  Audio Codec:  mp4a
  File Size:    1.35 MB

✅ Success! Metadata extracted successfully.
```

## What This Tests
- ✅ Swift compiles correctly
- ✅ AVFoundation async/await works
- ✅ Metadata extraction logic (used by the library)
- ✅ File handling and error cases

## Next Steps After This Test
Once this works, we can test:
1. Speed processing (2x, 16x, etc.)
2. Trimming video
3. Thumbnail generation
4. Full React Native integration

---

**Ready to try?** Just run the commands above and let me know what you see!

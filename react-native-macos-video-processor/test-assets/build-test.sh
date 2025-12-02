#!/bin/bash
# Build and run the Video Metadata Test

echo "🔨 Building VideoMetadataTest..."
echo ""

cd "$(dirname "$0")"

# Compile the Swift test tool (requires macOS 12+ for async/await)
swiftc -o VideoMetadataTest \
  -target x86_64-apple-macosx12.0 \
  -parse-as-library \
  VideoMetadataTest.swift

if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  echo ""
  echo "Usage: ./VideoMetadataTest <video-file-path>"
  echo ""
  echo "Example:"
  echo "  ./VideoMetadataTest ~/Movies/sample.mp4"
  echo "  ./VideoMetadataTest ../experience.mov"
  echo ""
else
  echo "❌ Build failed"
  exit 1
fi

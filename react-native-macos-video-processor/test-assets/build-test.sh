#!/bin/bash
# Build and run the Video Metadata Test

echo "🔨 Building VideoMetadataTest..."
echo ""

cd "$(dirname "$0")"

# Compile the Swift test tool
swiftc -o VideoMetadataTest \
  -target x86_64-apple-macosx11.0 \
  VideoMetadataTest.swift

if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  echo ""
  echo "Usage: ./VideoMetadataTest <video-file-path>"
  echo ""
  echo "Example:"
  echo "  ./VideoMetadataTest ~/Movies/sample.mp4"
  echo ""
else
  echo "❌ Build failed"
  exit 1
fi

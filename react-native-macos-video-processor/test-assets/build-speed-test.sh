#!/bin/bash
# Build the Video Speed Test

echo "🔨 Building VideoSpeedTest..."
echo ""

cd "$(dirname "$0")"

# Compile the Swift test tool
swiftc -o VideoSpeedTest \
  -target x86_64-apple-macosx12.0 \
  -parse-as-library \
  VideoSpeedTest.swift

if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  echo ""
  echo "Usage: ./VideoSpeedTest <input> <output> <speed>"
  echo ""
  echo "Examples:"
  echo "  ./VideoSpeedTest experience.mov output-2x.mov 2.0"
  echo "  ./VideoSpeedTest experience.mov output-4x.mov 4.0"
  echo "  ./VideoSpeedTest experience.mov output-slowmo.mov 0.5"
  echo ""
else
  echo "❌ Build failed"
  exit 1
fi

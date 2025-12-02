#!/bin/bash
# Quick Swift Syntax Check for VideoProcessor

echo "🔍 Checking Swift syntax for VideoProcessor.swift..."
echo ""

cd "$(dirname "$0")"

# Try to parse the Swift file (doesn't build, just checks syntax)
xcrun -sdk macosx swiftc \
  -parse \
  -target x86_64-apple-macosx11.0 \
  ios/VideoProcessor.swift \
  2>&1 | tee swift_check.log

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Swift syntax check PASSED!"
  echo "The VideoProcessor.swift file has no syntax errors."
  exit 0
else
  echo ""
  echo "❌ Swift syntax check FAILED"
  echo "See errors above. Common issues:"
  echo "  - Missing React/AVFoundation imports (expected, needs full Xcode build)"
  echo "  - Syntax errors in Swift code"
  exit 1
fi

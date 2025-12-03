# Changelog

## [0.1.0] - 2024-12-02

### 🎉 First Stable Release!

Promoted from beta to stable after successful publication and initial validation.

**What's New:**
- Stable 0.1.0 release (no breaking changes from beta)
- Core features validated with standalone tests
- Production-ready for macOS video processing

## [0.1.0-beta.1] - 2024-12-02

### 🎉 Initial Beta Release

**Core Features:**
- ⚡ Variable speed processing (0.1x - 32x) with pitch correction
- 🎯 Native AVFoundation implementation using modern async/await
- 📊 Real-time progress reporting
- 🔧 TypeScript-first API with comprehensive types
- 🍏 App Store compliant (100% public Apple APIs)

**Quick-Win Features:**
- ✂️ Video trimming/cutting
- 📋 Metadata extraction (duration, dimensions, codecs)
- 🖼️ Thumbnail generation
- 🔊 Volume control/mute

**Platform Support:**
- macOS 11+ (Big Sur and later)
- React Native 0.68+
- Swift 5.0+

**Testing Status:**
- ✅ TypeScript compilation validated
- ✅ Core AVFoundation logic tested standalone
- ✅ Speed processing validated (metadata extraction, 2x speed)
- ⏳ Full React Native macOS integration testing ongoing

**Known Limitations:**
- macOS only (no iOS/Android support)
- Requires React Native macOS setup
- Beta status - please report issues!

**Installation:**
```bash
npm install react-native-macos-video-processor@beta
# or
yarn add react-native-macos-video-processor@beta
```

**Feedback Welcome:**
Please report any issues at: https://github.com/kiarashplusplus/React-Native-macOS-Video-Processor/issues

---

## Upcoming in 0.1.0 (stable)
- Full React Native integration validation
- Additional test coverage
- Performance benchmarks
- Community feedback incorporation

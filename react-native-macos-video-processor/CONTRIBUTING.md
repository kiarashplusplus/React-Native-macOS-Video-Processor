# Contributing to React Native macOS Video Processor

Thank you for your interest in contributing! This document provides setup instructions and development guidelines.

## Development Setup

### Prerequisites

- macOS 12.0 (Monterey) or later (Required for modern async/await AVFoundation APIs)
- Xcode 13+
- Node.js 18+
- Yarn (this project uses Yarn workspaces)
- CocoaPods

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kiarashplusplus/react-native-macos-video-processor.git
   cd react-native-macos-video-processor
   ```

2. **Install dependencies:**
   ```bash
   yarn install
   ```

3. **Set up the example app:**
   ```bash
   cd example
   yarn install
   ```

4. **For macOS development, you'll need to manually add macOS support:**
   - The library is structured for macOS but uses the `ios/` directory (React Native convention)
   - Native code is in `ios/VideoProcessor.swift` and `ios/VideoProcessor.m`

### Running the Example App

```bash
# From the root directory
yarn example macos
```

## Project Structure

```
react-native-macos-video-processor/
├── src/                      # TypeScript source code
│   ├── index.tsx            # Main API exports
│   ├── types.ts             # Type definitions
│   └── NativeVideoProcessor.ts  # Native module interface
├── ios/                      # macOS/iOS native code
│   ├── VideoProcessor.swift  # Swift implementation
│   └── VideoProcessor.m      # Objective-C bridge
├── example/                  # Example app
│   └── src/
│       └── App.tsx          # Example app UI
└── __tests__/               # Tests
```

## Development Workflow

### Making Changes

1. **TypeScript changes:** Edit files in `src/`
2. **Swift changes:** Edit files in `ios/`
3. **Example app:** Test your changes in `example/src/App.tsx`

### Building

```bash
# Build the library
yarn prepare

# Type checking
yarn typecheck

# Linting
yarn lint
```

### Testing

```bash
# Run tests
yarn test
```

## Code Style

- **TypeScript:** Follow ESLint + Prettier configuration
- **Swift:** Use standard Swift conventions
  - 2-space indentation
  - Modern async/await patterns
  - Comprehensive error handling

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and linting (`yarn test && yarn lint`)
5. Commit your changes using conventional commits
6. Push to your fork
7. Open a pull request

### Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test changes
- `chore:` Build/tooling changes

Example:
```bash
git commit -m "feat: add video reversal support"
git commit -m "fix: handle edge case in speed processing"
```

## Adding New Features

### 1. TypeScript API
Update `src/types.ts` and `src/index.tsx` with new types and functions.

### 2. Native Module Interface
Update `src/NativeVideoProcessor.ts` to declare new native methods.

### 3. Swift Implementation
Add implementation in `ios/VideoProcessor.swift`.

### 4. Objective-C Bridge
Expose new methods in `ios/VideoProcessor.m`.

### 5. Documentation
Update `README.md` with usage examples.

### 6. Example App
Add UI to test the new feature in `example/src/App.tsx`.

## Native Development Tips

### Swift/AVFoundation

- Use modern `async/await` patterns
- Load asset properties asynchronously: `try await asset.load(.duration)`
- Use `AVAssetExportSession` for exports
- Implement progress reporting via `Timer` or `AsyncSequence`

### Error Handling

- Map Swift errors to typed JavaScript errors
- Use the `VideoProcessorError` enum
- Provide clear, actionable error messages

### Performance

- Video processing is CPU/GPU intensive
- Use background threads for heavy operations
- Report progress frequently (every 0.1s recommended)

### React Native macOS Specifics

- **Main Queue Setup**: Always set `requiresMainQueueSetup` to `true` in your Swift module.
  ```swift
  override static func requiresMainQueueSetup() -> Bool {
      return true
  }
  ```
  *Reason: Initializing on a background thread can cause runtime crashes on macOS, even if the module logic is thread-safe.*

## Release Process

Releases are automated using `release-it`:

```bash
yarn release
```

This will:
1. Bump version in `package.json`
2. Generate changelog
3. Create git tag
4. Push to GitHub
5. Publish to npm (maintainers only)

## Questions?

- Open an issue for bugs or feature requests
- Contact: kiarasha@alum.mit.edu

## License

Apache-2.0 - see [LICENSE](LICENSE) for details.

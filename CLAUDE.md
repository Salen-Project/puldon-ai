# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**salen_fin** is a Flutter application targeting multiple platforms (iOS, macOS, Android, Linux, Windows, Web).

- **Flutter SDK**: 3.35.7 (stable channel)
- **Dart SDK**: ^3.9.2
- **Package Name**: salen_fin

This is currently a new Flutter project based on the default template with a single main.dart file.

## Common Commands

### Development
```bash
# Run the app (default device)
flutter run

# Run on specific device
flutter run -d macos
flutter run -d chrome
flutter run -d ios

# Hot reload: Press 'r' in the running app terminal
# Hot restart: Press 'R' in the running app terminal

# List available devices
flutter devices
```

### Building
```bash
# Build for macOS
flutter build macos

# Build for iOS
flutter build ios

# Build for web
flutter build web

# Build APK for Android
flutter build apk

# Build app bundle for Android
flutter build appbundle
```

### Testing
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format all Dart files
dart format .

# Format specific file
dart format lib/main.dart
```

### Dependencies
```bash
# Install dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Add a new package
flutter pub add package_name

# Add a dev dependency
flutter pub add --dev package_name
```

### Clean & Maintenance
```bash
# Clean build artifacts
flutter clean

# Clean and reinstall dependencies
flutter clean && flutter pub get

# Check Flutter installation
flutter doctor -v
```

## Project Structure

```
lib/
  main.dart           # App entry point with MyApp and MyHomePage widgets

test/
  widget_test.dart    # Widget tests

android/              # Android platform code
ios/                  # iOS platform code
macos/                # macOS platform code
linux/                # Linux platform code
windows/              # Windows platform code
web/                  # Web platform code
```

## Architecture Notes

Currently using the default Flutter template architecture:
- **main.dart**: Contains `main()`, `MyApp` (StatelessWidget), and `MyHomePage` (StatefulWidget with counter demo)
- **Material Design**: Using MaterialApp with Material 3 theming (ColorScheme.fromSeed)
- **State Management**: Basic setState() pattern (no state management library yet)

## Development Notes

### Platform Support
All platforms are configured:
- **iOS/macOS**: Xcode 26.1 available
- **Web**: Enabled
- **Android/Linux/Windows**: Configured but Android SDK not currently set up

### Linting
Uses `flutter_lints: ^5.0.0` with default recommended rules from `package:flutter_lints/flutter.yaml`.

### Dependencies
Minimal dependencies - only `cupertino_icons` for iOS-style icons.

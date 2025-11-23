# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Lich+** - A Vietnamese calendar iOS application built with SwiftUI. The app provides a calendar interface with support for Vietnamese lunar calendar, event management, task tracking, and AI assistant features. The project uses a tab-based navigation architecture and implements a comprehensive design system.

**Key Tech Stack:**
- iOS 17.0+ minimum deployment target
- SwiftUI for UI framework
- Swift 5.0
- CocoaPods for dependency management
- Xcode project structure with unit and UI test targets

## Development Workflow

### Essential Commands

**Building and Running:**
```bash
# Build the app for the iOS Simulator
xcodebuild -scheme lich-plus -destination 'generic/platform=iOS Simulator' build

# Build and run on the default simulator
xcodebuild -scheme lich-plus -destination 'generic/platform=iOS Simulator' -derivedDataPath ./build run

# Open in Xcode for interactive development
open lich-plus.xcodeproj
```

**Testing:**
```bash
# Run all unit tests
xcodebuild -scheme lich-plus -destination 'generic/platform=iOS Simulator' test

# Run tests with detailed output
xcodebuild -scheme lich-plus -destination 'generic/platform=iOS Simulator' test -verbose

# Run UI tests
xcodebuild -scheme lich-plus test-lich-plusUITests -destination 'generic/platform=iOS Simulator'
```

**Dependencies:**
```bash
# Install or update CocoaPods dependencies
pod install

# Update pod dependencies to latest compatible versions
pod update
```

### Development Setup

1. Ensure Xcode 15+ is installed
2. Run `pod install` to set up CocoaPods dependencies
3. Open the workspace (not the project file):
   ```bash
   open lich-plus.xcodeproj
   ```

Note: All git operations must be run from this directory (`lich-plus/`) or parent git worktree folders, not from the container directory above.

## Architecture & Code Organization

### High-Level Architecture

The app follows a tab-based navigation pattern with SwiftUI's `TabView` as the main navigation container. Each tab corresponds to a major feature area:

1. **Tab Navigation (ContentView.swift)** - Manages the four main tabs:
   - Calendar (Lịch) - Calendar view with Vietnamese lunar calendar support
   - Tasks (Việc) - Task/todo management
   - AI (AI) - AI assistant features
   - Settings (Cài đặt) - Application settings

2. **Design System (Theme.swift)** - Centralized color palette and spacing constants:
   - `AppColors` struct: Primary colors (red #C7251D), secondary colors (gray), event colors (orange, blue, yellow, pink), text colors, backgrounds
   - `AppTheme` struct: Spacing scale (2px to 24px), corner radius options, font sizes, opacity values

3. **App Entry Point (lich_plusApp.swift)** - Simple `@main` entry point that renders `ContentView` in a `WindowGroup`

### Feature Views

Each tab is implemented as a separate SwiftUI `View` file:

- **CalendarView.swift** - Month view with Vietnamese lunar calendar support (planned: event display, day selection)
- **TasksView.swift** - Task/todo management interface (placeholder with feature description)
- **AIView.swift** - AI assistant chat/features (placeholder with feature description)
- **SettingsView.swift** - Application settings and preferences

### Key Design Decisions

1. **Tab Bar Customization** - The `ContentView` applies custom appearance to `UITabBar` to match the design system (custom colors, fonts, padding)
2. **Navigation Stack** - Each view wraps its content in `NavigationStack` for hierarchical navigation capabilities
3. **Centralized Colors & Typography** - All colors and spacing values are defined in `Theme.swift` to maintain consistency and enable theming

## File Structure

```
lich-plus/
├── lich-plus/                      # Source code directory
│   ├── lich_plusApp.swift          # App entry point
│   ├── ContentView.swift           # Tab navigation container
│   ├── CalendarView.swift          # Calendar feature
│   ├── TasksView.swift             # Tasks feature
│   ├── AIView.swift                # AI assistant feature
│   ├── SettingsView.swift          # Settings feature
│   ├── Theme.swift                 # Design system (colors, spacing, typography)
│   └── Assets.xcassets             # Images and app icons
├── lich-plusTests/                 # Unit test target
├── lich-plusUITests/               # UI test target
├── lich-plus.xcodeproj             # Xcode project
├── Podfile                         # CocoaPods dependencies
└── Podfile.lock                    # Locked dependency versions
```

## Common Development Tasks

### Adding a New Feature View

1. Create a new file following the naming pattern: `[FeatureName]View.swift`
2. Implement as a `struct [FeatureName]View: View`
3. Use colors from `AppColors` and spacing from `AppTheme`
4. Add a `#Preview` block at the end for live preview support
5. If adding to tab navigation, add a `.tabItem` entry in `ContentView.swift`

### Modifying the Design System

- Update colors in the `AppColors` struct (with comments explaining RGB values)
- Update spacing/typography in the `AppTheme` struct
- Changes automatically apply throughout the app via the design system references

### Working with SwiftUI Previews

All views include `#Preview` blocks for Xcode canvas preview support. Use the Xcode canvas to iterate on UI without building.

## Testing

The project includes test targets for unit tests (`lich-plusTests`) and UI tests (`lich-plusUITests`). Tests can be run via Xcode or command line using the testing commands listed above.

## Deployment

iOS 17.0 is the minimum deployment target. The app uses SwiftUI exclusively without legacy UIKit patterns.

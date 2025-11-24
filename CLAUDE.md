# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Maintaining This Documentation

**IMPORTANT:** Keep this CLAUDE.md file in sync with actual project changes. This documentation is critical for future development and team collaboration.

### When to Update CLAUDE.md

Update this file in the **same commit** that introduces the change:

1. **Adding/Removing Feature Views** - Update `File Structure` and `Feature Views` sections
2. **Changing Tab Navigation** - Update `High-Level Architecture` and `Feature Views` sections
3. **Modifying Design System** - Update the `Design System (Theme.swift)` bullet point and `Modifying the Design System` section
4. **Adding Dependencies** - Update `Key Tech Stack` and `Dependencies` section in Development Workflow
5. **Changing Directory Structure** - Update `File Structure` section
6. **Updating Development Commands** - Update `Development Workflow` section with new commands or changes to existing ones
7. **Adding/Removing Test Targets** - Update `File Structure` and `Testing` sections
8. **New Features or Architecture Changes** - Update relevant sections in `Architecture & Code Organization` and `Common Development Tasks`

### Documentation Guidelines

- Keep the documentation high-level and focused on architecture, not implementation details
- Use file paths relative to the `lich-plus/` directory
- Include comments in code blocks explaining non-obvious commands
- Document design decisions and architectural patterns, not just what exists
- Maintain naming conventions in the documentation (use backticks for file names, code references)
- When describing views, include their purpose and planned features (if applicable)

### Validation Checklist

Before committing changes that modify the project:

- [ ] File structure section matches actual source files
- [ ] Feature view descriptions are accurate and current
- [ ] Architecture diagrams/descriptions reflect actual code organization
- [ ] Commands in Development Workflow are tested and correct
- [ ] Key Tech Stack version numbers match project configuration
- [ ] All referenced files and directories actually exist
- [ ] Localization guidelines match current string management approach

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
# Run all tests (unit and UI) using the test runner script
./run-tests.sh

# Run only unit tests
./run-tests.sh --unit

# Run only UI tests
./run-tests.sh --ui

# View test runner help
./run-tests.sh --help
```

Alternatively, run tests directly with xcodebuild:
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

The app follows a tab-based navigation pattern with SwiftUI's `TabView` as the main navigation container. Code is organized into functional layers:

1. **App Layer (`App/`)** - Entry point and main navigation:
   - `lich_plusApp.swift` - Main `@main` entry point that renders `ContentView` in a `WindowGroup`
   - `ContentView.swift` - Tab navigation container managing the four main tabs:
     - Calendar (Lịch) - Calendar view with Vietnamese lunar calendar support
     - Tasks (Việc) - Task/todo management
     - AI (AI) - AI assistant features
     - Settings (Cài đặt) - Application settings

2. **Core Layer (`Core/`)** - Shared design system:
   - `Theme.swift` - Centralized color palette and spacing constants:
     - `AppColors` struct: Primary colors (red #C7251D), secondary colors (gray), event colors (orange, blue, yellow, pink), text colors, backgrounds
     - `AppTheme` struct: Spacing scale (2px to 24px), corner radius options, font sizes, opacity values

3. **Features Layer (`Features/`)** - Feature-specific implementations:
   - Each feature has its own folder (e.g., `Calendar/`, `Tasks/`, `AI/`, `Settings/`)
   - Features are self-contained and can be developed independently
   - Each feature folder contains all view and utility code specific to that feature

### Feature Views

Each tab is implemented as a separate SwiftUI `View` file in its own feature folder:

- **Features/Calendar/CalendarView.swift** - Month view with Vietnamese lunar calendar support (planned: event display, day selection)
- **Features/Tasks/TasksView.swift** - Full-featured task and event management with date grouping, filtering, search, and inline editing
- **Features/AI/AIView.swift** - AI assistant chat/features (placeholder with feature description)
- **Features/Settings/SettingsView.swift** - Application settings and preferences

### Key Design Decisions

1. **Tab Bar Customization** - The `ContentView` applies custom appearance to `UITabBar` to match the design system (custom colors, fonts, padding)
2. **Navigation Stack** - Each view wraps its content in `NavigationStack` for hierarchical navigation capabilities
3. **Centralized Colors & Typography** - All colors and spacing values are defined in `Theme.swift` to maintain consistency and enable theming

## File Structure

```
lich-plus/
├── lich-plus/                      # Source code directory
│   ├── App/                        # App entry point and main navigation
│   │   ├── lich_plusApp.swift      # App entry point
│   │   └── ContentView.swift       # Tab navigation container
│   ├── Core/                       # Shared design system and utilities
│   │   └── Theme.swift             # Design system (colors, spacing, typography)
│   ├── Features/                   # Feature-specific code organized by domain
│   │   ├── Calendar/               # Calendar feature
│   │   │   └── CalendarView.swift
│   │   ├── Tasks/                  # Tasks feature
│   │   │   ├── Models/
│   │   │   │   └── TaskModels.swift    # Task, TaskCategory, RecurrenceType models
│   │   │   ├── Components/
│   │   │   │   ├── TaskListHeader.swift    # Header with search and add button
│   │   │   │   ├── TaskCard.swift          # Individual task display
│   │   │   │   ├── TaskSection.swift       # Date-grouped task section
│   │   │   │   ├── FilterBar.swift         # Date filter options
│   │   │   │   └── AddEditTaskSheet.swift  # Modal form for task creation/editing
│   │   │   └── TasksView.swift        # Main tasks view with search, filtering, and management
│   │   ├── AI/                     # AI assistant feature
│   │   │   └── AIView.swift
│   │   └── Settings/               # Settings feature
│   │       └── SettingsView.swift
│   ├── Localizable.xcstrings       # String catalog for localization (EN & VI)
│   └── Assets.xcassets             # Images and app icons
├── lich-plusTests/                 # Unit test target
├── lich-plusUITests/               # UI test target
├── lich-plus.xcodeproj             # Xcode project
├── Podfile                         # CocoaPods dependencies
└── Podfile.lock                    # Locked dependency versions
```

## Common Development Tasks

### Adding a New Feature View

1. Create a new folder under `Features/[FeatureName]/` (e.g., `Features/MyNewFeature/`)
2. Create the main view file: `[FeatureName]View.swift` inside the feature folder
3. Implement as a `struct [FeatureName]View: View`
4. Use colors from `AppColors` (via `Theme.swift`) and spacing from `AppTheme`
5. Add a `#Preview` block at the end for live preview support
6. If adding to tab navigation, add a `.tabItem` entry in `App/ContentView.swift`
7. For shared utilities specific to the feature, create additional files in the same feature folder

### Managing Localizable Strings

The app uses Xcode's **String Catalog** format (`Localizable.xcstrings`) for managing localized strings. Currently supported languages: English (en) and Vietnamese (vi).

**Workflow for adding new strings:**

1. **In Swift code**, use the `String(localized:)` initializer or reference localization keys directly:
   ```swift
   Label("tab.calendar", systemImage: "calendar")  // Uses key from string catalog
   Text(String(localized: "tab.calendar"))         // Alternative syntax
   ```

2. **Add string key to Localizable.xcstrings:**
   - Open `Localizable.xcstrings` in Xcode
   - Add a new key using dot-notation format: `feature.action` (e.g., `calendar.createEvent`, `tasks.addTask`)
   - Provide English translation in the "en" localization
   - Provide Vietnamese translation in the "vi" localization

3. **String catalog structure:**
   ```json
   {
     "your.key" : {
       "extractionState" : "manual",
       "localizations" : {
         "en" : {
           "stringUnit" : {
             "state" : "translated",
             "value" : "English translation"
           }
         },
         "vi" : {
           "stringUnit" : {
             "state" : "translated",
             "value" : "Vietnamese translation"
           }
         }
       }
     }
   }
   ```

4. **Key naming conventions:**
   - Use dot-notation for organization: `screen.component.text`
   - Tab items: `tab.featureName` (e.g., `tab.calendar`, `tab.tasks`)
   - Button/action labels: `feature.action` (e.g., `calendar.save`, `task.delete`)
   - Section titles: `feature.section` (e.g., `settings.general`)

**Syncing with code changes:**
- String catalog entries are manually managed (not auto-extracted from code)
- Always add translations for both EN and VI when adding new keys
- Xcode will show warnings for missing localizations if a key is referenced in code

### Modifying the Design System

- Update colors in the `AppColors` struct (with comments explaining RGB values)
- Update spacing/typography in the `AppTheme` struct
- Changes automatically apply throughout the app via the design system references

### Working with SwiftUI Previews

All views include `#Preview` blocks for Xcode canvas preview support. Use the Xcode canvas to iterate on UI without building.

### Working with the Tasks Feature

The Tasks feature implements a complete task and event management system with the following capabilities:

**Task Model (`TaskModels.swift`):**
- Core `Task` struct with UUID identification
- Properties: title, date, optional start/end times, category, notes, completion status, reminder settings, recurrence
- `TaskCategory` enum: work, personal, birthday, holiday, meeting, other
- `RecurrenceType` enum: none, daily, weekly, monthly, yearly

**Key Features:**
- **Task Grouping**: Automatically groups tasks by date (Today, Tomorrow, Upcoming)
- **Search**: Full-text search across task titles and notes
- **Filtering**: Filter by time period (All, This Week, This Month)
- **Quick Actions**: One-click task completion toggle without opening edit form
- **Category Indicators**: Color-coded visual indicators for task categories
- **Form Validation**: Title is required for new tasks
- **Responsive Design**: Adapts to different screen sizes using Theme.swift spacing

**Components Architecture:**
- `TaskListHeader`: Search bar and add button
- `TaskCard`: Displays individual task with checkbox and metadata
- `TaskSection`: Groups tasks by date range
- `FilterBar`: Horizontal scrollable filter options
- `AddEditTaskSheet`: Modal form with full task editing capabilities
- `TasksView`: Main container managing state and interactions

**Localization Keys** (all keys use `task.` prefix):
- UI labels: `myTasks`, `search`, `add`, `addNew`, `edit`, `delete`, `done`, `cancel`
- Date labels: `today`, `tomorrow`, `upcoming`
- Field labels: `title`, `date`, `time`, `startTime`, `endTime`, `reminder`, `recurrence`, `category`, `notes`
- Status: `completed`, `notCompleted`
- Filters: `all`, `thisWeek`, `thisMonth`
- Categories and reminders have their own key prefixes: `category.` and `reminder.`

## Testing

The project includes test targets for unit tests (`lich-plusTests`) and UI tests (`lich-plusUITests`). Tests can be run via Xcode or using the `run-tests.sh` command-line script.

**Using the Test Runner Script:**
The `run-tests.sh` script provides a convenient way to run tests with clean, formatted output:

```bash
# Run all tests (default)
./run-tests.sh

# Run only unit tests
./run-tests.sh --unit

# Run only UI tests
./run-tests.sh --ui

# Display help
./run-tests.sh --help
```

The script uses `xcbeautify` for formatted output and handles errors gracefully. It's the recommended approach for command-line test execution.

**Manual xcodebuild Commands:**
For more control, you can also run tests directly using the xcodebuild commands listed in the "Essential Commands" section above.

## Deployment

iOS 17.0 is the minimum deployment target. The app uses SwiftUI exclusively without legacy UIKit patterns.

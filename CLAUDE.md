# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Lịch Việt** - A production-ready Vietnamese calendar application built with SwiftUI. The app features:
- Monthly calendar view with Vietnamese lunar calendar support
- Event management (create, edit, delete)
- Day agenda with event timeline
- Color-coded event categories
- Full Vietnamese localization
- SwiftData persistence
- 30 comprehensive unit tests

## Project Structure

```
lich-plus/                          # Xcode project directory
├── lich-plus/                      # Main app source
│   ├── Models/
│   │   ├── CalendarEvent.swift     # SwiftData event model, sample data generation
│   │   ├── EventCategory.swift     # Event category enum, hex color conversion
│   │   └── LunarDateInfo.swift     # Lunar calendar date struct
│   │
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── CalendarCellView.swift       # Calendar day cell (solar + lunar)
│   │   │   ├── EventCardView.swift          # Event list card
│   │   │   ├── FloatingActionButton.swift   # FAB for new events
│   │   │   └── MonthYearPicker.swift        # Month navigation header
│   │   │
│   │   ├── MonthCalendarView.swift  # Month grid (7-col, 6-row)
│   │   ├── DayAgendaView.swift      # Day view with event list
│   │   ├── EventDetailView.swift    # Event details + edit/delete
│   │   ├── EventFormView.swift      # Event creation/editing form
│   │   └── MainView.swift           # Root TabView
│   │
│   ├── Utils/
│   │   └── LunarCalendarConverter.swift  # Solar to lunar conversion
│   │
│   └── lich_plusApp.swift           # App entry, SwiftData ModelContainer setup
│
├── lich-plusTests/                  # Unit tests
│   ├── CalendarEventTests.swift
│   ├── EventCategoryTests.swift
│   └── LunarCalendarConverterTests.swift
│
└── lich-plus.xcodeproj/             # Xcode project
```

## Build & Run Commands

### Build for Simulator
```bash
xcodebuild build -scheme lich-plus -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run on Simulator (from Xcode)
```bash
open lich-plus.xcodeproj
# Then Product → Run (Cmd+R) or select iPhone 15 simulator and press Play
```

### Run Unit Tests
```bash
xcodebuild test -scheme lich-plus -destination 'platform=iOS Simulator,name=iPhone 15'
# Or in Xcode: Product → Test (Cmd+U)
```

### Run Specific Test
```bash
xcodebuild test -scheme lich-plus -only-testing lich-plusTests/CalendarEventTests/testEventCreation
```

### Clean Build
```bash
xcodebuild clean -scheme lich-plus
```

## Key Technologies

- **UI Framework**: SwiftUI (modern declarative UI)
- **Data Persistence**: SwiftData (Apple's replacement for Core Data)
- **Testing**: XCTest (unit tests) + Swift Testing framework
- **Minimum iOS**: 17.0
- **Swift Version**: 5.0+

## Architecture Overview

### Data Flow
```
lich_plusApp (SwiftData ModelContainer)
    ↓
MainView (TabView)
    ├── MonthCalendarView (Month grid)
    │   ├── @Query for all events
    │   └── Tap date → DayAgendaView
    │
    ├── DayAgendaView (Day detail)
    │   ├── Filter events by date
    │   ├── Tap event → EventDetailView
    │   └── FAB → EventFormView
    │
    └── EventDetailView/EventFormView
        ├── Read/Write CalendarEvent
        ├── ModelContext operations
        └── Navigate back
```

### Key Architectural Patterns

1. **View Hierarchy**: TabView root with split navigation (MonthCalendarView → DayAgendaView → EventDetailView)
2. **SwiftData Integration**:
   - Single `ModelContainer` in `lich_plusApp.swift`
   - Views use `@Query` macro for automatic data fetching
   - `@Environment(\.modelContext)` for CRUD operations
3. **Component Reusability**:
   - `CalendarCellView` - reused for each calendar day
   - `EventCardView` - reused for event lists
   - `FloatingActionButton` - shared across views
4. **Sample Data**: Auto-loaded on first app launch via `CalendarEvent.createSampleEvents()`

## Important File Insights

### lich_plusApp.swift
- **Purpose**: App entry point, SwiftData schema setup
- **Key Code**: ModelContainer initialization with sample data injection
- **Modification**: Change SwiftData schema here if adding new models
- **Note**: Only `CalendarEvent` model persists; `EventCategory` is utility-only

### CalendarEvent.swift
- **Purpose**: Main SwiftData model for event persistence
- **Key Properties**: title, date, startTime, endTime, location, category, color, isAllDay
- **Sample Data**: `createSampleEvents()` generates 10 events for August 2024
- **Helpers**: Computed properties for date/time formatting in Vietnamese locale

### MonthCalendarView.swift
- **Purpose**: Core calendar display (month grid)
- **Layout**: LazyVGrid with 7 columns, 6 rows (42 days total)
- **Logic**: Fills previous/current/next month days appropriately
- **Navigation**: Tap day → navigate to DayAgendaView via NavigationStack

### EventFormView.swift
- **Purpose**: Create/edit event form
- **Features**: Date picker, time range, category, color selector
- **Validation**: Requires non-empty title
- **Data Save**: Uses ModelContext.insert() for new, direct property update for edit

### LunarCalendarConverter.swift
- **Purpose**: Solar to lunar date conversion
- **Current**: Simplified algorithm good for August 2024
- **Future**: Replace with dedicated lunar calendar library for full-year accuracy
- **Static Method**: `getLunarDate(for: Date) → LunarDateInfo`

## Common Development Tasks

### Add a New Event Category
1. Add case to `EventCategory.swift`
2. Assign color and Vietnamese name
3. Update `EventFormView.categories` array

### Modify Calendar Colors
1. Edit hex colors in `EventCategory.swift`
2. Colors used: #5BC0A6 (teal), #4A90E2 (blue), #50E3C2 (cyan), #F5A623 (orange), #D0021B (red), #F8E71C (yellow)

### Add Test for New Feature
1. Create test file in `lich-plusTests/`
2. Follow pattern from existing tests (CalendarEventTests.swift)
3. Run: `xcodebuild test -scheme lich-plus`

### Update Sample Data
1. Modify `CalendarEvent.createSampleEvents()` in `CalendarEvent.swift`
2. Data auto-loads on first app launch (checks if database empty)
3. To reset: Delete app from simulator or use "Erase All Content and Settings"

### Add New View/Screen
1. Create file in `Views/`
2. Make `@State` variables for navigation
3. Add NavigationStack/NavigationDestination for routing
4. Follow existing MainView → MonthCalendarView → DayAgendaView pattern

## Testing Strategy

- **Unit Tests**: 30 tests in `lich-plusTests/`
- **Coverage**: Models (CalendarEvent, EventCategory), utilities (LunarCalendarConverter)
- **Test File Organization**: One test file per model
- **Run All Tests**: `xcodebuild test -scheme lich-plus`

## SwiftUI/SwiftData Best Practices Used

1. **@Model for persistence**: CalendarEvent uses @Model macro
2. **@Query for reading**: Views auto-fetch with @Query private var events
3. **@Environment for context**: Access ModelContext via @Environment(\.modelContext)
4. **@State for local state**: Navigation, form inputs, selection
5. **Computed properties for formatting**: Date/time strings in correct locale
6. **Hex color extension**: Color(hex:) for custom colors

## Critical Notes

1. **iOS Deployment Target**: 17.0 (must match for SwiftData support)
2. **SwiftData Schema**: Only CalendarEvent in schema; EventCategory is non-persistent helper
3. **Simulator Requirement**: Must use physical device or simulator for full testing
4. **Sample Data**: Auto-loads on first launch; delete app to reset
5. **Lunar Calendar**: Simplified for August 2024; requires library upgrade for full year

## Git & Commits

When committing changes:
- Focus commits on specific features (e.g., "Add event deletion")
- Include tests with new functionality
- Update documentation if architecture changes
- Test before committing: `xcodebuild test -scheme lich-plus`

## Troubleshooting

**Build fails with "cannot convert value of type 'EventCategory.Type'"**
- EventCategory should NOT be in SwiftData schema (it's not @Model for persistence)
- Check lich_plusApp.swift has only CalendarEvent.self

**Tests won't run - simulator stuck in creation state**
- Restart Xcode or restart Mac
- Run: `xcrun simctl erase all` (warning: erases all simulators)

**Sample data not showing**
- Delete app from simulator and rebuild
- Sample data only loads if database is empty on first launch

**Dates showing in wrong locale**
- Verify DateFormatter locale is set to "vi_VN"
- Check CalendarEvent computed properties use correct locale

## Future Enhancements

- Replace LunarCalendarConverter with dedicated library for full-year accuracy
- Add recurring event UI (model infrastructure exists)
- Implement Google Calendar sync
- Add push notifications for event reminders
- Support WidgetKit for home screen widgets
- Dark mode theme support

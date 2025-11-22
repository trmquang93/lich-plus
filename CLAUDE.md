# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Lịch Việt** - A production-ready Vietnamese calendar application built with SwiftUI. The app features:
- Monthly calendar view with Vietnamese lunar calendar support
- 120+ lunar calendar events (Mùng 1 and Rằm) for 5 years (2024-2029)
- Customizable lunar event display with toggle settings
- Event management (create, edit, delete) with protection for system events
- Day agenda with event timeline and lunar date information
- Color-coded event categories
- Full Vietnamese localization
- SwiftData persistence for events
- UserDefaults persistence for settings
- 78+ comprehensive unit tests

## Project Structure

```
lich-plus/                       # Xcode project directory
    ├── lich-plus/                   # Main app source
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
    ├── lich-plusTests/                  # Unit tests (78+ tests)
    │   ├── CalendarEventTests.swift           # 8 tests: event creation, properties, sample data
    │   ├── EventCategoryTests.swift           # 8 tests: categories, color conversion
    │   ├── LunarCalendarConverterTests.swift # 37 tests: lunar conversion, leap months, edge cases
    │   ├── SettingsViewTests.swift            # 8 tests: UserDefaults persistence, toggle behavior
    │   ├── EventFilteringTests.swift          # 17 tests: Rằm/Mùng 1 filtering, combined filters
    │   └── EventProtectionTests.swift         # 16 tests: system event protection, UI behavior
    │
    ├── lich-plusUITests/                # UI tests
    │
    └── lich-plus.xcodeproj/             # Xcode project file
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
- **Purpose**: Main SwiftData model for event persistence with lunar event generation
- **Key Properties**:
  - title, date, startTime, endTime, location, category, color, isAllDay
  - `isRecurring` (repurposed as system event flag for lunar events)
  - `recurringType` (reserved for future recurring event feature)
- **Sample Data**: `createSampleEvents()` generates 10 events for August 2024
- **Lunar Events**: `createLunarEvents()` generates ~120-130 Mùng 1 and Rằm events for 5 years
  - Handles leap months correctly (e.g., "5 nhuận")
  - Events marked with isRecurring=true (protected from editing/deletion)
  - Covers 2024-2029 with accurate lunar-to-solar conversion
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

- **Unit Tests**: 78+ comprehensive tests in `lich-plusTests/`
- **Test Coverage**:
  - **CalendarEvent**: 8 tests (event creation, properties, sample data generation)
  - **EventCategory**: 8 tests (color conversion, predefined categories, invalid hex handling)
  - **LunarCalendarConverter**: 37 tests (lunar conversion, leap months, edge cases, date boundaries)
  - **Settings**: 8 tests (UserDefaults persistence, toggle independence, app restart simulation)
  - **Event Filtering**: 17 tests (Rằm/Mùng 1 filtering, combined filters, user event visibility)
  - **Event Protection**: 16 tests (system event protection, UI button visibility, lock icons)
- **Test Organization**: Separate test file for each feature with detailed docstring comments
- **Run All Tests**: `xcodebuild test -scheme lich-plus -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Run Specific Test**: `xcodebuild test -scheme lich-plus -only-testing lich-plusTests/CalendarEventTests`

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
3. **Lunar Events**:
   - Generated on first app launch (~130 events for 5 years)
   - Marked with isRecurring=true (system events, cannot be edited/deleted)
   - Covers 2024-2029 using lookup table (replace with library by 2029)
   - Handles leap months correctly (identified with "nhuận" suffix)
4. **Settings Persistence**: Using UserDefaults for toggle states
   - `showRamEvents` (default: true) - shows/hides Rằm events
   - `showMung1Events` (default: true) - shows/hides Mùng 1 events
   - Settings persist across app restarts
5. **Event Protection**:
   - System events (isRecurring=true): no edit/delete, lock icon shown
   - User events (isRecurring=false): full edit/delete capabilities
6. **Sample Data**: Auto-loads on first launch; delete app to reset

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

**Sample data not showing**
- Delete app from simulator and rebuild
- Sample data only loads if database is empty on first launch

**Dates showing in wrong locale**
- Verify DateFormatter locale is set to "vi_VN"
- Check CalendarEvent computed properties use correct locale

## Phase 6: Lunar Monthly Events Feature (Complete)

### Feature Summary
The Lunar Monthly Events feature adds 120+ lunar calendar events to the application, providing users with important Vietnamese lunar calendar dates.

### Key Implementations

1. **Lunar Event Generation** (CalendarEvent.createLunarEvents)
   - Generates Mùng 1 (New Moon) and Rằm (Full Moon) events
   - Covers 5 years (2024-2029) with accurate lunar-to-solar conversion
   - Properly handles leap months (nhuận months)
   - System events marked with isRecurring=true

2. **Settings Integration** (SettingsView + UserDefaults)
   - Toggle to show/hide Rằm events
   - Toggle to show/hide Mùng 1 events
   - Independent toggles with immediate visual feedback
   - Settings persist across app restarts

3. **Event Filtering** (View layer)
   - Filters events based on toggle settings
   - User events always visible regardless of toggles
   - Accurate substring matching for "Rằm" and "Mùng 1"
   - Leap month events correctly identified

4. **Event Protection** (UI + Logic)
   - System events cannot be edited or deleted
   - Lock icon displayed on system events
   - Edit/delete buttons hidden for system events
   - User events fully editable

5. **Color Extension Fix**
   - Fixed Color(hex:) initializer to properly validate hex string length
   - Now correctly rejects invalid hex colors (e.g., "#12", "INVALID")

### Test Coverage
- 78+ unit tests covering all feature aspects
- Integration scenarios: first launch, settings persistence, filtering, protection
- Edge cases: leap months, date boundaries, similar titles
- Performance: launch time, filtering responsiveness

### Code Quality
- Comprehensive documentation added to all major methods
- Clear inline comments explaining complex logic
- Proper error handling and validation
- Follows project conventions and SwiftUI best practices

## Future Enhancements

- Replace LunarCalendarConverter with dedicated library (e.g., VietnameseLunar-ios) for full-year accuracy beyond 2029
- Add recurring event UI and management
- Implement Google Calendar sync
- Add push notifications for event reminders
- Support WidgetKit for home screen widgets
- Dark mode theme support
- Localization for English and other languages

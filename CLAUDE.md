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

**Building:**
```bash
# Build the app and check for compile errors
./build-app.sh

# Clean build folder first, then build
./build-app.sh --clean

# View build script help
./build-app.sh --help
```

**Testing:**
Use the script with `grep -E "✖"` to filter for failed tests.
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
│   │   │   ├── Components/
│   │   │   │   ├── CalendarHeaderView.swift      # Header with month/year navigation and picker
│   │   │   │   ├── MonthPickerView.swift         # Apple Calendar-style month picker (3x4 grid, swipe navigation)
│   │   │   │   ├── CalendarGridView.swift        # Calendar day grid display
│   │   │   │   ├── QuickInfoBannerView.swift     # Quick astrological info banner
│   │   │   │   ├── DayDetailView.swift           # Detailed day view with astrological data
│   │   │   │   └── EventsListView.swift          # Events display for selected day
│   │   │   ├── Managers/
│   │   │   │   └── CalendarDataManager.swift     # Calendar data and month navigation
│   │   │   ├── Models/
│   │   │   │   └── CalendarModels.swift          # Calendar, CalendarDay, CalendarMonth models
│   │   │   ├── Utilities/
│   │   │   │   ├── HoangDaoCalculator.swift      # 12 Trực (zodiac hours) and day quality calculation
│   │   │   │   ├── CanChiCalculator.swift        # Can-Chi calculation for date components
│   │   │   │   ├── LucHacDaoCalculator.swift     # Lục Hắc Đạo (unlucky days) detection
│   │   │   │   ├── StarCalculator.swift          # Star data retrieval and scoring
│   │   │   │   └── AstrologyData.swift           # Special festival dates and astrological data
│   │   │   ├── Data/
│   │   │   │   ├── Month1StarData.swift through Month12StarData.swift  # Star data for all 12 months
│   │   │   │   └── StarModels.swift              # Good and bad star enums and data structures
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

### Working with the Calendar Month Picker

The Calendar feature includes an Apple Calendar-style month picker for quick month/year navigation:

**MonthPickerView (`MonthPickerView.swift`):**
- 3x4 grid layout displaying all 12 months with abbreviated labels (Th.1 through Th.12)
- Year navigation with left/right chevron buttons
- Year range bounds: 1900-2100
- Vertical swipe gesture support: swipe up = next year, swipe down = previous year
- Three visual states for months:
  - Current month (today): Red background (AppColors.primary) with white text
  - Selected month (from selectedDate): Light red background (AppColors.backgroundLight)
  - Other months: Default text on transparent background
- Bottom "Done" button to dismiss the picker

**Integration (`CalendarHeaderView.swift`):**
- Month/year text is tappable to open the month picker as a bottom sheet
- Sheet presentation with `.medium` and `.large` detents
- Optional callback `onMonthSelected: ((Int, Int) -> Void)?` for month selection handling

**Data Manager (`CalendarDataManager.swift`):**
- New method: `goToMonth(_ month: Int, year: Int)`
  - Creates a date for the first day of the specified month/year
  - Regenerates the calendar month using `generateCalendarMonth()`
  - Clears the selected day (to force re-selection in new month)
  - Handles invalid date components gracefully

**Usage Example:**
```swift
// In CalendarView
CalendarHeaderView(
    selectedDate: .constant(Date()),
    onPreviousMonth: { dataManager.goToPreviousMonth() },
    onNextMonth: { dataManager.goToNextMonth() },
    onMonthSelected: { month, year in
        dataManager.goToMonth(month, year: year)
    }
)
```

**Design System Integration:**
- Colors: AppColors.primary, AppColors.backgroundLight, AppColors.textPrimary
- Spacing: AppTheme.spacing8, AppTheme.spacing12, AppTheme.spacing16
- Typography: AppTheme.fontBody, AppTheme.fontTitle2, AppTheme.fontTitle3
- Corner radius: AppTheme.cornerRadiusMedium, AppTheme.cornerRadiusLarge

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

### Working with Vietnamese Astrology (Hoàng Đạo & 12 Trực)

The Calendar feature includes traditional Vietnamese astrology calculations for determining auspicious and inauspicious days:

**Core Calculation Components:**

1. **12 Trực (Zodiac Hours)** - `HoangDaoCalculator.swift`
   - Calculates one of 12 zodiac hours (Kiến, Trừ, Mãn, Bình, Định, Chấp, Phá, Nguy, Thành, Thu, Khai, Bế) for each lunar day
   - Uses the "Tháng nào trực nấy" principle: Each lunar month has a base offset determining how the 12 Trực cycle through days
   - Formula: `Trực = (monthOffset + dayOfMonth - 1) % 12`
   - Month offsets follow a cyclic pattern: [9, 2, 7, 0, 5, 10, 3, 8, 1, 6, 11, 4] for months 1-12
   - Includes helper function `getMonthChi()` mapping each month to its corresponding Chi (Earthly Branch)

2. **Lục Hắc Đạo (6 Unlucky Days)** - `LucHacDaoCalculator.swift`
   - Detects specific inauspicious day types based on lunar month and day Chi
   - Examples: Thiên Lao (Heavenly Prison), Câu Trần (Hook of Dust), Chu Tước (Pearl Pelican)
   - Each unlucky day type has associated severity and activity restrictions

3. **Special Festival Dates** - `AstrologyData.swift`
   - Only specific festival dates (Tết, Mid-Autumn, etc.) override normal 12 Trực calculation
   - Generic first/15th days of month use the standard 12 Trực formula
   - Festival dates defined: (1,1), (1,15), (3,3), (5,5), (7,15), (8,15), (10,10)

**Day Quality Calculation** - `HoangDaoCalculator.determineDayQuality()`
- Combines 12 Trực and Lục Hắc Đạo to produce overall day rating
- Weighted scoring system: Auspicious hours (2.0 points), Unlucky days (-2.0 to -2.5 points)
- Result categories: Good (score > 0), Bad (score < 0), Neutral (score ≈ 0)
- Includes lucky directions, colors, and suitable/taboo activities

**Key Data Structures:**
- `ZodiacHourType`: Enum for 12 Trực with quality classification (veryAuspicious, neutral, inauspicious)
- `DayQuality`: Complete astrological data including Trực, unlucky day type, activities
- `HourlyZodiac`: Auspicious hours within a day with time ranges and activities

**References:**
- Based on Vietnamese astrology sources: vansu.net, phongthuytuongminh.com, xemngay.com
- Uses lunar-solar calendar conversion via `LunarCalendar` utility (VietnameseLunar library)
- Can-Chi calculation via `CanChiCalculator` for day/month/hour Can-Chi pairs

### Working with Star System (Sao Tốt/Sao Xấu)

The Calendar feature includes a comprehensive star system for all 12 lunar months, based on traditional Vietnamese astrology.

**Implementation Status:**
- ✅ **All 12 months implemented** (720/720 Can-Chi combinations)
- ✅ **Complete structural coverage** for entire year
- ✅ **42 stars in enums** (12 good + 30 bad stars)
- ✅ **Integrated with day quality** calculations

**Star Data Files:**
```
Features/Calendar/Data/
├── Month1StarData.swift  (60 Can-Chi entries)
├── Month2StarData.swift  (60 Can-Chi entries)
├── Month3StarData.swift  (60 Can-Chi entries)
├── Month4StarData.swift  (60 Can-Chi entries)
├── Month5StarData.swift  (60 Can-Chi entries)
├── Month6StarData.swift  (60 Can-Chi entries)
├── Month7StarData.swift  (60 Can-Chi entries - partial star data)
├── Month8StarData.swift  (60 Can-Chi entries - partial star data)
├── Month9StarData.swift  (60 Can-Chi entries - detailed)
├── Month10StarData.swift (60 Can-Chi entries - detailed)
├── Month11StarData.swift (60 Can-Chi entries - detailed)
└── Month12StarData.swift (60 Can-Chi entries - detailed)
```

**Star Models (`StarModels.swift`):**
- `GoodStar` enum: 12 auspicious stars (e.g., Thiên ân, Sát công, Trực linh)
- `ExtendedBadStar` enum: 30 inauspicious stars (e.g., Ly sào, Hỏa tinh, Đại hao)
- `DayStarData` struct: Holds stars for a specific Can-Chi combination
- `MonthStarData` struct: Organizes all 60 entries per month

**Star Calculator (`StarCalculator.swift`):**
- `detectStars()`: Returns star data for any lunar date
- `calculateStarScore()`: Computes weighted score from stars
- Supports all 12 months via switch statement

**Day Quality Formula:**
```
Final Score = 12 Trực base score
            + Lục Hắc Đạo penalty
            + Star system score

Result: GOOD | NEUTRAL | BAD
```

**Data Quality by Month:**
- **Months 9-12**: Detailed star extraction from book (33% coverage)
- **Months 7-8**: Partial star data with key stars identified (17% coverage)
- **Months 1-6**: Complete structure, ready for enhancement (50% coverage)

### Validation & Accuracy Metrics

**Current System Accuracy**: Validated against xemngay.com

**Component-Level Accuracy**:
- **Tier 1 (Critical): 100%** (40/40 checks)
  - Day/Month/Year Can-Chi calculation
  - 12 Trực (zodiac hour) determination
- **Tier 2 (Important): 100%** (20/20 checks)
  - Lucky hours (Giờ Hoàng Đạo): Fixed via book pages 51-52
  - Lục Hắc Đạo (unlucky days): Complete detection rules
- **Tier 3 (Enhanced): 45%** (Informational only)
  - Star names: Limited by incomplete data for months 1-6
  - Quality ratings: Subject to source variations

**xemngay.com Validation**:
- URL format: `https://xemngay.com/Default.aspx?blog=xngay&d=DDMMYYYY`
- Example: `https://xemngay.com/Default.aspx?blog=xngay&d=24112025`
- Test suite: 10 strategic dates across 7 lunar months
- Test location: `lich-plusTests/VietnameseCalendarTests.swift` lines 856-1039

**Latest Fixes** (achieving 100% Tier 2):
- Lucky hours: Corrected Dần/Thân Chi mapping [0,1,4,5,7,10]
- Unlucky days: Added Bạch Hổ (M3+Tuất), Câu Trận (M1+Hợi), Thiên Lao (M7+Thân)
- Naming: Standardized with "Hắc Đạo" suffix for consistency

### Reference Book & Verification Tools

**IMPORTANT:** When working on calendar logic or verifying accuracy, use the reference book and extraction tools.

**Source Book:**
- **Title**: Lich Van Nien 2005-2009 (Vietnamese Perpetual Calendar)
- **Location**: `lich-van-nien.pdf` in project root
- **Coverage**: All 12 lunar months, 720 Can-Chi combinations
- **Total Pages**: 193
- **Star Data Pages**: 104-175 (72 pages total, 6 pages per month)

**Page Mapping (from official book index, pages 188-191):**
```
Month 1 (Gieng):  Pages 104-109 (6 pages)
Month 2:          Pages 110-115 (6 pages)
Month 3:          Pages 116-121 (6 pages)
Month 4:          Pages 122-127 (6 pages)
Month 5:          Pages 128-133 (6 pages)
Month 6:          Pages 134-139 (6 pages)
Month 7:          Pages 140-145 (6 pages)
Month 8:          Pages 146-151 (6 pages)
Month 9:          Pages 152-157 (6 pages)
Month 10:         Pages 158-163 (6 pages)
Month 11:         Pages 164-169 (6 pages)
Month 12 (Chap):  Pages 170-175 (6 pages)

Key Reference Pages:
- 12 Truc System: Pages 48-49
- Hoang Dao/Hac Dao: Pages 50-52
- Good Stars by Month: Pages 60-63
- Bad Stars by Month: Pages 64-67
- Star Quality Tables: Pages 77-91
- Book Index: Pages 188-191
```

**Book Folder Structure:**
All 193 pages are extracted to `book/pages/` with consistent naming:
```
book/
├── pages/              # All 193 extracted pages
│   ├── page_0001.jpg   # Cover
│   ├── page_0002.jpg
│   ├── ...
│   └── page_0193.jpg   # Back cover
└── BOOK_INDEX.md       # Complete table of contents
```

**PDF Extraction Tools:**

1. **Quick extraction by month:**
   ```bash
   # Extract pages for a specific lunar month
   ./extract_book_pages.sh lich-van-nien.pdf <month_number>

   # Example: Extract Month 5 pages (128-133) to book/extract/month_05
   ./extract_book_pages.sh lich-van-nien.pdf 5

   # Extract special sections
   ./extract_book_pages.sh lich-van-nien.pdf hoangdao  # Pages 50-52
   ./extract_book_pages.sh lich-van-nien.pdf 12truc    # Pages 48-49
   ./extract_book_pages.sh lich-van-nien.pdf stars     # Pages 77-91
   ```

2. **Custom page extraction:**
   ```bash
   # Extract specific page range
   ./pdf_to_images.py lich-van-nien.pdf --pages 128-133 --output ./temp_extract

   # Extract with high quality (300 DPI)
   ./pdf_to_images.py lich-van-nien.pdf --pages 50-52 --dpi 300 --output ./temp_extract

   # View help
   ./pdf_to_images.py --help
   ```

3. **View full book index:**
   ```bash
   cat book/BOOK_INDEX.md
   ```

**Verification Workflow:**

When you encounter issues with calendar logic or star calculations:

1. **Identify the date** and its lunar month/day Can-Chi
2. **Extract the relevant book pages:**
   ```bash
   ./extract_book_pages.sh lich-van-nien.pdf <lunar_month>
   ```
3. **Read the extracted images** to verify:
   - Can-Chi combinations (Column A)
   - Bad stars (Column B - Sao xấu)
   - Good stars (Column C - Sao tốt)
4. **Compare with code:**
   - Check `Features/Calendar/Data/Month<X>StarData.swift`
   - Verify star mappings in `StarModels.swift`
5. **Update if needed:**
   - Add missing stars to enums (if not present)
   - Update star data entries
   - Run tests to verify

**Example Verification:**

```swift
// Problem: Day quality seems incorrect for Nov 3, 2025
// Step 1: Identify lunar date
let date = Date(year: 2025, month: 11, day: 3)
// Result: Lunar 14/09/2025, Can-Chi: Binh Ty

// Step 2: Look up in book/pages/ (Month 9 = pages 152-157)
// Or extract fresh: ./extract_book_pages.sh lich-van-nien.pdf 9

// Step 3: Read page_0152.jpg onwards - find Row: Binh Ty
// Book shows:
// - Good: Thien an, Truc linh
// - Bad: Hoa tai, Thien hoa, Tho on, Hoang sa, Phi ma sat, Ngu quy, Qua tu

// Step 4: Verify in Month9StarData.swift
// Should match the book exactly

// Step 5: If mismatch, update the data and test
```

**Enhancement Opportunities:**

To improve star data accuracy for Months 1-6:
1. Extract pages using tools above
2. Read images and identify all stars
3. Add new stars to `StarModels.swift` enums if needed
4. Update `Month<X>StarData.swift` with complete data
5. Assign appropriate scores based on star meanings
6. Run tests: `./run-tests.sh --unit`

**Cross-Reference:**
- Book pages (ground truth)
- xemngay.com (online validation)
- vansu.net (traditional meanings)

**Note for Future Work:**
The book PDF and extraction tools are the authoritative source for verifying calendar logic. Always consult the book when:
- Debugging day quality calculations
- Validating star presence/absence
- Adding new calendar features
- Resolving user-reported accuracy issues

## Deployment

iOS 17.0 is the minimum deployment target. The app uses SwiftUI exclusively without legacy UIKit patterns.

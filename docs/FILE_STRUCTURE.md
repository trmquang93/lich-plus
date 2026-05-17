# File Structure

```
lich-plus/                          # Container directory (CLAUDE.md lives here)
└── lich-plus/                      # Xcode project root (git repo)
    ├── lich-plus/                  # Source code
    │   ├── App/                    # Entry point + tab navigation
    │   │   ├── lich_plusApp.swift
    │   │   └── ContentView.swift
    │   ├── Core/
    │   │   ├── Theme.swift         # Design system
    │   │   ├── Components/         # FlowLayout, ParallaxScrollView, etc.
    │   │   ├── Services/           # Sync services (Apple/Google/MS/ICS), recurrence
    │   │   └── Extensions/         # e.g. Notification+Calendar
    │   ├── Features/
    │   │   ├── Calendar/           # CalendarView + Components/Managers/Models/Utilities/Data
    │   │   ├── Tasks/              # TasksView + Components/Models
    │   │   ├── AI/                 # AIView
    │   │   └── Settings/           # SettingsView
    │   ├── Localizable.xcstrings   # String catalog (en, vi)
    │   └── Assets.xcassets
    ├── lich-plusTests/             # Unit tests
    ├── lich-plusUITests/           # UI tests
    ├── lich-plus.xcodeproj
    ├── lich-plus.xcworkspace       # Open this, not the project
    ├── Podfile / Podfile.lock
    └── docs/                       # Extended documentation
```

Key Core/Services files: `AutoSyncCoordinator`, `BackgroundSyncManager`, `CalendarSyncService`, `EventKitService`, `GoogleCalendarService(+SyncService)`, `MicrosoftCalendarService(+SyncService)`, `ICSCalendarService(+SyncService)`, `LunarOccurrenceGenerator`, `RecurrenceMatcher`, `RecurrenceRuleContainer`, `SerializableLunarRecurrenceRule`.

Key Calendar utilities: `HoangDaoCalculator`, `CanChiCalculator`, `LucHacDaoCalculator`, `StarCalculator`, `AstrologyData`. Star data: `Month1StarData.swift` … `Month12StarData.swift`, plus `StarModels.swift`.

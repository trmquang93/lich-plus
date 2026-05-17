# Reusable Components

## ParallaxScrollView (`Core/Components/ParallaxScrollView.swift`)

Generic collapsible-header parallax scroll. Header closure receives `(height, collapseProgress)`. Props: `minHeaderHeight`, `maxHeaderHeight`, `header`, `content`. Coordinate space: `"scrollView"`. Apply `.clipped()` on header to prevent overflow.

```swift
ParallaxScrollView(minHeaderHeight: 100, maxHeaderHeight: 300,
    header: { height, progress in /* fade by progress */ },
    content: { /* list */ })
```

## FlowLayout (`Core/Components/FlowLayout.swift`)

Native SwiftUI `Layout` (iOS 16+). Left-to-right rows with auto-wrap. Props: `spacing` (default 8), `alignment` (`.leading`/`.center`/`.trailing`). Used for tag chips, tone buttons, filter groups.

## MonthPickerView (`Features/Calendar/Components/MonthPickerView.swift`)

Apple Calendar-style 3x4 month grid. Year range 1900-2100. Vertical swipe = year change. States: today (red bg), selected (light red bg), default. Triggered from `CalendarHeaderView` via tap on month/year text — opens as `.medium`/`.large` sheet.

`CalendarDataManager.goToMonth(_:year:)` jumps to a month and clears selected day.

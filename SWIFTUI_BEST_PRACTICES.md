# SwiftUI Best Practices for Lich+ Project

This document outlines SwiftUI best practices and patterns for developers working on the Lich+ iOS app.

## Table of Contents

1. [Sheet Presentation Patterns](#sheet-presentation-patterns)
2. [State Management](#state-management)
3. [Navigation Patterns](#navigation-patterns)
4. [Performance Optimization](#performance-optimization)
5. [Common Pitfalls](#common-pitfalls)

---

## Sheet Presentation Patterns

### Use `sheet(item:)` for Optional-Based Sheets

When presenting a sheet that displays details of an optional item, **always use `sheet(item:)`** instead of `sheet(isPresented:)`.

**Correct Pattern:**
```swift
@State private var selectedEvent: SyncableEvent?

.sheet(item: $selectedEvent) { event in
    EventDetailView(event: event)
}
```

**Avoid This Pattern:**
```swift
// DON'T: Two state variables that must be manually synchronized
@State private var selectedEvent: SyncableEvent?
@State private var showSheet = false

.sheet(isPresented: $showSheet) {
    if let event = selectedEvent {
        EventDetailView(event: event)
    }
}
```

**Why `sheet(item:)` is Better:**

| Aspect | `sheet(item:)` | `sheet(isPresented:)` |
|--------|----------------|----------------------|
| State variables | 1 | 2 |
| Manual sync needed | No | Yes |
| Swipe-dismiss handling | Automatic | Manual |
| Race conditions | Impossible | Possible |
| Code complexity | Simple | Complex |

**Real Example from Issue #25:**

The original implementation used `sheet(isPresented:)` with `onChange` to sync state:
```swift
// BAD: Race condition on first tap, swipe-dismiss bug
@State private var editingEvent: SyncableEvent?
@State private var showEditSheet = false

.sheet(isPresented: $showEditSheet) {
    if let event = editingEvent {
        CreateItemSheet(editingEvent: event, ...)
    }
}
.onChange(of: editingEvent) { _, newValue in
    if newValue != nil {
        showEditSheet = true
    }
}
```

The fix uses `sheet(item:)`:
```swift
// GOOD: No race conditions, automatic dismiss handling
@State private var editingEvent: SyncableEvent?

.sheet(item: $editingEvent) { event in
    CreateItemSheet(editingEvent: event, ...)
}
```

### When to Use Each Pattern

| Use Case | Pattern |
|----------|---------|
| Sheet with optional data | `sheet(item:)` |
| Simple toggle sheet (no data) | `sheet(isPresented:)` |
| Multiple sheet types | `sheet(item:)` with enum |

---

## State Management

### Single Source of Truth

Never derive state that can be computed. If `showSheet` is always `true` when `selectedItem != nil`, you only need `selectedItem`.

**Correct:**
```swift
@State private var selectedItem: Item?
// Sheet visibility is derived from selectedItem being non-nil
```

**Avoid:**
```swift
@State private var selectedItem: Item?
@State private var showSheet = false  // Redundant!
```

### State Placement

| State Type | Placement |
|------------|-----------|
| UI-only state (expanded, selected) | `@State` in View |
| Shared across views | `@StateObject` / `@EnvironmentObject` |
| Persisted data | SwiftData `@Query` |

### Avoid State Synchronization

If you find yourself using `onChange` to keep two state variables in sync, you likely have a design problem. Look for:
- Derived state that can be computed
- A single source of truth that can replace both variables
- SwiftUI modifiers designed for your use case (like `sheet(item:)`)

---

## Navigation Patterns

### Use `navigationDestination(item:)` for Optional Navigation

Similar to sheets, use the item-based variant for navigation:

```swift
@State private var selectedDate: Date?

.navigationDestination(item: $selectedDate) { date in
    DayDetailView(date: date)
}
```

### Tab-Based Navigation

The app uses `TabView` as the main navigation container. Each tab should:
- Wrap content in its own `NavigationStack`
- Manage its own navigation state
- Not interfere with other tabs' navigation

```swift
TabView {
    NavigationStack {
        CalendarView()
    }
    .tabItem { Label("Calendar", systemImage: "calendar") }

    NavigationStack {
        TasksView()
    }
    .tabItem { Label("Tasks", systemImage: "checklist") }
}
```

---

## Performance Optimization

### Minimize State Updates During Scroll

Use threshold-based updates instead of continuous updates:

```swift
// GOOD: Update only at thresholds
.onChange(of: progress) { _, newProgress in
    if newProgress >= 0.9 && collapseProgress < 0.9 {
        collapseProgress = 1.0
    } else if newProgress < 0.1 && collapseProgress >= 0.1 {
        collapseProgress = 0.0
    }
}

// BAD: Updates on every scroll position change
.onChange(of: progress) { _, newProgress in
    collapseProgress = newProgress  // Causes constant re-renders
}
```

### Use `@Query` Efficiently

SwiftData queries should be as specific as possible:

```swift
// GOOD: Filtered query
@Query(
    filter: #Predicate<SyncableEvent> { !$0.isDeleted },
    sort: \.startDate
)
private var events: [SyncableEvent]

// BAD: Fetch all, filter in view
@Query private var allEvents: [SyncableEvent]
var events: [SyncableEvent] {
    allEvents.filter { !$0.isDeleted }  // Computed on every render
}
```

### Avoid Expensive Computations in Body

Move expensive calculations outside the view body:

```swift
// GOOD: Computed property with caching consideration
private var filteredTasks: [TaskItem] {
    tasks.filter { ... }
}

var body: some View {
    List(filteredTasks) { task in ... }
}
```

---

## Common Pitfalls

### 1. Race Conditions with Multiple State Updates

**Problem:** Setting multiple state variables in sequence can cause race conditions.

```swift
// BAD: Race condition
func selectItem(_ item: Item) {
    selectedItem = item
    showSheet = true  // Sheet may render before selectedItem propagates
}
```

**Solution:** Use single state variable or `onChange`.

### 2. Forgetting `@MainActor` for SwiftData Services

All services interacting with SwiftData must be on the main actor:

```swift
@MainActor
final class CalendarSyncService {
    private let modelContext: ModelContext
    // ...
}
```

### 3. Not Handling Sheet Dismissal

When using `sheet(isPresented:)`, always handle all dismissal paths:
- Save/Done button
- Cancel button
- Swipe-to-dismiss
- Tap outside (on iPad)

With `sheet(item:)`, this is handled automatically.

### 4. Using `try?` Without Feedback

Silent error handling leaves users confused:

```swift
// BAD: User sees nothing on error
if let result = try? fetch() { ... }

// GOOD: Provide feedback
do {
    let result = try fetch()
    // handle success
} catch {
    print("Fetch error: \(error)")
    showErrorAlert = true
}
```

### 5. Capturing Self in Closures

Be careful with closure captures in long-lived contexts:

```swift
// Check for potential retain cycles
.sheet(item: $selectedEvent) { event in
    EventView(
        event: event,
        onSave: { [weak self] in  // Use weak if needed
            self?.selectedEvent = nil
        }
    )
}
```

---

## Project-Specific Patterns

### Design System Usage

Always use the design system from `Theme.swift`:

```swift
// GOOD
Text("Title")
    .foregroundColor(AppColors.textPrimary)
    .padding(AppTheme.spacing16)

// BAD
Text("Title")
    .foregroundColor(.black)
    .padding(16)
```

### Notification-Based Refresh

Use `NotificationCenter` for cross-view data refresh:

```swift
.onReceive(NotificationCenter.default.publisher(for: .calendarDataDidChange)) { _ in
    refreshData()
}
```

Post notifications after data changes:

```swift
NotificationCenter.default.post(name: .calendarDataDidChange, object: nil)
```

---

## Quick Reference

### Sheet Patterns

| Scenario | Pattern |
|----------|---------|
| Edit item details | `sheet(item: $editingItem)` |
| Create new item | `sheet(isPresented: $showCreateSheet)` |
| Multiple sheet types | `sheet(item: $activeSheet)` with enum |

### State Patterns

| Need | Solution |
|------|----------|
| Local UI state | `@State` |
| Shared state | `@StateObject` + `@EnvironmentObject` |
| Database query | `@Query` |
| Environment value | `@Environment(\.modelContext)` |

### Navigation Patterns

| Need | Solution |
|------|----------|
| Push to detail | `navigationDestination(item:)` |
| Modal sheet | `sheet(item:)` |
| Full screen cover | `fullScreenCover(item:)` |
| Alert | `alert(isPresented:)` |

---

## References

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftUI State and Data Flow](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- Issue #25: Empty screen on first event selection (race condition fix)

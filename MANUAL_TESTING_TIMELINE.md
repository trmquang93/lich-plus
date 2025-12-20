# Manual Testing: Timeline View

This document contains manual test cases for the new Day Timeline View feature.

## Test Environment Setup

- **Device**: iPhone Simulator (iPhone 16 or similar)
- **iOS Version**: 17.0+
- **App**: Lich+ (lich-plus)
- **Prerequisites**: App installed and launched

---

## 1. View Mode Toggle

### TC-1.1: Switch from List to Day View
**Steps:**
1. Launch the app
2. Tap "Timeline" tab at bottom
3. Observe the segmented control showing "List" and "Day"
4. Tap "Day" segment

**Expected Result:**
- Segmented control switches to "Day" (red background)
- View changes from list layout to time-grid layout
- Time ruler appears on the left side

### TC-1.2: Switch from Day to List View
**Steps:**
1. From Day view, tap "List" segment

**Expected Result:**
- View returns to infinite list layout
- Date-grouped sections appear

### TC-1.3: View Mode Persistence
**Steps:**
1. Switch to Day view
2. Tap Calendar tab
3. Return to Timeline tab

**Expected Result:**
- Timeline should remember the last selected view mode (Day)

---

## 2. Time Ruler (Vietnamese Chi Hours)

### TC-2.1: Hour Labels Display
**Steps:**
1. Navigate to Timeline > Day view
2. Observe the left column (time ruler)

**Expected Result:**
- Hours display in Vietnamese format: 00h, 01h, 02h... 23h
- Each hour cell is clearly separated

### TC-2.2: Vietnamese Chi Names
**Steps:**
1. In Day view, observe the time ruler
2. Check Chi names below each hour

**Expected Result:**
Chi names should follow this pattern (2-hour blocks):
| Hours | Chi Name |
|-------|----------|
| 00h-01h | Ty |
| 02h-03h | Suu |
| 04h-05h | Dan |
| 06h-07h | Mao |
| 08h-09h | Thin |
| 10h-11h | Ty |
| 12h-13h | Ngo |
| 14h-15h | Mui |
| 16h-17h | Than |
| 18h-19h | Dau |
| 20h-21h | Tuat |
| 22h-23h | Hoi |

### TC-2.3: Hoang Dao (Auspicious Hour) Indicators
**Steps:**
1. In Day view, look for gold star indicators on time ruler
2. Check different days to see pattern changes

**Expected Result:**
- Gold stars appear next to auspicious hours
- Pattern varies by day (based on day's Chi)
- 6 auspicious hours per day typically

### TC-2.4: Past Hour Dimming
**Steps:**
1. In Day view, observe hours before current time

**Expected Result:**
- Past hours should appear dimmed (lower opacity)
- Current and future hours at full opacity

---

## 3. Now Indicator

### TC-3.1: Now Indicator Visibility
**Steps:**
1. Navigate to Day view
2. Scroll to find current time

**Expected Result:**
- Red horizontal line indicating current time
- Red circle on left side with pulse animation
- Time label showing current time (e.g., "08:23")

### TC-3.2: Now Indicator Animation
**Steps:**
1. Observe the Now indicator red circle

**Expected Result:**
- Circle pulses (scales 1.0 to 1.3) continuously
- Animation is smooth (2-second cycle)

### TC-3.3: Auto-Scroll to Now
**Steps:**
1. Switch to List view
2. Switch back to Day view

**Expected Result:**
- View should auto-scroll to center on current time
- Now indicator should be visible on screen

### TC-3.4: Now Indicator Time Update
**Steps:**
1. Observe Now indicator for 1+ minute
2. Check the time label

**Expected Result:**
- Time updates every minute
- Position moves down slightly as time progresses

---

## 4. Day Header

### TC-4.1: Date Display
**Steps:**
1. In Day view, observe the header below segmented control

**Expected Result:**
- Shows day of week and date (e.g., "Saturday, December 13")
- Add button (+) visible on the right

### TC-4.2: Add Button
**Steps:**
1. Tap the + button in day header

**Expected Result:**
- Create new event/task sheet opens
- Date is pre-filled to current day

---

## 5. Timeline Grid

### TC-5.1: Hour Grid Lines
**Steps:**
1. In Day view, observe the main content area

**Expected Result:**
- Horizontal lines separate each hour
- Lines extend full width of event area
- Consistent spacing (based on zoom level)

### TC-5.2: Vertical Scrolling
**Steps:**
1. In Day view, swipe up/down on the timeline

**Expected Result:**
- Smooth scrolling through 24 hours
- Time ruler scrolls in sync with content
- Header remains fixed at top

### TC-5.3: Scroll Boundaries
**Steps:**
1. Scroll to top of timeline (00h)
2. Try to scroll further up
3. Scroll to bottom (23h)
4. Try to scroll further down

**Expected Result:**
- Cannot scroll past 00h at top
- Cannot scroll past 23h at bottom
- Rubber-band effect at boundaries

---

## 6. Event Display

### TC-6.1: Timed Event Block
**Prerequisite:** Create an event with specific start/end time (e.g., 10:00-11:30)

**Steps:**
1. Navigate to Day view for the event's date
2. Scroll to the event time

**Expected Result:**
- Event block positioned at correct Y position (10:00)
- Block height matches duration (1.5 hours)
- Shows event title
- Shows time range (10:00 - 11:30)
- Category color on left border

### TC-6.2: Event Block Colors
**Prerequisite:** Create events with different categories

**Steps:**
1. Create events with Work, Personal, Meeting categories
2. View in Day timeline

**Expected Result:**
| Category | Left Border Color |
|----------|------------------|
| Work | Green |
| Personal | Red |
| Meeting | Yellow |
| Birthday | Pink |
| Holiday | Orange |
| Other | Blue |

### TC-6.3: Concurrent Events
**Prerequisite:** Create two overlapping events (e.g., 10:00-11:00 and 10:30-11:30)

**Steps:**
1. Navigate to Day view
2. Find the overlapping time slot

**Expected Result:**
- Events display side-by-side (each 50% width)
- Both events fully visible
- No overlapping content

### TC-6.4: Past Event State
**Steps:**
1. View an event that ended before current time

**Expected Result:**
- Event block appears dimmed/grayscale
- Lower opacity than future events
- No shadow effect

### TC-6.5: Current Event State
**Steps:**
1. Create an event spanning current time
2. View in Day timeline

**Expected Result:**
- Event block at full color
- Subtle animated glow on border
- Elevated shadow

### TC-6.6: Completed Task Display
**Prerequisite:** Create and complete a task

**Steps:**
1. View completed task in Day timeline

**Expected Result:**
- Title has strikethrough
- Checkmark overlay visible
- "Completed" label shown

---

## 7. All-Day Events Strip

### TC-7.1: All-Day Event Display
**Prerequisite:** Create an all-day event

**Steps:**
1. Navigate to Day view for that date
2. Look at area above time grid

**Expected Result:**
- All-day strip visible below header
- Event chip shows category icon and title
- "Ca ngay" (All Day) label on left

### TC-7.2: Multiple All-Day Events
**Prerequisite:** Create 3+ all-day events

**Steps:**
1. View the Day timeline

**Expected Result:**
- Events display as horizontal scrollable chips
- Maximum 3 visible, then "+N more" indicator
- Horizontal scroll works within strip

### TC-7.3: All-Day Event Tap
**Steps:**
1. Tap on an all-day event chip

**Expected Result:**
- Event detail/edit sheet opens

### TC-7.4: Empty All-Day Strip
**Steps:**
1. View a day with no all-day events

**Expected Result:**
- Strip shows "Ca ngay" label
- No event chips visible
- Maintains consistent height

---

## 8. Gestures

### TC-8.1: Tap Event to Edit
**Steps:**
1. Tap on any event block in Day view

**Expected Result:**
- Light haptic feedback
- Edit sheet opens with event details

### TC-8.2: Swipe Left to Delete
**Steps:**
1. Swipe left on an event block
2. Continue past threshold (~80pt)

**Expected Result:**
- Red delete indicator appears
- Warning haptic on threshold
- Event animates off-screen
- Event deleted (or confirmation shown)

### TC-8.3: Swipe Right to Complete (Tasks only)
**Steps:**
1. Swipe right on a task block
2. Continue past threshold

**Expected Result:**
- Green checkmark indicator appears
- Success haptic
- Task marked as completed

### TC-8.4: Long Press Context Menu
**Steps:**
1. Long press on an event block (0.5s+)

**Expected Result:**
- Context menu appears with options:
  - Edit
  - Mark Complete (tasks only)
  - Delete

### TC-8.5: Drag to Create Event
**Steps:**
1. Long press on empty time slot (0.5s)
2. Drag vertically while holding

**Expected Result:**
- Light haptic on initial press
- Dashed preview block appears
- Block grows/shrinks with drag
- Selection haptic every 15 minutes
- Release creates event at that time

### TC-8.6: Pinch to Zoom (if implemented)
**Steps:**
1. Pinch in on timeline
2. Pinch out on timeline

**Expected Result:**
- Hour height changes between scales:
  - 15-min: 120pt/hour (zoomed in)
  - 30-min: 60pt/hour (default)
  - 1-hour: 40pt/hour (zoomed out)
- Haptic feedback on scale snap

---

## 9. Edge Cases

### TC-9.1: No Events Day
**Steps:**
1. Navigate to a day with no events

**Expected Result:**
- Time grid displays normally
- No event blocks visible
- All-day strip empty or hidden

### TC-9.2: Many Events (10+)
**Steps:**
1. Create 10+ events on same day
2. View in Day timeline

**Expected Result:**
- All events render correctly
- Scroll performance remains smooth
- Concurrent events handled (max 3 columns)

### TC-9.3: Very Long Event Title
**Steps:**
1. Create event with 100+ character title
2. View in Day timeline

**Expected Result:**
- Title truncates with ellipsis
- Event block remains properly sized
- No layout breaking

### TC-9.4: Short Duration Event (15 min)
**Steps:**
1. Create 15-minute event
2. View in Day timeline

**Expected Result:**
- Event block visible (minimum height ~30pt)
- Title readable
- Time range shown

### TC-9.5: Midnight Spanning Event
**Steps:**
1. Create event from 11:00 PM to 1:00 AM next day
2. View both days in Day timeline

**Expected Result:**
- Event appears on first day (clipped at midnight)
- Proper handling of multi-day display

---

## 10. Performance

### TC-10.1: Scroll Performance
**Steps:**
1. Rapidly scroll up and down the timeline

**Expected Result:**
- 60fps smooth scrolling
- No frame drops or stuttering
- No memory warnings

### TC-10.2: View Switch Performance
**Steps:**
1. Rapidly switch between List and Day view

**Expected Result:**
- Instant or near-instant switch (<300ms)
- No crashes or freezes

### TC-10.3: Memory Usage
**Steps:**
1. Use Day view for extended period (5+ minutes)
2. Create/delete multiple events
3. Switch views multiple times

**Expected Result:**
- No memory leaks
- App remains responsive
- No crashes

---

## Test Results Template

| Test Case | Pass/Fail | Notes | Date | Tester |
|-----------|-----------|-------|------|--------|
| TC-1.1 | | | | |
| TC-1.2 | | | | |
| TC-1.3 | | | | |
| TC-2.1 | | | | |
| TC-2.2 | | | | |
| ... | | | | |

---

## Known Issues / Limitations

1. **Text input via automation** - idb text input may not work in simulator
2. **Auto-scroll to Now** - May need manual scroll to find current time
3. **Pinch-to-zoom** - May require physical device for gesture testing

---

## Test Data Setup

### Quick Event Creation via Code (for testing)
Add this preview data to test with events:

```swift
// In DayTimelineView preview or test setup
let testEvents: [TaskItem] = [
    TaskItem(title: "Morning Standup", date: today,
             startTime: today.at(hour: 9, minute: 0),
             endTime: today.at(hour: 9, minute: 30),
             category: .meeting, itemType: .event),
    TaskItem(title: "Lunch Break", date: today,
             startTime: today.at(hour: 12, minute: 0),
             endTime: today.at(hour: 13, minute: 0),
             category: .personal, itemType: .event),
    TaskItem(title: "Project Review", date: today,
             startTime: today.at(hour: 14, minute: 0),
             endTime: today.at(hour: 15, minute: 30),
             category: .work, itemType: .event),
]
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-13 | Claude | Initial test cases |

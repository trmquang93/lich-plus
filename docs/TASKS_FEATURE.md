# Tasks Feature

Complete task and event management.

## Model (`Features/Tasks/Models/TaskModels.swift`)

- `Task` (UUID): title, date, optional start/end times, category, notes, completion, reminder, recurrence.
- `TaskCategory`: work, personal, birthday, holiday, meeting, other.
- `RecurrenceType`: none, daily, weekly, monthly, yearly.

## Navigation Flow

- **TasksView**: main entry — list view by default.
- **InfiniteTimelineView**: infinite scrollable list grouped by date.
- **DateSectionHeader**: tap a date header to push **DayTimelineView**.
- **DayTimelineView**: time-grid for that date with concurrent event handling.

## Components

`TaskListHeader`, `TimelineItemCard`, `DateSectionHeader`, `InfiniteTimelineView`, `DayTimelineView`, `TasksView`.

Features: date grouping (Today/Tomorrow/Upcoming), full-text search, period filter (All/Week/Month), one-tap completion, color-coded categories, title required on create.

## Localization Keys

Prefix `task.`: `myTasks`, `search`, `add`, `addNew`, `edit`, `delete`, `done`, `cancel`, `today`, `tomorrow`, `upcoming`, `title`, `date`, `time`, `startTime`, `endTime`, `reminder`, `recurrence`, `category`, `notes`, `completed`, `notCompleted`, `all`, `thisWeek`, `thisMonth`. Categories use `category.`, reminders use `reminder.`.

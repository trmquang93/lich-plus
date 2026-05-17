# Autosync System Architecture

Bidirectional event sync across multiple calendar sources using a two-tier approach.

## Tier 1: Real-Time Sync (Apple Calendar)

`AutoSyncCoordinator` in `Core/Services/AutoSyncCoordinator.swift`

- **Outbound**: Observes local `.calendarDataDidChange` notifications, debounces (0.3s) push to Apple Calendar.
- **Inbound**: Observes `EKEventStoreChanged` notifications, pulls immediately.
- **Lifecycle**: Started on app foreground, stopped on background.

## Tier 2: Periodic Sync (All Sources)

`BackgroundSyncManager` in `Core/Services/BackgroundSyncManager.swift`

- Syncs all enabled sources (Apple, Google, Microsoft, ICS) every 15 minutes.
- Runs as iOS background task (`BGAppRefresh`) when backgrounded.
- Push + pull for Google/Microsoft; pull-only for ICS.
- Silent error handling with `print()` debug logging.

## Push Implementation

- **Google Calendar**: `GoogleCalendarService` + `GoogleCalendarSyncService.pushLocalChanges()` — `POST`/`PATCH`/`DELETE` `/calendars/{id}/events`. Uses `RetryUtility.withExponentialBackoff` for 429s.
- **Microsoft Calendar**: `MicrosoftCalendarService` + `MicrosoftCalendarSyncService.pushLocalChanges()` — Microsoft Graph `/me/events` with identical retry strategy.

## Conflict Resolution

Last-write-wins via `lastModifiedRemote` vs `lastModifiedLocal`. Applied during pull operations in both tiers.

## Database Fields

- `syncStatus`: "pending" | "synced" | "deleted"
- `lastModifiedLocal`, `lastModifiedRemote`
- Source IDs: `googleEventId`, `microsoftEventId`, `icsEventUid`, `ekEventIdentifier`

## Entitlements

- `UIBackgroundModes` includes background fetch.
- Task identifier: `com.lichplus.sync.background` in entitlements.
- 15-minute interval hardcoded.

## Testing

- `AutoSyncCoordinatorTests.swift` — real-time sync behavior, observer lifecycle.
- Future: `GoogleCalendarServicePushTests`, `MicrosoftCalendarServicePushTests`.

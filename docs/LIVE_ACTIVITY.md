# Tết / Festival Live Activity

Privacy-safe ActivityKit Live Activity showing a countdown to the next public lunar festival (Tết and other catalog holidays).

## What appears

- **Lock Screen**: festival name (public catalog only), solar date, days remaining.
- **Dynamic Island** (iPhone 14 Pro+): compact countdown number; expanded shows festival title, days label, and solar date.

No user events, giỗ names, birth year, văn khấn, or private notes are ever included.

## User control

**Settings → Preferences → Festival countdown**

- **Auto-start before festivals** (default on): starts the Live Activity when a public festival is within 45 days.
- **Start / Stop Live Activity**: manual control when a festival is in the window.

## Code layout

| Path | Role |
|------|------|
| `LichPlusShared/FestivalLiveActivityAttributes.swift` | ActivityKit attributes |
| `LichPlusShared/FestivalLiveActivityConstants.swift` | Window (45 days) and keys |
| `LichPlusWidgets/FestivalLiveActivityWidget.swift` | Lock Screen + Dynamic Island UI |
| `lich-plus/Core/LiveActivity/FestivalLiveActivityManager.swift` | Start / update / end |
| `lich-plus/Core/LiveActivity/FestivalLiveActivityStore.swift` | Auto-start preference |
| `lich-plus/Features/Settings/Components/FestivalLiveActivitySettingsView.swift` | Settings UI |

Countdown dates come from `FestivalCountdownProvider` / `PublicHolidayCatalog` (same as in-app card and countdown widget).

## Xcode / App Store Connect (Quang)

1. **Main app** (`lich-plus`): `NSSupportsLiveActivities` = YES in Info.plist (done).
2. **Widget extension** (`LichPlusWidgets`): `NSSupportsLiveActivities` = YES in Info.plist (done).
3. **Signing**: App Group `group.com.qtran.lich-plus` must remain enabled on both targets.
4. **Simulator**: iOS 17+ simulator with Live Activities enabled in Settings → Face ID & Passcode → Live Activities (or use a physical device).
5. **ASC**: No extra capability beyond existing App Group; Live Activities use local updates only (no Push Notification capability required for this MVP).

## Testing

1. Set simulator date to ~30 days before the next Tết (see `LunarBoundarySweepTests` for solar anchors).
2. Open **Settings → Festival countdown** → **Start Live Activity**.
3. Lock the device to see the Lock Screen banner; on supported devices, check Dynamic Island.

## Analytics

- `live_activity_start` — activity started (manual or auto).
- `live_activity_end` — user stopped or festival passed.

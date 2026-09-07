# Analytics event taxonomy (Lich+)

Privacy-safe instrumentation for Firebase Analytics. **Never** log calendar titles, event notes, giỗ/ancestor names, greeting text, văn khấn content, or other user-entered private data.

All events flow through `AnalyticsService` and `AnalyticsParameterPolicy` in `lich-plus/Core/Analytics/`.

## Events

| Event | When | Parameters |
|-------|------|------------|
| `app_open` | Cold start or return from background | `source` (`cold_start` \| `foreground`), `app_version`, `build_number` |
| `screen_view` | User views a product surface | `screen_name` (see below) |
| `feature_used` | User completes a product action | `feature_id` (see below) |
| `notif_permission` | OS notification permission result | `granted` (`true` \| `false`) |
| `notif_opt_in` | In-app notification master toggle outcome | `opted_in` (`true` \| `false`) |
| `widget_install` | Widget added to home screen (future) | `widget_kind` (`today` \| `month` \| `timeline`) |

## `screen_name` values

Defined in `AnalyticsScreen.swift`:

- `calendar`, `timeline`, `customs`, `settings`
- `notification_settings`, `calendar_sync_settings`, `google_calendar_settings`, `microsoft_calendar_settings`, `ics_calendar_settings`, `lunar_special_dates_settings`, `language_settings`, `personal_profile`
- `van_khan`, `greetings`, `day_detail`

## `feature_id` values

Defined in `AnalyticsFeature.swift`:

- `google_calendar_connect`, `microsoft_calendar_connect`, `apple_calendar_sync`, `ics_calendar_subscribe`
- `share_app`, `rate_app`, `greeting_generate`, `van_khan_export_pdf`

## Crashlytics

- Automatic crash reports (stack traces, device/OS metadata).
- Optional non-PII breadcrumbs via `AnalyticsService.recordBreadcrumb(_:)`.
- Custom keys limited to `AnalyticsParameterPolicy.allowedParameterKeys` (e.g. `app_version`, `build_number`).

## Adding new instrumentation

1. Add a new case to `AnalyticsScreen` or `AnalyticsFeature` — never pass free-form strings from the UI.
2. If a new parameter key is required, add it to `AnalyticsParameterPolicy.allowedParameterKeys` and document it here.
3. Call `AnalyticsService.shared` from the feature layer; do not call `Analytics.logEvent` directly.

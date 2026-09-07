# Firebase setup (Analytics + Crashlytics)

Lich+ uses the [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) via Swift Package Manager (`FirebaseAnalytics`, `FirebaseCrashlytics`).

## Prerequisites

- A Firebase project (create one at [Firebase Console](https://console.firebase.google.com/))
- Bundle ID: `com.qtran.lich-plus`

## One-time console setup

1. In Firebase Console, add an **iOS app** with bundle ID `com.qtran.lich-plus`.
2. Download **GoogleService-Info.plist** from the app settings page.
3. Copy the file into the `lich-plus/` folder in this repo (same level as `Info.plist`).
4. In Xcode, ensure `GoogleService-Info.plist` is included in the **lich-plus** target (the synchronized folder should pick it up automatically).

> **Do not commit** a real `GoogleService-Info.plist` to git. It is listed in `.gitignore`. Use `lich-plus/GoogleService-Info.plist.example` as a reference for the expected keys.

## Enable Crashlytics in Firebase Console

1. Open **Crashlytics** in the Firebase project and complete the setup wizard.
2. Build and run a Release/archive build so the **Firebase Crashlytics** run script can upload dSYMs.

## Local build without Firebase

If `GoogleService-Info.plist` is missing, the app still builds and runs. `AnalyticsService.configureIfNeeded()` skips Firebase initialization and logs events to the debug console only (`#if DEBUG`).

## Verify Analytics

1. Add `GoogleService-Info.plist` locally.
2. Run the app on a device or simulator.
3. Open **Firebase Console → Analytics → DebugView** and enable debug mode:
   ```bash
   # Replace with your Xcode scheme / bundle path as needed
   xcrun simctl spawn booted log config --mode "level:debug" --subsystem com.google.firebase
   ```
   Or add `-FIRDebugEnabled` to the scheme's launch arguments.
4. Navigate tabs — you should see `screen_view` events with `screen_name` values from `docs/ANALYTICS.md`.

## Verify Crashlytics (debug only)

In a **Debug** build with Firebase configured:

```swift
AnalyticsService.shared.triggerTestCrash()
```

Only call this during manual QA. Do not ship test-crash UI in production builds (`#if DEBUG` guard in `AnalyticsService`).

## Xcode Cloud / CI

Store `GoogleService-Info.plist` as a **secret file** or CI environment artifact and copy it into `lich-plus/` during `ci_post_clone.sh` before the Xcode build. Without it, CI builds succeed but Analytics/Crashlytics remain inactive.

## Privacy

See `docs/ANALYTICS.md` and `landing-page/privacy.html`. Instrumentation is limited to product surfaces and feature IDs — never user calendar or ritual text content.

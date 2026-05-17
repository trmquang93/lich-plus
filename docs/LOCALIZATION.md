# Localization

The app uses Xcode's **String Catalog** (`Localizable.xcstrings`). Languages: English (en), Vietnamese (vi).

## CRITICAL: Never edit `Localizable.xcstrings` manually

Always let Xcode manage it. Manual edits corrupt the file structure.

## Workflow

1. In Swift code, use `String(localized:)` with **raw English text** (no dot-notation):
   ```swift
   Text(String(localized: "Lunar Special Dates"))
   Label(String(localized: "Add Event"), systemImage: "plus")
   ```
2. Build with Xcode — auto-extracts new keys into `Localizable.xcstrings`. The English text is both the key and default translation.
3. Vietnamese translation is a **separate task**: open `Localizable.xcstrings` in Xcode and add the `vi` value.

## Rules

- **Never** use dot-notation keys like `"settings.lunarSpecialDates.title"`.
- **Always** use raw English strings.
- Build with Xcode to auto-extract.
- Xcode warns on missing localizations.

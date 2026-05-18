# Localization

The app uses Xcode's **String Catalog** (`Localizable.xcstrings`). Languages: English (en), Vietnamese (vi).

## CRITICAL: Never edit `Localizable.xcstrings` manually

Always let Xcode manage it. Manual edits corrupt the file structure.

## Workflow

1. In Swift code, use **raw English text** (no dot-notation keys). Pick the form that fits the call site:
   - **`LocalizedStringKey`** — preferred for SwiftUI view parameters that already accept it (`Text`, `Label`, `navigationTitle`, `Button(_:action:)`, custom view props typed `LocalizedStringKey`). Pass the literal directly; SwiftUI resolves it lazily:
     ```swift
     Text("Lunar Special Dates")
     Label("Add Event", systemImage: "plus")
     FormSection(title: "Title") { ... }   // title: LocalizedStringKey
     ```
   - **`String(localized:)`** — use when you need an eagerly-resolved `String` (string interpolation, `String(format:)`, model fields, non-SwiftUI APIs, things that won't accept `LocalizedStringKey`):
     ```swift
     let msg = String(format: String(localized: "Giỗ %@ %@"), relation, name)
     alert.title = String(localized: "Are you sure?")
     ```
2. Build with Xcode — both forms are auto-extracted into `Localizable.xcstrings`. The English text is both the key and default translation.
3. Vietnamese translation is a **separate task**: open `Localizable.xcstrings` in Xcode and add the `vi` value.

## Rules

- **Never** use dot-notation keys like `"settings.lunarSpecialDates.title"`.
- **Always** use raw English strings.
- For custom view props that take user-facing display text, type them `LocalizedStringKey` (not `String`) so callers can pass literals and SwiftUI handles localization. Only use `String` when the field carries runtime/data text (e.g. an event title from the database) — those must not be looked up as localization keys.
- Build with Xcode to auto-extract.
- Xcode warns on missing localizations.

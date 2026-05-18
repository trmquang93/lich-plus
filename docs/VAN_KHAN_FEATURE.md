# Văn Khấn Feature

Bundled, offline-capable library of Vietnamese văn khấn (formal prayer)
texts, prefilled with the user's personal information and exportable as
PDF.

## Where it lives

- **Tab:** Phong tục (3rd tab) — `App/PhongTucFeedView.swift`.
- **Calendar surface:** `Features/Calendar/Components/DayDetailView.swift`
  injects `VanKhanBannerCard` above the day-quality card whenever an
  occasion matches the visible day.
- **Personal profile:** Edited in Settings → Cá nhân
  (`Features/Settings/Components/PersonalProfileView.swift`).

## Architecture

```
Features/VanKhan/
├── Models/VanKhanModels.swift              # VanKhanOccasion, VanKhanCategory, OccasionTrigger, VanKhanText
├── Data/
│   ├── VanKhanLibrary.swift                # static catalogue (metadata only)
│   ├── VanKhanTexts+Monthly.swift          # bundled bodies (TEMPLATE — needs vetted text)
│   ├── VanKhanTexts+Festivals.swift
│   ├── VanKhanTexts+Anniversary.swift
│   └── VanKhanTexts+Family.swift
├── Services/
│   ├── VanKhanRenderer.swift               # token substitution (pure)
│   ├── VanKhanOccasionMatcher.swift        # (lunarDay, lunarMonth, solarDate) -> matches
│   └── VanKhanPDFRenderer.swift            # UIGraphicsPDFRenderer, A4, multi-page
├── Views/
│   ├── VanKhanSection.swift                # inline section in Phong tục feed
│   ├── VanKhanDetailView.swift             # renderer + overrides + Export PDF
│   └── TodayHighlightsSection.swift        # "Hôm nay" hero
└── Components/
    ├── VanKhanRenderedBody.swift           # AttributedString with gold/red token styling
    └── VanKhanBannerCard.swift             # Calendar day-detail banner
```

Persistence: `PersonalProfile` and `DeceasedRelative` SwiftData `@Model`s
in `Core/Persistence/Models/`. Singleton fetched via
`Core/Services/PersonalProfileService.swift` (`@MainActor`).

## Token substitution

`VanKhanRenderer.render(text:profile:overrides:context:)` walks `{token}`
placeholders with this priority:

1. `overrides` dict (user-edited in the detail view)
2. `context.deceasedRelative` for giỗ (`{deceasedName}`, `{deceasedRelation}`)
3. `context.childName` for đầy tháng / thôi nôi (`{childName}`)
4. `PersonalProfile` (`{name}`, `{address}`, `{gender}`, `{spouseName}`)
5. Generated dates (`{solarDate}` in `dd/MM/yyyy`, `{lunarDate}` in `dd/mm/yyyy`)

Unknown / empty tokens are **left intact** (`{token}`) so the UI's
`VanKhanRenderedBody` can render them in brand-red to highlight what the
user still needs to fill in. Resolved tokens get a soft gold
under-highlight.

## Occasion matching

`VanKhanOccasionMatcher.match(date:profile:max:)` returns up to `max`
`Match`es, ranked:

1. **Anniversary** (giỗ) — iterate `profile.deceasedRelatives`; match by
   `(lunarDay, lunarMonth)`.
2. **Festival** — fixed lunar dates (Vu Lan 15/7, Trung Thu 15/8, Ông
   Táo 23/12, Tết, Rằm tháng Giêng), Giao Thừa (last lunar day of year),
   Thanh Minh (solar 4/4 ±1).
3. **Monthly** — Mùng 1 / Rằm, suppressed when a festival of the same
   lunar day already matched.

Used by both `TodayHighlightsSection` (capped at 2) and
`VanKhanBannerCard` (capped at 1).

## PDF export

`VanKhanPDFRenderer.renderToTempFile(...)` produces an A4 PDF via
`UIGraphicsPDFRenderer`. Body draws with the system serif font (Apple
New York where available, falls back to system font — both ship with
full Vietnamese diacritics). Pagination via binary-search of the longest
attributed prefix that fits the remaining height. Output is shared with
`UIActivityViewController`.

## Tests

- `lich-plusTests/PersonalProfileServiceTests.swift` — 4 tests (singleton
  invariant, persistence, add/remove deceased relatives).
- `lich-plusTests/VanKhanRendererTests.swift` — 7 tests (substitution,
  overrides, unknown-token preservation, deceased binding, solar date
  injection).
- `lich-plusTests/VanKhanOccasionMatcherTests.swift` — 8 tests (monthly,
  festival wins over monthly, Vu Lan, Trung Thu, Ông Táo, giỗ from
  profile, no-match day).

Run with: `/Users/quang/.claude/skills/ios-build-test/scripts/run_tests.sh single lich-plusTests`.

## Known gaps / follow-ups

- **Bundled prayer texts are TEMPLATES** — each body has a
  `[TODO: ... — tra cứu nguồn chính thống]` marker. The plan calls out
  cultural-authenticity risk; replace with vetted Vietnamese sources
  (cite per file) before shipping.
- Lời chúc surface in the Phong tục feed is a single `NavigationLink`
  into the existing `GreetingGeneratorView` (pragmatic divergence from
  the plan's "extract `GreetingsSection`" step — avoided refactoring the
  greeting controls). Revisit if/when the feed needs inline greeting
  previews.
- AI personalization, AirPrint, push notifications on Rằm/Mùng 1, and
  backend-hosted text updates are explicitly out of v1.

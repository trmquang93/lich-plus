# Vietnamese Astrology (Hoàng Đạo, 12 Trực, Stars)

Traditional Vietnamese astrology calculations for determining auspicious/inauspicious days.

## Core Components

### 12 Trực (Zodiac Hours) — `HoangDaoCalculator.swift`
- 12 zodiac hours: Kiến, Trừ, Mãn, Bình, Định, Chấp, Phá, Nguy, Thành, Thu, Khai, Bế.
- "Tháng nào trực nấy": `Trực = (monthOffset + dayOfMonth - 1) % 12`
- Month offsets: `[9, 2, 7, 0, 5, 10, 3, 8, 1, 6, 11, 4]` for months 1-12.
- `getMonthChi()` maps each month to its Chi.

### Lục Hắc Đạo (6 Unlucky Days) — `LucHacDaoCalculator.swift`
- Detects inauspicious day types (Thiên Lao, Câu Trần, Chu Tước, etc.) by lunar month + day Chi.
- Each type has severity and activity restrictions.

### Special Festival Dates — `AstrologyData.swift`
- Festivals override normal 12 Trực: `(1,1), (1,15), (3,3), (5,5), (7,15), (8,15), (10,10)`.
- Generic 1st/15th use standard formula.

## Day Quality

`HoangDaoCalculator.determineDayQuality()` combines 12 Trực + Lục Hắc Đạo + Stars.

- Auspicious hours: +2.0
- Unlucky days: -2.0 to -2.5
- Result: Good (>0), Bad (<0), Neutral (≈0)
- Includes lucky directions, colors, suitable/taboo activities.

Key types: `ZodiacHourType`, `DayQuality`, `HourlyZodiac`.

## Star System

All 12 lunar months implemented (720/720 Can-Chi). 42 stars (12 good + 30 bad).

- Data: `Features/Calendar/Data/Month1StarData.swift` … `Month12StarData.swift`
- Models: `StarModels.swift` — `GoodStar`, `ExtendedBadStar`, `DayStarData`, `MonthStarData`
- Calculator: `StarCalculator.swift` — `detectStars()`, `calculateStarScore()`

Data quality:
- Months 9-12: detailed (33% coverage)
- Months 7-8: partial (17%)
- Months 1-6: structure ready (50%)

## Validation Metrics (vs xemngay.com)

- **Tier 1 (Critical)**: 100% — Day/Month/Year Can-Chi, 12 Trực
- **Tier 2 (Important)**: 100% — Lucky hours, Lục Hắc Đạo
- **Tier 3 (Enhanced)**: 45% — Star names (limited by data months 1-6)

URL: `https://xemngay.com/Default.aspx?blog=xngay&d=DDMMYYYY`
Tests: `lich-plusTests/VietnameseCalendarTests.swift` (lines 856-1039)

## Reference Book & Verification

**Source**: `lich-van-nien.pdf` (193 pages). Star data: pages 104-175.

Page mapping:
```
Month 1: 104-109   Month 7:  140-145
Month 2: 110-115   Month 8:  146-151
Month 3: 116-121   Month 9:  152-157
Month 4: 122-127   Month 10: 158-163
Month 5: 128-133   Month 11: 164-169
Month 6: 134-139   Month 12: 170-175

12 Truc: 48-49        Hoang Dao/Hac Dao: 50-52
Good Stars: 60-63     Bad Stars: 64-67
Star Quality: 77-91   Index: 188-191
```

All pages extracted to `book/pages/page_NNNN.jpg`. Index: `book/BOOK_INDEX.md`.

### Extraction Tools

```bash
# By month
./extract_book_pages.sh lich-van-nien.pdf 5
./extract_book_pages.sh lich-van-nien.pdf hoangdao   # 50-52
./extract_book_pages.sh lich-van-nien.pdf 12truc     # 48-49
./extract_book_pages.sh lich-van-nien.pdf stars      # 77-91

# Custom range
./pdf_to_images.py lich-van-nien.pdf --pages 128-133 --output ./temp_extract
./pdf_to_images.py lich-van-nien.pdf --pages 50-52 --dpi 300 --output ./temp_extract
```

## Verification Workflow

1. Identify lunar month/day Can-Chi for the date.
2. Extract pages: `./extract_book_pages.sh lich-van-nien.pdf <month>`
3. Read images — verify Column A (Can-Chi), B (Sao xấu), C (Sao tốt).
4. Compare with `Features/Calendar/Data/Month<X>StarData.swift` and `StarModels.swift`.
5. Update if mismatch; run unit tests.

The book is authoritative when debugging day quality, validating stars, or resolving accuracy reports.

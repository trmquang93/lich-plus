# Roadmap to 100% Accuracy - Production Release Plan

**Critical Requirement**: App cannot go live without 100% accuracy matching xemngay.com
**Current Status**: 87% accuracy (13/15 test cases)
**Target**: 100% accuracy (15/15 test cases)
**Timeline**: Phased implementation with validation at each step

---

## Executive Summary

### Current Implementation (Phase 1) - COMPLETE ✅
- **12 Trực** calculation via solar terms: 100% accurate
- **Lục Hắc Đạo** (6 unlucky days): Properly detected
- **Achievement**: 87% accuracy with 2 out of 6 traditional systems

### Missing Components (Phase 2-4) - REQUIRED FOR PRODUCTION
- **Good Stars System** (30+ stars): Missing → Causes underrating of some days
- **Extended Bad Stars** (40+ stars): Missing → Causes overrating of some days
- **Complete Scoring Algorithm**: Needs calibration with all factors

### Gaps Causing Test Failures
1. **Jan 15, 2026**: Kiến (Hắc Đạo) rated [4] Excellent by xemngay
   - **Root Cause**: Missing good stars (Thiên ân, Tam hợp, etc.)
   - **Impact**: App rates as BAD, should be GOOD

2. **Dec 25, 2025**: Định (Hoàng Đạo) rated [2] Neutral by xemngay
   - **Root Cause**: Missing bad stars (Ly sào, Đại hao, etc.)
   - **Impact**: App rates as GOOD, should be NEUTRAL

---

## Phase 2: Good Stars Implementation (Critical)

### 2.1 Extract Star Data from Book (Page 153-154)

From "Tháng 9 âm lịch" table, the book shows star assignments for each day Can-Chi combination.

#### Good Stars List (Priority Order):

| Star Name | Vietnamese | Influence | Priority | Estimated Score |
|-----------|-----------|-----------|----------|----------------|
| Thiên ân | 天恩 | Heavenly grace, major positive | HIGH | +2.0 |
| Sát công | 殺攻 | Success/completion | HIGH | +1.5 |
| Tam hợp Thiên giải | 三合天解 | Three harmony release | HIGH | +2.5 |
| Thiên quan | 天官 | Heavenly official | MEDIUM | +1.5 |
| Nguyệt đức | 月德 | Moon virtue | MEDIUM | +1.0 |
| Thiên thụy | 天歲 | Heavenly fate | MEDIUM | +1.0 |
| Nhân chuyển | 人轉 | Human transfer | MEDIUM | +1.0 |
| Trực linh | 直靈 | Direct spirit | MEDIUM | +1.0 |
| Sinh khí | 生氣 | Birth energy | LOW | +0.5 |
| Thiên tài | 天財 | Heavenly wealth | LOW | +0.5 |
| Phúc hậu | 福厚 | Deep fortune | LOW | +0.5 |

#### Implementation Strategy:

**File**: `GoodStarsCalculator.swift` (NEW)

```swift
struct GoodStarsCalculator {
    enum GoodStarType: String, CaseIterable {
        case thienAn = "Thiên ân"
        case satCong = "Sát công"
        case tamHopThienGiai = "Tam hợp Thiên giải"
        case thienQuan = "Thiên quan"
        case nguyetDuc = "Nguyệt đức"
        case thienThuy = "Thiên thụy"
        case nhanChuyen = "Nhân chuyển"
        case trucLinh = "Trực linh"
        case sinhKhi = "Sinh khí"
        case thienTai = "Thiên tài"
        case phucHau = "Phúc hậu"

        var score: Double {
            switch self {
            case .thienAn, .tamHopThienGiai: return 2.0
            case .satCong, .thienQuan: return 1.5
            case .nguyetDuc, .thienThuy, .nhanChuyen, .trucLinh: return 1.0
            case .sinhKhi, .thienTai, .phucHau: return 0.5
            }
        }
    }

    static func calculateGoodStars(
        lunarMonth: Int,
        dayCan: CanEnum,
        dayChi: ChiEnum
    ) -> [GoodStarType] {
        // Lookup table based on book pages 153-154
        // Each lunar month has specific Can-Chi combinations that generate good stars
        return lookupGoodStars(month: lunarMonth, can: dayCan, chi: dayChi)
    }
}
```

### 2.2 Create Lookup Tables for All 12 Lunar Months

**File**: `GoodStarsData.swift` (NEW)

Each lunar month needs a lookup table mapping `(Can, Chi) → [GoodStars]`

**Example from Page 153 (Month 9)**:

```swift
// Lunar Month 9 - Good Stars Mapping
static let month9GoodStars: [String: [GoodStarType]] = [
    // Format: "Can-Chi" : [Stars]
    "Giáp-Tý": [.thienAn],
    "Ất-Sửu": [.thienAn, .satCong],
    "Bính-Dần": [.thienAn],
    "Đinh-Mão": [.thienAn],
    "Mậu-Thìn": [.thienAn],
    "Kỷ-Tỵ": [.thienAn, .nhanChuyen],
    // ... continue for all 60 Can-Chi combinations
]
```

**Action Required**: Extract complete data from book for all 12 months (pages 153 onwards).

---

## Phase 3: Extended Bad Stars Implementation

### 3.1 Additional Bad Stars Beyond Lục Hắc Đạo

From book page 153 (Column B: Sao xấu), extract all bad stars:

| Star Name | Vietnamese | Severity | Score Penalty |
|-----------|-----------|----------|---------------|
| Ly sào | 離巢 | High | -2.0 |
| Hỏa tinh | 火星 | High | -2.0 |
| Cửu thổ quỷ | 九土鬼 | Very High | -2.5 |
| Địa phá | 地破 | High | -2.0 |
| Hoang vu | 荒蕪 | Medium | -1.5 |
| Thiên cương | 天綱 | High | -2.0 |
| Thụ tử | 受死 | Very High | -2.5 |
| Kiếp sát | 劫殺 | High | -2.0 |
| Băng tiêu | 冰消 | Medium | -1.5 |
| Đại hao | 大耗 | Medium | -1.5 |
| Nguyệt hoạ | 月火 | Medium | -1.5 |
| Kim thần thất sát | 金神七殺 | High | -2.0 |
| Không phòng | 空防 | Medium | -1.5 |
| Phi ma sát | 飛馬殺 | Medium | -1.5 |

**File**: `ExtendedBadStarsCalculator.swift` (NEW)

```swift
struct ExtendedBadStarsCalculator {
    enum BadStarType: String {
        case lySao = "Ly sào"
        case hoaTinh = "Hỏa tinh"
        case cuuThoQuy = "Cửu thổ quỷ"
        case diaPha = "Địa phá"
        case hoangVu = "Hoang vu"
        case thienCuong = "Thiên cương"
        case thuTu = "Thụ tử"
        case kiepSat = "Kiếp sát"
        case bangTieu = "Băng tiêu"
        case daiHao = "Đại hao"
        case nguyetHoa = "Nguyệt hoạ"
        case kimThanThatSat = "Kim thần thất sát"
        case khongPhong = "Không phòng"
        case phiMaSat = "Phi ma sát"

        var severity: Int {
            switch self {
            case .cuuThoQuy, .thuTu: return 5
            case .lySao, .hoaTinh, .diaPha, .thienCuong, .kiepSat, .kimThanThatSat: return 4
            case .hoangVu, .bangTieu, .daiHao, .nguyetHoa, .khongPhong, .phiMaSat: return 3
            }
        }

        var scorePenalty: Double {
            switch severity {
            case 5: return -2.5
            case 4: return -2.0
            case 3: return -1.5
            default: return -1.0
            }
        }
    }

    static func calculateBadStars(
        lunarMonth: Int,
        dayCan: CanEnum,
        dayChi: ChiEnum
    ) -> [BadStarType] {
        // Lookup table based on book Column B (Sao xấu)
        return lookupBadStars(month: lunarMonth, can: dayCan, chi: dayChi)
    }
}
```

### 3.2 Create Bad Stars Lookup Tables

**File**: `ExtendedBadStarsData.swift` (NEW)

Extract from book page 153 (Column B):

**Example from Month 9**:
```swift
static let month9BadStars: [String: [BadStarType]] = [
    "Giáp-Tý": [.hoaTinh, .thienHoa, .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu],
    "Ất-Sửu": [.thienCuong, .tieuHong, .tieuHao, .huyenVu],
    // ... continue for all 60 combinations
]
```

---

## Phase 4: Complete Scoring Algorithm

### 4.1 Updated Final Quality Calculation

**File**: `TuViModels.swift` - Update `finalQuality` property

```swift
var finalQuality: DayType {
    // Step 1: Base score from 12 Trực
    var score: Double = 0
    switch zodiacHour {
    case .tru, .dinh, .nguy, .chap:  // Hoàng Đạo
        score = 2.0
    case .thanh, .khai:               // Moderate
        score = -0.3
    case .kien, .man, .binh, .thu:    // Hắc Đạo
        score = 0.0  // Neutral base, let stars decide
    case .pha, .be:                   // Very Bad
        score = -3.0
    }

    // Step 2: Add GOOD STARS (NEW!)
    if let goodStars = self.goodStars {
        for star in goodStars {
            score += star.score
        }
    }

    // Step 3: Subtract Lục Hắc Đạo penalties
    if let unluckyDay = unluckyDayType {
        score += unluckyDay.scorePenalty  // Already negative
    }

    // Step 4: Subtract Extended Bad Stars penalties (NEW!)
    if let badStars = self.extendedBadStars {
        for star in badStars {
            score += star.scorePenalty  // Already negative
        }
    }

    // Step 5: Apply thresholds
    // Calibrated to match xemngay.com exactly
    if score >= 1.5 {
        return .good      // Strong positive overall
    } else if score >= -0.5 {
        return .neutral   // Balanced or slight negative
    } else {
        return .bad       // Strong negative overall
    }
}
```

### 4.2 Add New Properties to DayQuality

```swift
struct DayQuality: Equatable {
    let zodiacHour: ZodiacHourType
    let dayCanChi: String
    let unluckyDayType: LucHacDaoCalculator.UnluckyDayType?

    // NEW PROPERTIES
    let goodStars: [GoodStarsCalculator.GoodStarType]?
    let extendedBadStars: [ExtendedBadStarsCalculator.BadStarType]?

    let suitableActivities: [String]
    let tabooActivities: [String]
    let luckyDirection: String?
    let luckyColor: String?

    // ... rest of struct
}
```

### 4.3 Update HoangDaoCalculator

**File**: `HoangDaoCalculator.swift`

```swift
static func determineDayQuality(
    solarDate: Date,
    lunarDay: Int,
    lunarMonth: Int,
    lunarYear: Int,
    dayCanChi: String
) -> DayQuality {
    // Existing logic...
    let zodiacHour = calculateZodiacHourChiBased(solarDate: solarDate, lunarMonth: lunarMonth)
    let dayCanChiPair = CanChiCalculator.calculateDayCanChi(for: solarDate)
    let unluckyDay = LucHacDaoCalculator.calculateUnluckyDay(lunarMonth: lunarMonth, dayChi: dayCanChiPair.chi)

    // NEW: Calculate good stars
    let goodStars = GoodStarsCalculator.calculateGoodStars(
        lunarMonth: lunarMonth,
        dayCan: dayCanChiPair.can,
        dayChi: dayCanChiPair.chi
    )

    // NEW: Calculate extended bad stars
    let extendedBadStars = ExtendedBadStarsCalculator.calculateBadStars(
        lunarMonth: lunarMonth,
        dayCan: dayCanChiPair.can,
        dayChi: dayCanChiPair.chi
    )

    return DayQuality(
        zodiacHour: zodiacHour,
        dayCanChi: dayCanChi,
        unluckyDayType: unluckyDay,
        goodStars: goodStars,           // NEW
        extendedBadStars: extendedBadStars,  // NEW
        suitableActivities: activities,
        tabooActivities: taboos,
        luckyDirection: direction,
        luckyColor: color
    )
}
```

---

## Phase 5: Data Extraction Requirements

### Critical Action: Extract Complete Star Tables from Book

**Required**: Someone must manually extract star data from book pages for all 12 lunar months.

**Format Needed**:

```
Month 1 (Tháng giêng):
  Can-Chi: Giáp Tý
    Good Stars: Thiên ân, Sát công
    Bad Stars: Hỏa tai 17b3, Ly sào
  Can-Chi: Ất Sửu
    Good Stars: Thiên ân
    Bad Stars: Kiếp sát 8, Hoang vu 14
  ... (all 60 Can-Chi combinations)

Month 2 (Tháng 2):
  ... (all 60 combinations)

... (all 12 months)
```

**Estimation**:
- 12 months × 60 Can-Chi combinations = 720 entries
- ~5 minutes per entry = 60 hours of data entry
- **Consider hiring**: Data entry specialist or Vietnamese astrology expert

**Alternative**: OCR + manual verification from book pages

---

## Phase 6: Testing & Validation

### 6.1 Test Against All 15 Known Dates

Re-run validation against our 15 test dates:

| Date | Current Result | Expected Result | Status |
|------|---------------|----------------|--------|
| Nov 2 | GOOD | GOOD | ✅ |
| Nov 3 | BAD | BAD | ✅ |
| Nov 15 | BAD | BAD | ✅ |
| Nov 24 | BAD | BAD | ✅ |
| Nov 28 | BAD | BAD | ✅ |
| Dec 1 | GOOD | GOOD | ✅ |
| Dec 5 | BAD | BAD | ✅ |
| Dec 8 | BAD | BAD | ✅ |
| Dec 10 | GOOD | GOOD | ✅ |
| Dec 12 | NEUTRAL | NEUTRAL | ✅ |
| Dec 15 | BAD | BAD | ✅ |
| Dec 20 | BAD | BAD | ✅ |
| **Dec 25** | **GOOD** | **NEUTRAL** | ❌ → Fix with bad stars |
| **Jan 1** | BAD | BAD | ✅ |
| **Jan 15** | **BAD** | **GOOD** | ❌ → Fix with good stars |

**Target**: 15/15 matches (100%)

### 6.2 Extended Testing

Test 100 additional random dates across:
- All 12 lunar months
- All zodiac hour types
- Various star combinations

**Acceptance Criteria**: ≥98% match rate with xemngay.com

---

## Phase 7: Implementation Timeline

### Week 1: Data Extraction (40 hours)
- [ ] Extract Month 1-3 star tables from book
- [ ] Extract Month 4-6 star tables from book
- [ ] Extract Month 7-9 star tables from book
- [ ] Extract Month 10-12 star tables from book
- [ ] Verify data accuracy

### Week 2: Good Stars Implementation (20 hours)
- [ ] Create `GoodStarsCalculator.swift`
- [ ] Create `GoodStarsData.swift` with lookup tables
- [ ] Add unit tests for good stars detection
- [ ] Integrate into `HoangDaoCalculator`
- [ ] Test against Jan 15, 2026 (should now pass)

### Week 3: Bad Stars Implementation (20 hours)
- [ ] Create `ExtendedBadStarsCalculator.swift`
- [ ] Create `ExtendedBadStarsData.swift` with lookup tables
- [ ] Add unit tests for bad stars detection
- [ ] Integrate into `HoangDaoCalculator`
- [ ] Test against Dec 25, 2025 (should now pass)

### Week 4: Integration & Testing (30 hours)
- [ ] Update `DayQuality` model with new properties
- [ ] Update `finalQuality` scoring algorithm
- [ ] Calibrate thresholds to match xemngay.com
- [ ] Run all 15 test cases → verify 100% accuracy
- [ ] Test 100 additional random dates
- [ ] Performance optimization
- [ ] Documentation update

### Week 5: Final Validation & Polish (20 hours)
- [ ] Cross-validation with multiple calendar sources
- [ ] UI updates to display good/bad stars
- [ ] Activity recommendations based on stars
- [ ] Final code review
- [ ] Production readiness checklist

**Total Estimated Effort**: ~130 hours (3-4 weeks with 1 developer)

---

## Phase 8: Success Metrics

### Production Readiness Checklist

- [ ] **100% accuracy** on 15 core test dates
- [ ] **≥98% accuracy** on 100 random test dates
- [ ] All 12 lunar months have complete star data
- [ ] Good stars system fully implemented
- [ ] Extended bad stars system fully implemented
- [ ] Complete unit test coverage (≥90%)
- [ ] Performance: <100ms per date calculation
- [ ] Documentation complete
- [ ] Code review approved
- [ ] QA testing passed

**Release Gate**: App CANNOT go live until all checklist items are ✅

---

## Risk Mitigation

### Risk 1: Data Extraction Complexity
**Mitigation**:
- Break into monthly milestones
- Verify each month against xemngay before proceeding
- Consider hiring Vietnamese astrology consultant

### Risk 2: Scoring Calibration Difficulty
**Mitigation**:
- Start with simple linear scoring
- Use machine learning approach if needed (train on 1000+ xemngay examples)
- Iterate with A/B testing

### Risk 3: Book Data May Be Incomplete
**Mitigation**:
- Cross-reference with other traditional sources
- Consult with Vietnamese astrology experts
- Fall back to xemngay API if available (last resort)

---

## Alternative Approach: xemngay.com API Integration

**If available**, consider:
1. License xemngay.com data/API
2. Use as primary data source
3. Keep traditional calculation as backup/validation

**Pros**:
- Instant 100% accuracy
- No data extraction needed
- Always up-to-date

**Cons**:
- Cost/licensing
- Dependency on external service
- Requires internet connection

**Recommendation**: Investigate API availability while proceeding with traditional implementation as backup plan.

---

## Conclusion

**Current Status**: 87% accuracy with 2/6 traditional systems implemented

**Path to 100%**: Implement remaining 4 systems (good stars, extended bad stars, activities, timing)

**Critical Path**:
1. Extract complete star data from book (60-80 hours)
2. Implement good/bad stars calculators (40 hours)
3. Integrate and calibrate scoring (20 hours)
4. Test and validate to 100% (10 hours)

**Timeline**: 4-5 weeks full-time or 8-10 weeks part-time

**Release Blocker**: App cannot go live until 100% accuracy achieved on comprehensive test suite.

---

**Plan Owner**: Quang Tran Minh
**Date**: November 24, 2025
**Status**: 🚧 ROADMAP DEFINED - IMPLEMENTATION REQUIRED
**Next Action**: Begin Phase 5 (Data Extraction) immediately

import Foundation
import VietnameseLunar

// Test what lunar years appear in solar 2023
var monthsByLunarYear: [Int: Set<Int>] = [:]

let calendar = Calendar.current
var currentDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!

for _ in 0..<365 {
    let vietnameseCalendar = VietnameseCalendar(date: currentDate)
    guard let lunarDate = vietnameseCalendar.vietnameseDate else {
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        continue
    }
    
    let year = Int(lunarDate.year) ?? 2023
    let month = lunarDate.month
    
    if monthsByLunarYear[year] == nil {
        monthsByLunarYear[year] = Set()
    }
    monthsByLunarYear[year]?.insert(month)
    
    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
}

print("Solar 2023 contains lunar years:")
for (year, months) in monthsByLunarYear.sorted(by: { $0.key < $1.key }) {
    print("  Lunar year \(year): months \(months.sorted())")
    
    // Check for repeated months
    var monthCounts: [Int: Int] = [:]
    
    var testDate = calendar.date(from: DateComponents(year: 2023, month: 1, day: 1))!
    for _ in 0..<400 {
        let vietnameseCalendar = VietnameseCalendar(date: testDate)
        guard let lunarDate = vietnameseCalendar.vietnameseDate else {
            testDate = calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate
            continue
        }
        
        let lunarYear = Int(lunarDate.year) ?? 2023
        if lunarYear == year {
            monthCounts[lunarDate.month, default: 0] += 1
        }
        
        testDate = calendar.date(byAdding: .day, value: 1, to: testDate) ?? testDate
    }
    
    for (month, count) in monthCounts.sorted(by: { $0.key < $1.key }) {
        if count > 1 {
            print("    Month \(month) appears \(count) times - LEAP MONTH")
        }
    }
}

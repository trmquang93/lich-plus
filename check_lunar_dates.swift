import Foundation

// Quick check - let's see what the test expects for lunar dates
let testDates = [
    ("Nov 15, 2025", 2025, 11, 15),
    ("Nov 20, 2025", 2025, 11, 20),
    ("Nov 3, 2025", 2025, 11, 3),
    ("Dec 1, 2025", 2025, 12, 1),
]

for (name, year, month, day) in testDates {
    let dateComponents = DateComponents(year: year, month: month, day: day)
    let calendar = Calendar.current
    if let date = calendar.date(from: dateComponents) {
        print("\(name): \(date.formatted(date: .abbreviated, time: .omitted))")
    }
}

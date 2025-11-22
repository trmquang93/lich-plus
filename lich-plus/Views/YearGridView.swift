import SwiftUI
import SwiftData

// MARK: - Year Grid View
/// A modal sheet view displaying all 12 months of a selected year in a 3x4 grid.
/// Users can navigate between years and quickly jump to any month or return to today.
struct YearGridView: View {
    // MARK: - Constants
    static let minYear = 1975
    static let maxYear = 2075
    private static let gridColumns = 3
    private static let gridSpacing: CGFloat = 16

    // MARK: - Properties
    @Binding var currentDate: Date
    @Binding var isPresented: Bool
    @State private var yearDate: Date

    let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: gridColumns)

    init(currentDate: Binding<Date>, isPresented: Binding<Bool>) {
        self._currentDate = currentDate
        self._isPresented = isPresented
        self._yearDate = State(initialValue: currentDate.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Year Navigation Header
            YearPicker(
                yearDate: $yearDate,
                onPreviousYear: { goToPreviousYear() },
                onNextYear: { goToNextYear() }
            )

            // Month Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(1...12, id: \.self) { month in
                        let isCurrentMonth = isCurrentMonthAndYear(month: month, year: Calendar.current.component(.year, from: yearDate))

                        MiniMonthView(
                            month: month,
                            year: Calendar.current.component(.year, from: yearDate),
                            isCurrentMonth: isCurrentMonth,
                            action: {
                                selectMonth(month)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            // Today Button
            TodayButton(onTap: {
                jumpToToday()
            })
            .padding(.bottom, 16)
        }
        .background(Color.white)
    }

    // MARK: - Helper Methods
    /// Selects a month and updates the current date to the first day of that month.
    /// Dismisses the year grid view after selection.
    /// - Parameter month: The month number (1-12) to select
    private func selectMonth(_ month: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: yearDate)

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        if let newDate = calendar.date(from: components) {
            currentDate = newDate
            isPresented = false
        } else {
            // Fallback: dismiss sheet even if date construction fails
            // This ensures consistent UX and prevents stuck UI
            print("⚠️ Warning: Failed to construct date for month \(month), year \(year)")
            isPresented = false
        }
    }

    /// Navigates to the previous year if within allowed bounds (1975-2075).
    private func goToPreviousYear() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: yearDate)

        guard currentYear > Self.minYear else { return }

        if let newDate = calendar.date(byAdding: .year, value: -1, to: yearDate) {
            yearDate = newDate
        }
    }

    /// Navigates to the next year if within allowed bounds (1975-2075).
    private func goToNextYear() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: yearDate)

        guard currentYear < Self.maxYear else { return }

        if let newDate = calendar.date(byAdding: .year, value: 1, to: yearDate) {
            yearDate = newDate
        }
    }

    /// Jumps to the current month and dismisses the year grid view.
    private func jumpToToday() {
        currentDate = Date()
        isPresented = false
    }

    /// Checks if the given month and year match the current month and year.
    /// - Parameters:
    ///   - month: The month number (1-12) to check
    ///   - year: The year to check
    /// - Returns: True if the month and year match today's date
    private func isCurrentMonthAndYear(month: Int, year: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        return month == currentMonth && year == currentYear
    }
}

// MARK: - Year Picker
/// Navigation header for year selection with previous/next buttons.
/// Buttons are disabled when reaching year boundaries (1975-2075).
struct YearPicker: View {
    // MARK: - Properties
    @Binding var yearDate: Date
    let onPreviousYear: () -> Void
    let onNextYear: () -> Void

    var currentYear: Int {
        Calendar.current.component(.year, from: yearDate)
    }

    var canGoPrevious: Bool {
        currentYear > YearGridView.minYear
    }

    var canGoNext: Bool {
        currentYear < YearGridView.maxYear
    }

    var body: some View {
        HStack(spacing: 16) {
            // Previous Year Button
            Button(action: onPreviousYear) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(canGoPrevious ? (Color(hex: "#5BC0A6") ?? .green) : Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .disabled(!canGoPrevious)
            .accessibilityLabel("Năm trước")
            .accessibilityHint(canGoPrevious ? "Chuyển về năm \(currentYear - 1)" : "Đã đến năm tối thiểu")

            Spacer()

            // Year Display
            Text("\(currentYear)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .accessibilityLabel("Năm \(currentYear)")

            Spacer()

            // Next Year Button
            Button(action: onNextYear) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(canGoNext ? (Color(hex: "#5BC0A6") ?? .green) : Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .disabled(!canGoNext)
            .accessibilityLabel("Năm sau")
            .accessibilityHint(canGoNext ? "Chuyển tới năm \(currentYear + 1)" : "Đã đến năm tối đa")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Mini Month View
/// Individual month cell displaying Vietnamese month name.
/// Highlighted with teal border if it represents the current month and year.
struct MiniMonthView: View {
    // MARK: - Properties
    let month: Int
    let year: Int
    let isCurrentMonth: Bool
    let action: () -> Void

    /// Vietnamese month name (e.g., "Tháng Một", "Tháng Hai")
    var monthName: String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let date = calendar.date(from: components) else {
            return "Tháng \(month)"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "LLLL"

        var name = formatter.string(from: date)
        // Capitalize first letter
        name = name.prefix(1).uppercased() + name.dropFirst()

        return name
    }

    var monthLabel: String {
        "Tháng \(month)"
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(monthName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                Text(monthLabel)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 80)
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCurrentMonth ? (Color(hex: "#5BC0A6") ?? .green) : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(monthName) năm \(year)")
        .accessibilityHint(isCurrentMonth ? "Tháng hiện tại. Nhấn để xem chi tiết" : "Nhấn để xem \(monthName)")
    }
}

// MARK: - Today Button
/// Button to quickly jump to the current month and dismiss the year grid.
struct TodayButton: View {
    // MARK: - Properties
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("Hôm nay")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "#5BC0A6") ?? .green)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel("Về hôm nay")
        .accessibilityHint("Nhấn để về tháng hiện tại")
    }
}

// MARK: - Preview
#Preview {
    YearGridView(
        currentDate: .constant(Date()),
        isPresented: .constant(true)
    )
    .modelContainer(for: CalendarEvent.self, inMemory: true)
}

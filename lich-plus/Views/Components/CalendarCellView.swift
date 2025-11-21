import SwiftUI

// MARK: - Calendar Cell View
struct CalendarCellView: View {
    let day: Int?
    let lunarDay: String
    let hasEvents: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            // Solar Date (Large)
            Text(day.map(String.init) ?? "")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isCurrentMonth ? .black : .gray.opacity(0.5))
                .frame(height: 24)

            // Lunar Date (Small)
            Text(lunarDay)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(1)

            // Event Indicator
            if hasEvents {
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color(hex: "#5BC0A6") ?? .green)
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(Color(hex: "#4A90E2") ?? .blue)
                        .frame(width: 4, height: 4)
                }
                .frame(height: 4)
            } else {
                Spacer()
                    .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color(hex: "#5BC0A6")?.opacity(0.1) ?? Color.blue.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isToday ? Color(hex: "#5BC0A6") ?? .green : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .onTapGesture {
            if day != nil {
                action()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        HStack(spacing: 0) {
            CalendarCellView(day: 1, lunarDay: "15", hasEvents: false, isCurrentMonth: true, isToday: false, isSelected: false) {}
            CalendarCellView(day: 2, lunarDay: "16", hasEvents: true, isCurrentMonth: true, isToday: true, isSelected: true) {}
            CalendarCellView(day: nil, lunarDay: "", hasEvents: false, isCurrentMonth: false, isToday: false, isSelected: false) {}
        }
        .padding()
    }
}

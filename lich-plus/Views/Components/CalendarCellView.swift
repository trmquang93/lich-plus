import SwiftUI

// MARK: - Calendar Cell View
struct CalendarCellView: View {
    let viewModel: CalendarCellViewModel
    let action: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // MARK: - Background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            viewModel.todayBorderColor,
                            lineWidth: 2
                        )
                )

            // MARK: - Content
            VStack(alignment: .leading, spacing: 4) {
                // MARK: - Top Row: Solar Date + Auspicious Dots
                HStack {
                    // Solar date (top-left)
                    Text(viewModel.date.map { Calendar.current.component(.day, from: $0) }.map(String.init) ?? "")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.solarDayColor)

                    Spacer()

                    // Auspicious dots (top-right)
                    HStack(spacing: 3) {
                        if viewModel.shouldShowAuspiciousDot {
                            Circle()
                                .fill(Color(hex: "#D0021B") ?? .red)
                                .frame(width: 6, height: 6)
                        }

                        if viewModel.shouldShowInauspiciousDot {
                            Circle()
                                .fill(Color(hex: "#9B59B6") ?? .purple)
                                .frame(width: 6, height: 6)
                        }
                    }
                }

                // MARK: - Lunar Date with Can Chi
                Text(viewModel.lunarDisplayText)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(viewModel.lunarTextColor)
                    .lineLimit(1)

                Spacer()
            }
            .padding(6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .onTapGesture {
            if viewModel.date != nil {
                action()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        // MARK: - Row 1: Current Month Examples
        HStack(spacing: 0) {
            // Regular weekday with Can Chi
            CalendarCellView(
                viewModel: CalendarCellViewModel(
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 15)),
                    lunarInfo: LunarDateInfo(
                        year: 2025,
                        month: 10,
                        day: 15,
                        canChi: CanChiInfo(can: "Giáp", chi: "Tỵ")
                    ),
                    auspiciousInfo: AuspiciousDayInfo(type: .neutral),
                    isCurrentMonth: true,
                    isToday: false
                )
            ) {}

            // Mùng 1 (red text) + Today border + Auspicious dot
            CalendarCellView(
                viewModel: CalendarCellViewModel(
                    date: Date(),
                    lunarInfo: LunarDateInfo(
                        year: 2025,
                        month: 11,
                        day: 1,
                        canChi: CanChiInfo(can: "Bính", chi: "Ngọ")
                    ),
                    auspiciousInfo: AuspiciousDayInfo(type: .auspicious, reason: "Ngày tốt"),
                    isCurrentMonth: true,
                    isToday: true
                )
            ) {}

            // Saturday (cyan) with Inauspicious dot
            CalendarCellView(
                viewModel: CalendarCellViewModel(
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 22)),
                    lunarInfo: LunarDateInfo(
                        year: 2025,
                        month: 10,
                        day: 22,
                        canChi: CanChiInfo(can: "Đinh", chi: "Mùi")
                    ),
                    auspiciousInfo: AuspiciousDayInfo(type: .inauspicious, reason: "Ngày xấu"),
                    isCurrentMonth: true,
                    isToday: false
                )
            ) {}
        }

        // MARK: - Row 2: More Examples
        HStack(spacing: 0) {
            // Sunday (orange)
            CalendarCellView(
                viewModel: CalendarCellViewModel(
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 23)),
                    lunarInfo: LunarDateInfo(
                        year: 2025,
                        month: 10,
                        day: 23,
                        canChi: CanChiInfo(can: "Mậu", chi: "Thân")
                    ),
                    auspiciousInfo: AuspiciousDayInfo(type: .neutral),
                    isCurrentMonth: true,
                    isToday: false
                )
            ) {}

            // Out of month (gray)
            CalendarCellView(
                viewModel: CalendarCellViewModel(
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 30)),
                    lunarInfo: LunarDateInfo(
                        year: 2025,
                        month: 9,
                        day: 28,
                        canChi: CanChiInfo(can: "Kỷ", chi: "Dậu")
                    ),
                    auspiciousInfo: AuspiciousDayInfo(type: .neutral),
                    isCurrentMonth: false,
                    isToday: false
                )
            ) {}

            // Both auspicious and inauspicious dots (edge case)
            CalendarCellView(
                viewModel: CalendarCellViewModel(
                    date: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 20)),
                    lunarInfo: LunarDateInfo(
                        year: 2025,
                        month: 10,
                        day: 20,
                        canChi: CanChiInfo(can: "Canh", chi: "Tuất")
                    ),
                    auspiciousInfo: AuspiciousDayInfo(type: .neutral),
                    isCurrentMonth: true,
                    isToday: false
                )
            ) {}
        }

        Spacer()
    }
    .padding()
}

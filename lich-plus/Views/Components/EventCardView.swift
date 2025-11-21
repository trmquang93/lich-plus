import SwiftUI

// MARK: - Event Card View
struct EventCardView: View {
    let event: CalendarEvent
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Color Badge
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: event.color) ?? .blue)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    // Time Range or All Day
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        if event.isAllDay {
                            Text("Cả ngày")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        } else if let timeRange = event.timeRangeString {
                            Text(timeRange)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        } else if let startTime = event.startTimeString {
                            Text(startTime)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                        }
                    }

                    // Location (if available)
                    if let location = event.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)

                            Text(location)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Category Badge
                Text(event.category)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: event.color)?.opacity(0.8) ?? Color.blue.opacity(0.8))
                    .cornerRadius(4)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        EventCardView(
            event: CalendarEvent(
                title: "Họp team tuần",
                date: Date(),
                startTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()),
                endTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()),
                location: "Phòng họp A",
                category: "Họp công việc",
                color: "#5BC0A6"
            ),
            action: {}
        )

        EventCardView(
            event: CalendarEvent(
                title: "Ăn trưa với khách hàng",
                date: Date(),
                startTime: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: Date()),
                location: "Nhà hàng Việt Thắng",
                category: "Ăn trưa",
                color: "#4A90E2"
            ),
            action: {}
        )

        EventCardView(
            event: CalendarEvent(
                title: "Lễ Vu Lan",
                date: Date(),
                category: "Sự kiện văn hóa",
                color: "#F8E71C",
                isAllDay: true
            ),
            action: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

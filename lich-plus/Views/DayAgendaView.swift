import SwiftUI
import SwiftData

// MARK: - Day Agenda View
struct DayAgendaView: View {
    let date: Date
    @Binding var showEventForm: Bool
    @Binding var showDayAgenda: Bool
    @State private var selectedEvent: CalendarEvent?
    @State private var showEventDetail = false

    @Query private var allEvents: [CalendarEvent]
    @AppStorage("showRamEvents") private var showRamEvents = true
    @AppStorage("showMung1Events") private var showMung1Events = true

    var dayAgendaEvents: [CalendarEvent] {
        allEvents.filter { event in
            // First filter by date
            guard Calendar.current.isDate(event.date, inSameDayAs: date) else {
                return false
            }

            // Then filter by lunar event visibility settings
            if event.isRecurring {  // System event flag
                if event.title.contains("Rằm") && !showRamEvents {
                    return false
                }
                if event.title.contains("Mùng 1") && !showMung1Events {
                    return false
                }
            }

            return true
        }
        .sorted { (event1, event2) in
            if let time1 = event1.startTime, let time2 = event2.startTime {
                return time1 < time2
            }
            return event1.isAllDay && !event2.isAllDay
        }
    }

    var lunarDate: LunarDateInfo {
        LunarCalendarConverter.getLunarDate(for: date)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        let dayString = formatter.string(from: date)
        return dayString.prefix(1).uppercased() + dayString.dropFirst()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack(spacing: 12) {
                Button(action: { showDayAgenda = false }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Quay lại")
                    }
                    .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    Text(dateString)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)

                    Text(lunarDate.displayString)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Full Date Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Thứ \(getWeekday()), Ngày \(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)

                HStack(spacing: 4) {
                    Text("Âm lịch:")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)

                    Text(lunarDate.displayString)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.gray.opacity(0.05))

            // Events List
            if dayAgendaEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("Không có sự kiện")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)

                    Text("Thêm sự kiện mới để bắt đầu lên kế hoạch")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(dayAgendaEvents) { event in
                            EventCardView(event: event, action: {
                                selectedEvent = event
                                showEventDetail = true
                            })
                        }
                    }
                    .padding(16)
                }
            }

            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showEventDetail) {
            if let selectedEvent = selectedEvent {
                EventDetailView(event: selectedEvent, isPresented: $showEventDetail)
            }
        }
        .sheet(isPresented: $showEventForm) {
            EventFormView(isPresented: $showEventForm, initialDate: date, eventToEdit: nil)
        }
        .overlay(alignment: .bottomTrailing) {
            FloatingActionButton(action: {
                showEventForm = true
            })
            .padding()
        }
    }

    // MARK: - Helper Methods
    private func getWeekday() -> String {
        let weekdays = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"]
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekdays[weekday - 1]
    }
}

// MARK: - Preview
#Preview {
    DayAgendaView(
        date: Date(),
        showEventForm: .constant(false),
        showDayAgenda: .constant(true)
    )
    .modelContainer(for: CalendarEvent.self, inMemory: true)
}

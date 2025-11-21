import SwiftUI
import SwiftData

// MARK: - Main View
struct MainView: View {
    var body: some View {
        TabView {
            // Calendar Tab
            MonthCalendarView()
                .tabItem {
                    Label("Lịch", systemImage: "calendar")
                }

            // More features can be added here
            VStack {
                Text("Thêm tính năng sắp tới")
                    .font(.system(size: 16, weight: .semibold))
            }
            .tabItem {
                Label("Cài đặt", systemImage: "gear")
            }
        }
        .tint(Color(hex: "#5BC0A6") ?? .green)
    }
}

// MARK: - Preview
#Preview {
    MainView()
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}

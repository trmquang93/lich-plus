import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("showRamEvents") private var showRamEvents = true
    @AppStorage("showMung1Events") private var showMung1Events = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sự kiện âm lịch")) {
                    Toggle("Hiển thị Rằm", isOn: $showRamEvents)
                    Toggle("Hiển thị Mùng 1", isOn: $showMung1Events)
                }

                Section(header: Text("Thông tin")) {
                    HStack {
                        Text("Sự kiện được tạo")
                        Spacer()
                        Text("5 năm")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}

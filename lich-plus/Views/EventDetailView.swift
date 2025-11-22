import SwiftUI
import SwiftData

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: CalendarEvent
    @Binding var isPresented: Bool
    @State private var showEditForm = false
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            HStack {
                Button(action: { isPresented = false }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Quay lại")
                    }
                    .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                }

                Spacer()

                if !event.isRecurring {  // Only show for user events
                    HStack(spacing: 12) {
                        Button(action: { showEditForm = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                        }

                        Button(action: { showDeleteConfirmation = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    // System event indicator
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)

                        Text("Sự kiện hệ thống")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tiêu đề")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        Text(event.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ngày")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: event.color) ?? .blue)

                            Text(event.dateString)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                        }
                    }

                    // Time
                    if !event.isAllDay, let timeRange = event.timeRangeString {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Thời gian")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: event.color) ?? .blue)

                                Text(timeRange)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                            }
                        }
                    } else if event.isAllDay {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Thời gian")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: event.color) ?? .blue)

                                Text("Cả ngày")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    // Location
                    if let location = event.location {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Địa điểm")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)

                            HStack(spacing: 8) {
                                Image(systemName: "location")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: event.color) ?? .blue)

                                Text(location)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Danh mục")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)

                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: event.color) ?? .blue)
                                .frame(width: 4)

                            Text(event.category)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)

                            Spacer()
                        }
                    }

                    // Notes
                    if let notes = event.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ghi chú")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)

                            Text(notes)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.black)
                                .lineLimit(nil)
                        }
                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding(16)
            }

            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditForm) {
            EventFormView(isPresented: $showEditForm, initialDate: event.date, eventToEdit: event)
        }
        .alert("Xóa sự kiện", isPresented: $showDeleteConfirmation) {
            Button("Xóa", role: .destructive) {
                deleteEvent()
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Bạn chắc chắn muốn xóa '\(event.title)'?")
        }
    }

    // MARK: - Helper Methods
    private func deleteEvent() {
        modelContext.delete(event)
        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error deleting event: \(error)")
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EventDetailView(
            event: CalendarEvent(
                title: "Họp team tuần",
                date: Date(),
                startTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()),
                endTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()),
                location: "Phòng họp A",
                category: "Họp công việc",
                color: "#5BC0A6"
            ),
            isPresented: .constant(true)
        )
        .modelContainer(for: CalendarEvent.self, inMemory: true)
    }
}

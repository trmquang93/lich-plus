import SwiftUI
import SwiftData

// MARK: - Event Form View
struct EventFormView: View {
    @Binding var isPresented: Bool
    let initialDate: Date?
    let eventToEdit: CalendarEvent?

    @State private var title = ""
    @State private var date = Date()
    @State private var isAllDay = false
    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var location = ""
    @State private var category = "Họp công việc"
    @State private var notes = ""
    @State private var color = "#5BC0A6"

    @Environment(\.modelContext) var modelContext

    let categories = [
        "Họp công việc",
        "Ăn trưa",
        "Gọi điện",
        "Sự kiện văn hóa",
        "Khác"
    ]

    let colors = [
        "#5BC0A6",
        "#4A90E2",
        "#50E3C2",
        "#F5A623",
        "#D0021B",
        "#F8E71C"
    ]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Title Section
                Section(header: Text("Tiêu đề")) {
                    TextField("Nhập tiêu đề sự kiện", text: $title)
                }

                // Date Section
                Section(header: Text("Ngày")) {
                    DatePicker(
                        "Chọn ngày",
                        selection: $date,
                        displayedComponents: .date
                    )
                }

                // All Day Toggle
                Section {
                    Toggle("Cả ngày", isOn: $isAllDay)
                }

                // Time Section
                if !isAllDay {
                    Section(header: Text("Thời gian")) {
                        DatePicker(
                            "Bắt đầu",
                            selection: Binding(
                                get: { startTime ?? date },
                                set: { startTime = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )

                        DatePicker(
                            "Kết thúc",
                            selection: Binding(
                                get: { endTime ?? date },
                                set: { endTime = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                // Location Section
                Section(header: Text("Địa điểm")) {
                    TextField("Nhập địa điểm (tùy chọn)", text: $location)
                }

                // Category Section
                Section(header: Text("Danh mục")) {
                    Picker("Danh mục", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                // Color Section
                Section(header: Text("Màu sắc")) {
                    HStack(spacing: 8) {
                        ForEach(colors, id: \.self) { colorHex in
                            Button(action: { color = colorHex }) {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                color == colorHex ? Color.black : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                        Spacer()
                    }
                }

                // Notes Section
                Section(header: Text("Ghi chú")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle(eventToEdit != nil ? "Chỉnh sửa sự kiện" : "Tạo sự kiện")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Lưu") {
                        saveEvent()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let eventToEdit = eventToEdit {
                    // Prevent editing system events
                    if eventToEdit.isRecurring {
                        // This is a system event, close the form immediately
                        isPresented = false
                        return
                    }
                    loadEvent(eventToEdit)
                } else if let initialDate = initialDate {
                    date = initialDate
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func loadEvent(_ event: CalendarEvent) {
        title = event.title
        date = event.date
        isAllDay = event.isAllDay
        startTime = event.startTime
        endTime = event.endTime
        location = event.location ?? ""
        category = event.category
        notes = event.notes ?? ""
        color = event.color
    }

    private func saveEvent() {
        if eventToEdit != nil {
            updateEvent()
        } else {
            createEvent()
        }
    }

    private func createEvent() {
        let newEvent = CalendarEvent(
            title: title,
            date: date,
            startTime: isAllDay ? nil : startTime,
            endTime: isAllDay ? nil : endTime,
            location: location.isEmpty ? nil : location,
            category: category,
            notes: notes.isEmpty ? nil : notes,
            color: color,
            isAllDay: isAllDay
        )

        modelContext.insert(newEvent)

        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error saving event: \(error)")
        }
    }

    private func updateEvent() {
        guard let eventToEdit = eventToEdit else { return }

        eventToEdit.title = title
        eventToEdit.date = date
        eventToEdit.isAllDay = isAllDay
        eventToEdit.startTime = isAllDay ? nil : startTime
        eventToEdit.endTime = isAllDay ? nil : endTime
        eventToEdit.location = location.isEmpty ? nil : location
        eventToEdit.category = category
        eventToEdit.notes = notes.isEmpty ? nil : notes
        eventToEdit.color = color

        do {
            try modelContext.save()
            isPresented = false
        } catch {
            print("Error updating event: \(error)")
        }
    }
}

// MARK: - Preview
#Preview {
    EventFormView(isPresented: .constant(true), initialDate: Date(), eventToEdit: nil)
        .modelContainer(for: CalendarEvent.self, inMemory: true)
}

//
//  DatePickerSheet.swift
//  lich-plus
//
//  Modal sheet for date and time selection
//

import SwiftUI

struct DatePickerSheet: View {
    let title: String
    @Binding var selectedDate: Date
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "task.done")) {
                        onDone()
                    }
                    .foregroundStyle(AppColors.primary)
                }
            }
        }
    }
}

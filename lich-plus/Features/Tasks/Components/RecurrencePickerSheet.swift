//
//  RecurrencePickerSheet.swift
//  lich-plus
//
//  Modal sheet for recurrence selection
//

import SwiftUI

struct RecurrencePickerSheet: View {
    @Binding var selectedRecurrence: RecurrenceType
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                    Button {
                        selectedRecurrence = recurrence
                    } label: {
                        HStack {
                            Text(recurrence.displayName)
                                .foregroundStyle(AppColors.textPrimary)

                            Spacer()

                            if selectedRecurrence == recurrence {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "createItem.recurrence"))
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

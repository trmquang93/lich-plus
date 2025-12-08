//
//  RecurrencePickerSheet.swift
//  lich-plus
//
//  Modal sheet for recurrence selection with all recurrence options
//

import SwiftUI

// MARK: - RecurrencePickerSheet

struct RecurrencePickerSheet: View {
    @Binding var selectedRecurrence: RecurrenceType
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Recurrence List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                            VStack(spacing: 0) {
                                Button {
                                    selectedRecurrence = recurrence
                                } label: {
                                    HStack(spacing: AppTheme.spacing12) {
                                        Text(recurrence.displayName)
                                            .font(.system(size: AppTheme.fontBody))
                                            .foregroundStyle(AppColors.textPrimary)

                                        Spacer()

                                        if selectedRecurrence == recurrence {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundStyle(AppColors.primary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, AppTheme.spacing16)
                                    .padding(.vertical, AppTheme.spacing12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .background(AppColors.borderLight)
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

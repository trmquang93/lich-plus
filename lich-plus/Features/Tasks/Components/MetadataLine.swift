//
//  MetadataLine.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 26/11/25.
//

import SwiftUI

/// A horizontal metadata display showing date, time (if available), and category information.
///
/// This component displays a compact line of metadata for a task or event:
/// - Calendar icon and formatted date (e.g., "Nov 24, 2025")
/// - Optional separator dot and time (e.g., "2:30 PM") if startTime is provided
/// - Category color dot indicator
///
/// Text color adapts based on completion status.
struct MetadataLine: View {
    let item: TaskItem
    let isCompleted: Bool

    private var textColor: Color {
        isCompleted ? AppColors.textDisabled : AppColors.textSecondary
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private var formattedTime: String? {
        guard let startTime = item.startTime else { return nil }
        return Self.timeFormatter.string(from: startTime)
    }

    var body: some View {
        HStack(spacing: AppTheme.spacing4) {
            // MARK: - Date with Calendar Icon

            Image(systemName: "calendar")
                .metadataStyle(color: textColor)

            Text(item.dateDisplay)
                .metadataStyle(color: textColor)

            // MARK: - Time (if available)

            if item.isAllDay {
                Text("·")
                    .metadataStyle(color: textColor)

                Text(String(localized: "event.allDay"))
                    .metadataStyle(color: textColor)
            } else if let timeString = formattedTime {
                Text("·")
                    .metadataStyle(color: textColor)

                Text(timeString)
                    .metadataStyle(color: textColor)
            }

            // MARK: - Category Color Dot

            Text("·")
                .metadataStyle(color: textColor)

            Circle()
                .fill(item.category.colorValue)
                .frame(width: AppTheme.categoryDotSize, height: AppTheme.categoryDotSize)
        }
    }
}

// MARK: - Custom View Modifier

private struct MetadataTextStyle: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: AppTheme.fontCaption, weight: .regular))
            .foregroundColor(color)
    }
}

extension View {
    fileprivate func metadataStyle(color: Color) -> some View {
        modifier(MetadataTextStyle(color: color))
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing20) {
        // MARK: - With Time

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("With Time")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            MetadataLine(
                item: TaskItem(
                    title: "Team Meeting",
                    date: Date(),
                    startTime: Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!,
                    category: .meeting,
                    itemType: .task
                ),
                isCompleted: false
            )
        }

        // MARK: - Without Time (Regular Task)

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Without Time (Regular Task)")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            MetadataLine(
                item: TaskItem(
                    title: "Project deadline",
                    date: Date(),
                    category: .work,
                    itemType: .task
                ),
                isCompleted: false
            )
        }

        // MARK: - All Day Event

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("All Day Event")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            MetadataLine(
                item: TaskItem(
                    title: "Holiday celebration",
                    date: Date(),
                    category: .holiday,
                    itemType: .event
                ),
                isCompleted: false
            )
        }

        // MARK: - Different Categories

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Work Category")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            MetadataLine(
                item: TaskItem(
                    title: "Conference call",
                    date: Date(),
                    startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())!,
                    category: .work,
                    itemType: .event
                ),
                isCompleted: false
            )
        }

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Birthday Category")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            MetadataLine(
                item: TaskItem(
                    title: "Sarah's Birthday",
                    date: Date(timeIntervalSinceNow: 86400),
                    category: .birthday,
                    itemType: .event
                ),
                isCompleted: false
            )
        }

        // MARK: - Completed State

        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text("Completed (Lighter Text)")
                .font(.system(size: AppTheme.fontSubheading, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            MetadataLine(
                item: TaskItem(
                    title: "Finished task",
                    date: Date(),
                    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
                    category: .personal,
                    isCompleted: true,
                    itemType: .task
                ),
                isCompleted: true
            )
        }

        Spacer()
    }
    .padding()
}

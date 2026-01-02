//
//  DayDetailView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 25/11/25.
//

import SwiftData
import SwiftUI

// MARK: - Day Detail View

struct DayDetailView: View {
    let day: CalendarDay
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var syncService: CalendarSyncService
    @State private var showAddEventSheet: Bool = false

    private var dayQuality: DayQuality {
        HoangDaoCalculator.determineDayQuality(for: day.date)
    }

    private var hourlyZodiacs: [HourlyZodiac] {
        HoangDaoCalculator.getHourlyZodiacs(for: day.date)
    }

    private var luckyHours: [HourlyZodiac] {
        hourlyZodiacs.filter { $0.isAuspicious }
    }

    private var unluckyHours: [HourlyZodiac] {
        hourlyZodiacs.filter { !$0.isAuspicious }
    }

    // MARK: - Formatted Date Properties

    private var formattedSolarDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: day.date)
    }

    private var formattedLunarDate: String {
        let yearCanChi = CanChiCalculator.calculateYearCanChi(lunarYear: day.lunarYear)
        return "Ngày \(day.lunarDay) tháng \(day.lunarMonth) năm \(yearCanChi.displayName)"
    }

    private var formattedLuckyHours: String {
        luckyHours.map { hour in
            let chi = hour.chi
            let range = chi.hourRange
            let startTime = chi == .ty ? "23" : "\(range.start)"
            let endTime = chi == .ty ? "1" : "\(range.end)"
            return "\(chi.vietnameseName) (\(startTime)-\(endTime))"
        }.joined(separator: ", ")
    }

    private var formattedUnluckyHours: String {
        unluckyHours.map { hour in
            let chi = hour.chi
            let range = chi.hourRange
            let startTime = chi == .ty ? "23" : "\(range.start)"
            let endTime = chi == .ty ? "1" : "\(range.end)"
            return "\(chi.vietnameseName) (\(startTime)-\(endTime))"
        }.joined(separator: ", ")
    }

    private var qualityTitleColor: Color {
        switch dayQuality.finalQuality {
        case .good: return AppColors.accent
        case .bad: return AppColors.primary
        case .neutral: return AppColors.textSecondary
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing16) {
                // Day quality card
                dayQualityCard

                // Events card
                eventsCard

                // 12 Truc section
                trucCard

                // Stars sections (if available)
                if let goodStars = dayQuality.goodStars, !goodStars.isEmpty {
                    starsCard(
                        title: "Sao tốt",
                        stars: goodStars.map { $0.rawValue },
                        isGood: true
                    )
                }

                if let badStars = dayQuality.badStars, !badStars.isEmpty {
                    starsCard(
                        title: "Sao xấu",
                        stars: badStars.map { $0.rawValue },
                        isGood: false
                    )
                }

                // Activities sections
                activitiesCard

                // Lucky info section
                luckyInfoCard
            }
            .padding(AppTheme.spacing16)
        }
        .background(AppColors.backgroundLightGray)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                headerSection
            }
        }
        .sheet(isPresented: $showAddEventSheet) {
            CreateItemSheet(
                initialItemType: .event,
                onSave: { _ in showAddEventSheet = false }
            )
            .environmentObject(syncService)
            .modelContext(modelContext)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: AppTheme.spacing4) {
            Text(formattedSolarDate)
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            Text(formattedLunarDate)
                .font(.system(size: AppTheme.fontCaption))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Helper Views

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
            Text(title)
                .font(.system(size: AppTheme.fontBody, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            Text(value)
                .font(.system(size: AppTheme.fontCaption))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func eventColor(for category: EventCategory) -> Color {
        switch category {
        case .work: return AppColors.primary
        case .personal: return AppColors.eventBlue
        case .birthday: return AppColors.eventPink
        case .holiday: return AppColors.eventOrange
        case .meeting: return AppColors.accent
        case .other: return AppColors.secondary
        }
    }

    // MARK: - Day Quality Card

    private var dayQualityCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            // Quality Title
            Text(dayQuality.finalQuality.displayName)
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(qualityTitleColor)

            // Lucky Hours
            if !formattedLuckyHours.isEmpty {
                infoRow(title: "Giờ hoàng đạo", value: formattedLuckyHours)
            }

            // Unlucky Hours
            if !formattedUnluckyHours.isEmpty {
                infoRow(title: "Giờ hắc đạo", value: formattedUnluckyHours)
            }

            // Lucky Direction
            if let direction = dayQuality.luckyDirection, !direction.isEmpty {
                infoRow(title: "Hướng tốt", value: direction)
            }

            // Suitable Activities
            if !dayQuality.suitableActivities.isEmpty {
                infoRow(
                    title: "Việc nên làm",
                    value: dayQuality.suitableActivities.joined(separator: ", ")
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Events Card

    private var eventsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            // Header with icon and add button
            HStack {
                HStack(spacing: AppTheme.spacing8) {
                    Image(systemName: "calendar")
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                    Text("Sự kiện")
                        .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
                Button(action: { showAddEventSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.white)
                        .frame(width: 28, height: 28)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }
            }

            // Events list or empty state
            if day.events.isEmpty {
                Text("Không có sự kiện nào")
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.spacing16)
            } else {
                VStack(spacing: AppTheme.spacing12) {
                    ForEach(day.events) { event in
                        eventRow(event)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func eventRow(_ event: Event) -> some View {
        HStack(spacing: AppTheme.spacing12) {
            // Color indicator bar
            RoundedRectangle(cornerRadius: 2)
                .fill(eventColor(for: event.category))
                .frame(width: 4, height: 50)

            // Event details
            VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                Text(event.title)
                    .font(.system(size: AppTheme.fontBody, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(event.isAllDay ? String(localized: "event.allDay") : (event.time ?? ""))
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
                if let description = event.description {
                    Text(description)
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.secondary)
        }
        .padding(AppTheme.spacing12)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    // MARK: - 12 Truc Card

    private var trucCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text("12 Trực")
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                // Truc name with quality
                HStack(spacing: AppTheme.spacing8) {
                    Text(dayQuality.zodiacHour.vietnameseName)
                        .font(.system(size: AppTheme.fontBody, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(qualityLabel)
                        .font(.system(size: AppTheme.fontCaption, weight: .medium))
                        .padding(.horizontal, AppTheme.spacing8)
                        .padding(.vertical, AppTheme.spacing4)
                        .background(qualityLabelColor)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                        .foregroundStyle(AppColors.white)
                }

                // Description
                Text(dayQuality.zodiacHour.fullDescription)
                    .font(.system(size: AppTheme.fontCaption))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Stars Card

    private func starsCard(title: String, stars: [String], isGood: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(title)
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(isGood ? AppColors.accent : AppColors.primary)

            Text(stars.joined(separator: ", "))
                .font(.system(size: AppTheme.fontCaption))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Activities Card

    private var activitiesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing16) {
            // Suitable activities
            if !dayQuality.suitableActivities.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                    Text("Việc nên làm")
                        .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                        .foregroundStyle(AppColors.accent)

                    Text(dayQuality.suitableActivities.joined(separator: ", "))
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppTheme.spacing16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.accentLight)
                .cornerRadius(AppTheme.cornerRadiusLarge)
            }

            // Taboo activities
            if !dayQuality.tabooActivities.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                    Text("Việc nên tránh")
                        .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                        .foregroundStyle(AppColors.primary)

                    Text(dayQuality.tabooActivities.joined(separator: ", "))
                        .font(.system(size: AppTheme.fontCaption))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(AppTheme.spacing16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 255 / 255, green: 244 / 255, blue: 244 / 255))
                .cornerRadius(AppTheme.cornerRadiusLarge)
            }
        }
    }

    // MARK: - Lucky Info Card

    private var luckyInfoCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text("Thông tin may mắn")
                .font(.system(size: AppTheme.fontTitle3, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                // Lucky direction
                if let direction = dayQuality.luckyDirection, !direction.isEmpty {
                    HStack(spacing: AppTheme.spacing12) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.accent)
                        VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                            Text("Hướng may mắn")
                                .font(.system(size: AppTheme.fontCaption))
                                .foregroundStyle(AppColors.textSecondary)
                            Text(direction)
                                .font(.system(size: AppTheme.fontBody, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                        Spacer()
                    }
                }

                // Lucky color
                if let color = dayQuality.luckyColor, !color.isEmpty {
                    HStack(spacing: AppTheme.spacing12) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.accent)
                        VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                            Text("Màu may mắn")
                                .font(.system(size: AppTheme.fontCaption))
                                .foregroundStyle(AppColors.textSecondary)
                            Text(color)
                                .font(.system(size: AppTheme.fontBody, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing16)
        .background(AppColors.background)
        .cornerRadius(AppTheme.cornerRadiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Computed Properties

    private var qualityLabel: String {
        switch dayQuality.zodiacHour.quality {
        case .veryAuspicious: return "Hoàng Đạo"
        case .neutral: return "Khả Dụng"
        case .inauspicious: return "Hắc Đạo"
        case .severelyInauspicious: return "Rất Hung"
        }
    }

    private var qualityLabelColor: Color {
        switch dayQuality.zodiacHour.quality {
        case .veryAuspicious: return AppColors.accent
        case .neutral: return AppColors.secondary
        case .inauspicious: return AppColors.primary
        case .severelyInauspicious: return Color(red: 220 / 255, green: 53 / 255, blue: 69 / 255)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SyncableEvent.self, configurations: config)
    let modelContext = ModelContext(container)
    let eventKitService = EventKitService()
    let syncService = CalendarSyncService(
        eventKitService: eventKitService,
        modelContext: modelContext
    )

    let mockDay = CalendarDay(
        date: Date(),
        solarDay: 5,
        solarMonth: 12,
        solarYear: 2025,
        lunarDay: 15,
        lunarMonth: 10,
        lunarYear: 2025,
        dayType: .good,
        isCurrentMonth: true,
        isToday: true,
        events: [
            Event(
                syncableEventId: nil,
                title: "Weekly Team Sync",
                time: "10:00",
                isAllDay: false,
                category: .meeting,
                description: "Online - Google Meet"
            ),
            Event(
                syncableEventId: nil,
                title: "Design Review",
                time: "14:00",
                isAllDay: false,
                category: .work,
                description: "Meeting Room 4B"
            ),
            Event(
                syncableEventId: nil,
                title: "Dinner with Family",
                time: "19:00",
                isAllDay: false,
                category: .personal,
                description: "Pizza 4P's Restaurant"
            ),
        ],
        isWeekend: false
    )

    NavigationStack {
        DayDetailView(day: mockDay)
    }
    .environmentObject(syncService)
    .modelContainer(container)
}

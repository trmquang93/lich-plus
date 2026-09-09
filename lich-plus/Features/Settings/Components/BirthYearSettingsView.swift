//
//  BirthYearSettingsView.swift
//  lich-plus
//
//  Local-only birth year for tuổi hợp/xung. Never uploaded or logged.
//

import SwiftUI

struct BirthYearSettingsView: View {
    @ObservedObject private var birthYearStore = BirthYearStore.shared
    @State private var draftYear: Int = Calendar.current.component(.year, from: Date()) - 30
    @State private var isEnabled: Bool = false

    private var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 100)...current).reversed()
    }

    var body: some View {
        Form {
            Section {
                Toggle(String(localized: "Use birth year"), isOn: $isEnabled)
                    .onChange(of: isEnabled) { _, enabled in
                        if enabled {
                            birthYearStore.setBirthYear(draftYear)
                        } else {
                            birthYearStore.setBirthYear(nil)
                        }
                        AnalyticsService.shared.logFeatureUsed(.birth_year_setting)
                    }

                if isEnabled {
                    Picker(String(localized: "Birth year"), selection: $draftYear) {
                        ForEach(yearRange, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .onChange(of: draftYear) { _, year in
                        birthYearStore.setBirthYear(year)
                    }

                    if let birthYear = birthYearStore.birthYear {
                        let canChi = TuoiHopXungCalculator.birthYearCanChi(for: birthYear)
                        LabeledContent(String(localized: "Your Can-Chi year")) {
                            Text(canChi.displayName)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            } header: {
                Text(String(localized: "Birth Year"))
            } footer: {
                Text(String(localized: "Stored on this device only. Used for ngày xung tuổi and Ngũ hành hints in xem ngày. Never uploaded or sent to analytics."))
            }
        }
        .navigationTitle(String(localized: "Birth Year"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let stored = birthYearStore.birthYear {
                isEnabled = true
                draftYear = stored
            }
        }
    }
}

#Preview {
    NavigationStack {
        BirthYearSettingsView()
    }
}

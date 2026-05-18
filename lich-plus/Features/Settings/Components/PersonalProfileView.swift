//
//  PersonalProfileView.swift
//  lich-plus
//

import SwiftUI
import SwiftData

/// Edits the user's personal profile (tín chủ info) used to prefill văn khấn.
struct PersonalProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [PersonalProfile]

    @State private var showAddDeceasedSheet = false

    private var profile: PersonalProfile {
        if let existing = profiles.first { return existing }
        let new = PersonalProfile()
        modelContext.insert(new)
        return new
    }

    var body: some View {
        Form {
            tinChuSection
            familySection
            deceasedSection
        }
        .navigationTitle(String(localized: "Personal Profile"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddDeceasedSheet) {
            DeceasedRelativeEditor(profile: profile)
        }
    }

    // MARK: - Tín chủ

    private var tinChuSection: some View {
        Section {
            TextField(String(localized: "Full name"), text: bindString(\.fullName))
            TextField(
                String(localized: "Address"),
                text: bindString(\.address),
                axis: .vertical
            )
            .lineLimit(2...4)

            Picker(String(localized: "Gender"), selection: bindOptionalString(\.gender)) {
                Text(String(localized: "Male")).tag(String?("nam"))
                Text(String(localized: "Female")).tag(String?("nữ"))
            }
            .pickerStyle(.segmented)

            DatePicker(
                String(localized: "Date of birth"),
                selection: bindOptionalDate(\.dateOfBirth, default: Date()),
                displayedComponents: .date
            )
        } header: {
            Text(String(localized: "Tín chủ (You)"))
        }
    }

    // MARK: - Family

    private var familySection: some View {
        Section {
            TextField(String(localized: "Spouse name"), text: bindOptionalString(\.spouseName, default: ""))
            stringListEditor(
                title: String(localized: "Children"),
                values: profile.childrenNames,
                set: { profile.childrenNames = $0; save() }
            )
            stringListEditor(
                title: String(localized: "Parents"),
                values: profile.parentsNames,
                set: { profile.parentsNames = $0; save() }
            )
        } header: {
            Text(String(localized: "Family"))
        }
    }

    // MARK: - Deceased

    private var deceasedSection: some View {
        Section {
            ForEach(profile.deceasedRelatives) { r in
                HStack(spacing: AppTheme.spacing12) {
                    ZStack {
                        Circle().fill(AppColors.vkBrownTint)
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AppColors.lunarAccent)
                    }
                    .frame(width: 38, height: 38)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(r.relation) \(r.name)")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(String(format: String(localized: "giỗ %d/%d ÂL"), r.lunarDay, r.lunarMonth))
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .onDelete { offsets in
                for i in offsets {
                    let r = profile.deceasedRelatives[i]
                    profile.deceasedRelatives.removeAll { $0.id == r.id }
                    modelContext.delete(r)
                }
                save()
            }

            Button {
                showAddDeceasedSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.primary)
                    Text(String(localized: "Add deceased relative"))
                        .foregroundStyle(AppColors.primary)
                }
            }
        } header: {
            Text(String(localized: "Deceased relatives"))
        } footer: {
            Text(String(localized: "Used to surface giỗ (death anniversary) văn khấn on the matching lunar date."))
        }
    }

    // MARK: - Helpers

    private func save() {
        profile.updatedAt = Date()
        try? modelContext.save()
    }

    private func bindString(_ keyPath: ReferenceWritableKeyPath<PersonalProfile, String>) -> Binding<String> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0; save() }
        )
    }

    private func bindOptionalString(_ keyPath: ReferenceWritableKeyPath<PersonalProfile, String?>, default defaultValue: String = "") -> Binding<String> {
        Binding(
            get: { profile[keyPath: keyPath] ?? defaultValue },
            set: { profile[keyPath: keyPath] = $0.isEmpty ? nil : $0; save() }
        )
    }

    private func bindOptionalString(_ keyPath: ReferenceWritableKeyPath<PersonalProfile, String?>) -> Binding<String?> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0; save() }
        )
    }

    private func bindOptionalDate(_ keyPath: ReferenceWritableKeyPath<PersonalProfile, Date?>, default defaultValue: Date) -> Binding<Date> {
        Binding(
            get: { profile[keyPath: keyPath] ?? defaultValue },
            set: { profile[keyPath: keyPath] = $0; save() }
        )
    }

    @ViewBuilder
    private func stringListEditor(title: String, values: [String], set: @escaping ([String]) -> Void) -> some View {
        DisclosureGroup(title) {
            ForEach(Array(values.enumerated()), id: \.offset) { idx, value in
                TextField("", text: Binding(
                    get: { value },
                    set: { newValue in
                        var copy = values
                        copy[idx] = newValue
                        set(copy)
                    }
                ))
            }
            .onDelete { offsets in
                var copy = values
                copy.remove(atOffsets: offsets)
                set(copy)
            }

            Button {
                set(values + [""])
            } label: {
                Label(String(localized: "Add"), systemImage: "plus")
            }
        }
    }
}

// MARK: - Add-deceased sheet

private struct DeceasedRelativeEditor: View {
    let profile: PersonalProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var relation: String = ""
    @State private var name: String = ""
    @State private var lunarDay: Int = 1
    @State private var lunarMonth: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "Relation (ông, bà, bố, mẹ, …)"), text: $relation)
                TextField(String(localized: "Name"), text: $name)
                Stepper(value: $lunarDay, in: 1...30) {
                    Text(String(format: String(localized: "Lunar day: %d"), lunarDay))
                }
                Stepper(value: $lunarMonth, in: 1...12) {
                    Text(String(format: String(localized: "Lunar month: %d"), lunarMonth))
                }
            }
            .navigationTitle(String(localized: "Add deceased"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        let r = DeceasedRelative(
                            relation: relation,
                            name: name,
                            lunarDay: lunarDay,
                            lunarMonth: lunarMonth
                        )
                        modelContext.insert(r)
                        profile.deceasedRelatives.append(r)
                        profile.updatedAt = Date()
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PersonalProfileView()
            .modelContainer(PersistenceController.preview.container)
    }
}

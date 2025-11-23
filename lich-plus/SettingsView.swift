//
//  SettingsView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("⚙️ Cài đặt")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                VStack(spacing: 16) {
                    Text("Settings View")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Configure app preferences and user settings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Cài đặt")
        }
    }
}

#Preview {
    SettingsView()
}

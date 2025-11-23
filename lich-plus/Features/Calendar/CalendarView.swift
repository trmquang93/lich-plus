//
//  CalendarView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("📅 Lịch")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                VStack(spacing: 16) {
                    Text("Calendar View")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Monthly calendar with Vietnamese lunar calendar support")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Lịch")
        }
    }
}

#Preview {
    CalendarView()
}

//
//  TasksView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct TasksView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("✓ Việc")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                VStack(spacing: 16) {
                    Text("Tasks View")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Create, edit, and manage your tasks and events")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Việc")
        }
    }
}

#Preview {
    TasksView()
}

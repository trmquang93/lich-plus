//
//  HoangDaoIndicator.swift
//  lich-plus
//
//  Gold star indicator component showing auspicious hour level
//

import SwiftUI

struct HoangDaoIndicator: View {
    let level: Int  // 0, 1, or 2 stars

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<level, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.hoangDaoGold)
            }
        }
        .frame(height: 12)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 20) {
            VStack(alignment: .center, spacing: 8) {
                HoangDaoIndicator(level: 0)
                Text("No Stars")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            VStack(alignment: .center, spacing: 8) {
                HoangDaoIndicator(level: 1)
                Text("1 Star")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            VStack(alignment: .center, spacing: 8) {
                HoangDaoIndicator(level: 2)
                Text("2 Stars")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(AppColors.background)
    }
}

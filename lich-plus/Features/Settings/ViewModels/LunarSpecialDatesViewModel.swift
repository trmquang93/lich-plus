//
//  LunarSpecialDatesViewModel.swift
//  lich-plus
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class LunarSpecialDatesViewModel: ObservableObject {
    private let service: LunarSpecialDateService

    @Published private(set) var isProcessing = false
    @Published private(set) var error: Error?

    init(service: LunarSpecialDateService) {
        self.service = service
    }

    func isEnabled(_ specialDate: LunarSpecialDate) -> Bool {
        service.isEnabled(specialDate)
    }

    func toggle(_ specialDate: LunarSpecialDate, enabled: Bool) {
        isProcessing = true
        error = nil

        do {
            if enabled {
                try service.enableSpecialDate(specialDate)
            } else {
                try service.disableSpecialDate(specialDate)
            }
        } catch {
            self.error = error
        }

        isProcessing = false
    }
}

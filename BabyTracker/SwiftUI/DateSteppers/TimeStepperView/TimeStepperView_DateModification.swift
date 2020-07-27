//
//  TimeStepperView_DateModification.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Functions to help managing the target date
extension TimeStepperView {
    func updateTargetDate() {
        targetDate = .init(Date.apply(adjustmentComponents, to: targetDate.date))
    }
    
    func dateIsModified() -> Bool {
        let dayAdjustment = adjustmentComponents.day ?? 0
        let monAdjustment = adjustmentComponents.month ?? 0
        let highestDiff = max(abs(dayAdjustment), abs(monAdjustment))
        return highestDiff != 0
    }
}

//
//  BabyEventType_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

extension BabyEventType: CardHeaderProvider {
    
    var displayTitle: String {
        switch self {
        case .feed:
            return "Feedings"
        case .diaper:
            return "Diapers"
        case .nap:
            return "Naps"
        case .weight:
            return "Weight"
        case .tummyTime:
            return "Tummy Times"
        case .custom:
            return "Event"
        }
    }
    
    var imageName: String {
        switch self {
        case .feed:
            return "BreastFeeding"
        case .diaper:
            return "Diaper"
        case .nap:
            return "Napping"
        case .weight:
            return "Scale"
        case .tummyTime:
            return "TummyTime"
        case .custom:
            return "Event"
        }
    }
    
    var colorValue: Color {
        switch self {
        case .feed:
            return .init(.systemYellow)
        case .diaper:
            return .init(.systemBlue)
        case .nap:
            return .init(.systemPurple)
        case .weight:
            return .init(.systemOrange)
        case .tummyTime:
            return .init(.systemGreen)
        case .custom:
            return .init(.systemPink)
        }
    }
}

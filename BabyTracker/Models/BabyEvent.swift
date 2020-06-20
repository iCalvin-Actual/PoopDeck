//
//  Models.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation
import SwiftUI

typealias BreastSide = FeedEvent.Source.BreastSide

// MARK: - Baby Event Type

// MARK: - Baby Event
protocol BabyEvent: Identifiable, Codable, Equatable {
    static var type: BabyEventType { get }
    static var new: Self { get }
    
    var id: UUID { get set }
    var date: Date { get set }
}

// MARK: Display
extension BabyEventType {
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
            return .yellow
        case .diaper:
            return .blue
        case .nap:
            return .purple
        case .weight:
            return .orange
        case .tummyTime:
            return .green
        case .custom:
            return .pink
        }
    }
}

extension FeedEvent.Source {
    var displayTitle: String {
        switch self {
        case .bottle:
            return "Bottle Feedings"
        case .breast:
            return "Breast Feedings"
        }
    }
    var imageName: String {
        switch self {
        case .bottle:
            return "Bottle"
        case .breast:
            return "BreastFeeding"
        }
    }
}

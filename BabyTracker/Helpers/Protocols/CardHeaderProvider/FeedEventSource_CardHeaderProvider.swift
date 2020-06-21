//
//  FeedEventSource_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

extension FeedEvent.Source: CardHeaderProvider {
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
    
    var colorValue: Color {
        switch self {
        case .bottle:
            return .init(.systemYellow)
        case .breast:
            return .init(.systemRed)
        }
    }
}

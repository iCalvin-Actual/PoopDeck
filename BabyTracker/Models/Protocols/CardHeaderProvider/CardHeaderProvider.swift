//
//  CardHeaderProvider.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Display values to use when showing event cards
protocol CardHeaderProvider {
    var displayTitle: String { get }
    var imageName: String { get }
    var colorValue: Color { get }
}

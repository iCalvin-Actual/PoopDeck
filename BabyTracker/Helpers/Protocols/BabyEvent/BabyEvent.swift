//
//  Models.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation
import SwiftUI

/// Shared components of all recorded events
protocol BabyEvent: Identifiable, Codable, Equatable {
    static var type: BabyEventType { get }
    static var new: Self { get }
    
    var id: UUID { get set }
    var date: Date { get set }
}

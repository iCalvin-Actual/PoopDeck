//
//  BabyEventStore.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// May want to refactor into a single dictionary, but this works for now
struct BabyEventStore: Codable {
    var feedings:       [UUID: FeedEvent] = [:]
    var changes:        [UUID: DiaperEvent] = [:]
    var naps:           [UUID: NapEvent] = [:]
    var weighIns:       [UUID: WeightEvent] = [:]
    var tummyTimes:     [UUID: TummyTimeEvent] = [:]
    var customEvents:   [UUID: CustomEvent] = [:]
}

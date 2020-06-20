//
//  BabyEventType.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

enum BabyEventType: String {
    case feed
    case diaper
    case nap
    case weight
    case tummyTime
    case custom
}

extension BabyEventType: Equatable, Codable, CaseIterable { }

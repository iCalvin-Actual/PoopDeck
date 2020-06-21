//
//  BabyLogArchive.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Struct to cache document contents to disk
struct BabyLogArchive: Codable {
    let baby: Baby
    let eventStore: BabyEventStore
    
    init(_ log: BabyLog) {
        self.baby = log.baby
        self.eventStore = log.eventStore
    }
    init(_ baby: Baby) {
        self.baby = baby
        self.eventStore = .init()
    }
}


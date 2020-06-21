//
//  FeedEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Typealias speeds access to deep nested enum
typealias BreastSide = FeedEvent.Source.BreastSide


struct FeedEvent: MeasuredBabyEvent {
    static var type: BabyEventType = .feed
    static var new: FeedEvent {
        /// Default to an unmeasured breastfeed with both breasts
        return FeedEvent(source: .breast(.both))
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var source: Source
    var measurement: Measurement<Unit>?
}

//
//  Models.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

protocol BabyEventType: Identifiable {
    var id: UUID { get }
    var date: Date { get }
}

enum BabyEvent: Identifiable {
    case feed(_: FeedEvent)
    case diaper(_: DiaperEvent)
    case nap(_: NapEvent)
    case fuss(_: FussEvent)
    case weight(_: WeightEvent)
    case tummyTime(_: TummyTimeEvent)
    case custom(_: CustomEvent)
    
    var id: UUID {
        switch self {
        case .feed(let event):
            return event.id
        case .diaper(let event):
            return event.id
        case .nap(let event):
            return event.id
        case .fuss(let event):
            return event.id
        case .weight(let event):
            return event.id
        case .tummyTime(let event):
            return event.id
        case .custom(let event):
            return event.id
        }
    }
}

struct FeedEvent: BabyEventType {
    enum Source {
        case breast(_ event: BreastFeedEvent)
        case bottle(size: Measurement<UnitVolume>)
        
        struct BreastFeedEvent {
            enum Side {
                case left
                case right
                case both
            }
            
            var side: Side?
            var preWeight: Measurement<UnitMass>?
            var postWeight: Measurement<UnitMass>?
        }
    }
    
    var id = UUID()
    var source: Source
    var date: Date = Date()
}

struct DiaperEvent: BabyEventType {
    var id = UUID()
    var pee: Bool = false
    var poop: Bool = false
    var date: Date = Date()
}

struct NapEvent: BabyEventType {
    var id = UUID()
    var held: Bool = false
    var interruptions: Int = 0
    var date: Date = Date()
    var duration: TimeInterval = 300
}

struct FussEvent: BabyEventType {
    var id = UUID()
    var date: Date = Date()
    var duration: TimeInterval = 300
}

struct TummyTimeEvent: BabyEventType {
    var id = UUID()
    var date: Date = Date()
    var duration: TimeInterval = 300
}

struct WeightEvent: BabyEventType {
    var id = UUID()
    var weight: Measurement<UnitMass>
    var date: Date = Date()
    var clothed: Bool = false
}

struct CustomEvent: BabyEventType {
    var id = UUID()
    var event: String
    var date: Date = Date()
}

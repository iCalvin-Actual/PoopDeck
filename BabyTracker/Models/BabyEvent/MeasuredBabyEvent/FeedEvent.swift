//
//  FeedEvent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

typealias BreastSide = FeedEvent.Source.BreastSide

// MARK: - Feed Event
struct FeedEvent: MeasuredBabyEvent {
    static var type: BabyEventType = .feed
    static var new: FeedEvent {
        return FeedEvent(source: .breast(.both))
    }
    
    var id = UUID()
    var date: Date = Date()
    
    var source: Source
    var measurement: Measurement<Unit>?
}

extension FeedEvent {
    static var defaultMeasurement: Measurement<Unit> {
        return Measurement(
            value: Locale.current.usesMetricSystem ? 90.0 : 3.0,
            unit: defaultUnit
        )
    }
}

// MARK: - Feed Source
extension FeedEvent {
    enum Source: Equatable, Codable {
        case breast(_ side: BreastSide)
        case bottle

        enum CodingKeys: String, CodingKey {
            case source
            case breastSide
        }
        
        enum SourceType: String, Codable, CaseIterable {
            case breast
            case bottle
        }
        
        enum BreastSide: String, Equatable, Codable, CaseIterable {
            case left
            case right
            case both
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try container.decode(SourceType.self, forKey: .source)
            
            switch type {
            case .breast:
                let side = try container.decode(BreastSide.self, forKey: .breastSide)
                self = .breast(side)
            case .bottle:
                self = .bottle
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .breast(let side):
                try container.encode(SourceType.breast, forKey: .source)
                try container.encode(side, forKey: .breastSide)
            case .bottle:
                try container.encode(SourceType.bottle, forKey: .source)
            }
        }
        
        var title: String {
            switch self {
            case .bottle:
                return "Bottle feeding"
            case .breast:
                return "Breast feeding"
            }
        }
    }
}

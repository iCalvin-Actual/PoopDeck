//
//  FeedEventSource.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension FeedEvent {
    
    /// Associated types give more context specific to the feed source type
    enum Source: Equatable {
        case breast(_ side: BreastSide)
        case bottle
    }
}

extension FeedEvent.Source: Codable {
    /// Three sets of enums to hack Codable conformance with associated types
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
}


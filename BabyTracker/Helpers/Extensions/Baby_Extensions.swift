//
//  Baby_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Set of baby emoji options in lieu of a name
extension Baby {
    static var emojiSet: [String] {
        return [
        "👶🏿",
        "👶🏾",
        "👶🏽",
        "👶🏼",
        "👶🏻",
        "👶"
        ]
    }
}

/// Name accessor values
extension Baby {
    private var nameComponents: PersonNameComponents? {
        return PersonNameComponentsFormatter.decoding.personNameComponents(from: name)
    }
    var displayName: String {
        guard let components = nameComponents else {
            return name
        }
        return PersonNameComponentsFormatter.short.string(from: components)
    }
    var displayInitial: String {
        guard let components = nameComponents else {
            return name
        }
        return PersonNameComponentsFormatter.abbreviated.string(from: components)
    }
}

//
//  Baby.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

// MARK: - Baby
class OldFormatBaby: Codable {
    
    var id: UUID
    
    init() {
        self.id = UUID()
    }
    
    var name: String = ""
    var emoji: String?
    var birthday: Date?
    
    var themeColor: PreferredColor? = .random
}

class Baby: Codable {
    
    var id: UUID
    
    init() {
        self.id = UUID()
    }
    
    var name: String = ""
    var emoji: String = ""
    var prefersEmoji: Bool = true
    
    var birthday: Date?
    
    var themeColor: PreferredColor? = .random
}

// MARK: - Computed Variables
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

// MARK: - Static Helpers
extension Baby {
    static var new: Baby {
        return Baby()
    }
}
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

// MARK: - Protocols
extension Baby: ObservableObject { }
extension Baby: Equatable {
    static func == (lhs: Baby, rhs: Baby) -> Bool { return lhs.id == rhs.id }
}
extension Baby: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
        hasher.combine(name)
        hasher.combine(themeColor)
        hasher.combine(birthday)
    }
}

//
//  Baby.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

// MARK: - Baby
class Baby: Codable {
    
    var id: UUID = UUID()
    
    /// Name is non-optional, but assumed empty
    var name: String = ""
    /// Emoji value can also be empty, but one of these two much be non-nil to have a valid baby
    var emoji: String = Baby.emojiSet.randomElement() ?? ""
    /// Use the emoji value instead of the name, even if a name is saved
    var prefersEmoji: Bool = true
    
    /// Birthdate is optional too. Don't wanna force any information
    var birthday: Date?
    
    /// In lieu of Gender options, present Theme Colors the user can choose for the Baby's avatar
    var themeColor: ThemeColor? = .random
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

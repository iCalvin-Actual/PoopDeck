//
//  BabyFormView_FormContent.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension BabyFormView {
    struct FormContent {
        /// If for whatever reason the user doesn't want to enter the baby's real name, they can instead use an emoji.
        var name: String = ""
        var emoji: String = Baby.emojiSet.randomElement() ?? ""
        var useEmojiName: Bool = false
        
        /// Theme color to use for the baby in lieu of adding a gender option
        var color: ThemeColor = ThemeColor.prebuiltSet.randomElement()!
        
        /// Birthday is esaier to have non-nil but ignored
        var birthday: Date = .oneWeekAgo
        var saveBirthday: Bool = false
    }
}

//
//  BabyFormView_Validation.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

extension BabyFormView {
    /// Generates a baby using the current form status
    var babyFromForm: Baby {
        let baby = Baby()
        baby.name = content.name
        baby.emoji = content.emoji
        if content.saveBirthday {
            baby.birthday = content.birthday
        }
        baby.themeColor = content.color
        baby.prefersEmoji = content.useEmojiName
        
        return baby
    }
    
    func validateAndApply() {
        let baby = self.babyFromForm
        guard baby.validName else { return }
        onApply?(content)
    }
}

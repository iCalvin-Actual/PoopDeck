//
//  CustomEventForm_Validation.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension CustomEventFormView {
    var isEmpty: Bool {
        return content.title.isEmpty && content.info.isEmpty
    }
    
    var isValid: Bool {
        return !content.title.isEmpty
    }
    
    var isEdited: Bool {
        let restore =  restoreContent.sorted(by: { $0.date.date > $1.date.date })[activeOffset]
        
        return
            content.title != restore.title ||
            content.info != restore.info ||
            content.date.date != restore.date.date
    }
}

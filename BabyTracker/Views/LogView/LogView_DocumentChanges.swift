//
//  LogView_DocumentChanges.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Should be triggered by UIDocument notification
extension LogView {
    func handleStateChange(_ notification: Notification) {
        switch log.documentState {
        case .editingDisabled:
            /// Lock down the document and prevent editing
            self.allowChanges = false
        case .inConflict:
            /// Already in conflict mode
            guard !self.resolvingConflict else { return }
            self.resolvingConflict = true
            
            self.onAction?(.resolve(self.log))
        case .savingError:
            self.allowChanges = false
        case .closed:
            self.allowChanges = false
        case .progressAvailable:
            guard log.progress != nil else {
                // No progress to handle
                return
            }
            /// Should show progress in Tab View
        case .normal:
            self.allowChanges = true
        default:
            print("Unknown Value? \(log.documentState)")
        }
    }
}

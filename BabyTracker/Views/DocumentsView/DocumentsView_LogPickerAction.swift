//
//  DocumentsView_LogPickerAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

extension DocumentsView {
    func onBabyAction(_ logPickerAction: LogPickerAction) {
        switch logPickerAction {
        case .show(let log):
            self.onAction?(.show(log))
        case .select(let log):
            guard let log = log else {
                self.onAction?(.showDocuments)
                return
            }
            self.selected = log
        case .save(let log):
            self.onAction?(.save(log))
        case .close(let log):
            self.onAction?(.close(log))
        case .delete(let log):
            self.onAction?(.delete(log))
        case .forceClose:
            self.onAction?(.forceClose)
        case .updateColor(let log, newColor: let newColor):
            self.onAction?(.updateColor(log, newColor: newColor))
        }
    }
}

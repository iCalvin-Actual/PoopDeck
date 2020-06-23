//
//  LogView_CustomAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension LogView {
    func onEventAction(_ action: CustomAction) {
        switch action {
        case .create(let form):
            let event = CustomEvent(
                id: form.id ?? .init(),
                date: form.date.date,
                event: form.title,
                detail: form.info.isEmpty ? nil : form.info)
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let uuid):
            self.log.delete(uuid) { (_: Result<CustomEvent?, BabyError>) in
                print("Did Delete?")
            }
        case .toggleUnit:
            print("Do nothing")
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
}

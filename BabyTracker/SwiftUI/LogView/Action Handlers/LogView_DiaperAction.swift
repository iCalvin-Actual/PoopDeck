//
//  LogView_DiaperAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension LogView {
    func onEventAction(_ action: DiaperAction) {
        switch action {
        case .create(let form):
            let event = DiaperEvent(
                id: form.id ?? UUID(),
                date: form.date.date,
                pee: form.pee,
                poop: form.poo)
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let uuid):
            print("in delete")
            self.log.delete(uuid) { (deleteResult: Result<DiaperEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
}

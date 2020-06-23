//
//  LogView_TummyTimeAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension LogView {
    func onEventAction(_ action: MeasuredEventFormAction<TummyTimeEvent>) {
        switch action {
        case .create(let form):
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: form.date.date)
            let date = Date.apply(timeComponents, to: startOfTargetDate)
            let event = TummyTimeEvent(
                id: form.id ?? UUID(),
                date: date,
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<TummyTimeEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
}

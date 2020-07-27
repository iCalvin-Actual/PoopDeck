//
//  LogView_FeedAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension LogView {
    func onEventAction(_ action: MeasuredEventFormAction<FeedEvent>) {
        switch action {
        case .create(let form):
            let event = FeedEvent(
                id: form.id ?? UUID(),
                date: form.date.date,
                source: .breast(.both),
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<FeedEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
    
    func onBottleEventAction(_ action: MeasuredEventFormAction<FeedEvent>) {
        switch action {
        case .create(let form):
            let event = FeedEvent(
                id: form.id ?? UUID(),
                date: form.date.date,
                source: .bottle,
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<FeedEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
}

//
//  MeasuredEventFormView_UpdateEvents.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension MeasuredEventFormView {
    func updateEvents() {
        self.log.groupOfType(completion: { (result: Result<[UUID: E], BabyError>) in
            if case let .success(groupDict) = result, groupDict != items {
                self.items = groupDict
                guard self.activeIndex < self.restoreContent.count else {
                    self.content = .init()
                    self.collectMeasurement = false
                    return
                }
                self.content = self.restoreContent[self.activeIndex]
                self.collectMeasurement = self.content.measurement != nil
            }
        })
    }
}

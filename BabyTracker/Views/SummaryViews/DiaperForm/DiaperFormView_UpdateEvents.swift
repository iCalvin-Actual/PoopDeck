//
//  DiaperFormView_UpdateEvents.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension DiaperFormView {
    /// Fetches events from the event store. Triggers new state updates and computed vars access values
    func updateEvents() {
        log.groupOfType(completion: { (result: Result<[UUID: DiaperEvent], BabyError>) in
            if case let .success(groupDict) = result, groupDict != self.items {
                
                self.items = groupDict
                
                
                
                self.isLoading = false
            }
        })
    }
    
    func removeLast() {
        guard let id = content.id else { return }
        self.onAction?(.remove(id))
        self.editing = false
    }
}

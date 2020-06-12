//
//  ObservableDate.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation
import Combine

class ObservableDate: ObservableObject {
    var date: Date
    init(_ date: Date = .init()) {
        self.date = date
    }
}

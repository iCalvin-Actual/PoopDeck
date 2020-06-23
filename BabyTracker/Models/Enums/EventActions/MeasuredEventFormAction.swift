//
//  MeasuredEventFormAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

enum MeasuredEventFormAction<E: MeasuredBabyEvent> {
    case create(_: MeasuredEventFormView<E>.FormContent)
    case remove(_: UUID)
}

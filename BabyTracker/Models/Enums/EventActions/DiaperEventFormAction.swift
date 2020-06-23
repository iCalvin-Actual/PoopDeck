//
//  DiaperEventFormAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/22/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

enum DiaperAction {
    case create(_: DiaperFormView.FormContent)
    case remove(_: UUID)
}

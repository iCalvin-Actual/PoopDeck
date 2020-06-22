//
//  LogPickerAction.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

enum LogPickerAction {
    case select(_ baby: BabyLog?)
    /// Shows in documents browser
    case show(_ baby: BabyLog)
    case save(_ baby: BabyLog)
    case close(_ baby: BabyLog)
    case delete(_ baby: BabyLog)
    /// Seems to be necessary, otherwise changes in one view (Say the BabyPickerView) won't appear in the other view (LogView). Instead send updates back to the top level and update state
    case updateColor(_ baby: BabyLog, newColor: ThemeColor)
    /// Necessary to break out of stuck state where a file has been moved to an invalid location where it can't be saved, so it can't be properly closed. This just resets state to 0 open docs
    case forceClose
}

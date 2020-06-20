//
//  BabyLog_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

extension BabyLog {
    
    /// Non-nill instance to use when required
    static var dummy: BabyLog {
        return BabyLog(fileURL: URL(fileURLWithPath: ""))
    }
}

//
//  BabyError.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

enum BabyError: Error {
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .unknown:
            return "An unknown error occured"
        }
    }
    
    var localizedTitle: String {
        switch self {
        case .unknown:
            return "Whoopsidaisey"
        }
    }
}

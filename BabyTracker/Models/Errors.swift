//
//  Errors.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit

// MARK: - Error Handling

enum BabyError: Error {
    case unknown
}

protocol BabyErrorHandler {
    func handle(_ error: BabyError)
}

extension BabyError {
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

extension BBLGSSViewController: BabyErrorHandler {
    func handle(_ error: BabyError) {
        print("🚨: Handling Error - \(error.localizedDescription)")
        let alertController = UIAlertController(title: error.localizedTitle, message: error.localizedDescription, preferredStyle: .alert)
        self.present(alertController, animated: true)
    }
}

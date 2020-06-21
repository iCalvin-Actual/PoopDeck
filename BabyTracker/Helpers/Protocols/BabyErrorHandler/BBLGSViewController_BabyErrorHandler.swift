//
//  BBLGSViewController_BabyErrorHandler.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit

extension BBLGSViewController: BabyErrorHandler {
    func handle(_ error: BabyError) {
        print("🚨: Handling Error - \(error.localizedDescription)")
        let alertController = UIAlertController(title: error.localizedTitle, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(.init(title: "Close", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
}

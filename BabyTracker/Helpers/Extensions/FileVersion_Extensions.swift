//
//  FileVersion_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Display strings to identify a File Version
extension NSFileVersion {
    var personDisplayName: String? {
        guard let components = self.originatorNameComponents else { return nil }
        return PersonNameComponentsFormatter.short.string(from: components)
    }
    var deviceDisplayName: String? {
        return self.localizedNameOfSavingComputer
    }
}

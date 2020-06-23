//
//  FileVersionInfoStack.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct FileVersionInfoStack: View {
    var version: NSFileVersion
    var showName: Bool = true
    
    var body: some View {
        HStack {
            if showName {
                Text("\(version.deviceDisplayName ?? version.personDisplayName ?? "Unknown")")
                    .bold()
            } else {
                Text("Modified at")
                    .bold()
            }
            Spacer()
            Text(DateFormatter.shortDateTime.string(from: version.modificationDate ?? Date()))
        }
    }
}

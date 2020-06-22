//
//  FileVersionList.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct FileVersionList: View {
    var versions: [NSFileVersion]
    var onSelect: ((NSFileVersion) -> Void)?
    var body: some View {
        List {
            Section {
                ForEach(versions, id: \.self) { version in
                    FileVersionInfoStack(version: version, showName: false)
                }
            }
        }
        .navigationBarTitle(
            Text("Versions")
        )
    }
}

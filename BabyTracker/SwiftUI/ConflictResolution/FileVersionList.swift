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
    
    @State private var previewLog: Bool = false
    @State private var canPreviewLog: Bool = false
    
    @State private var log: BabyLog?
    var body: some View {
        List {
            Section {
                ForEach(versions, id: \.self) { version in
                    FileVersionInfoStack(version: version, showName: false)
                        .onTapGesture {
                            self.onSelect?(version)
                        }
                        .sheet(isPresented: self.$previewLog, content: {
                            ZStack {
                                if self.log != nil {
                                    LogView(log: self.log!)
                                }
                            }
                        })
                }
            }
        }
        .navigationBarTitle(
            Text("Versions")
        )
    }
}

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
    
    @State private var previewLog: Bool = false
    
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
        .onAppear(perform: {
            self.loadVersion()
        })
        .onLongPressGesture {
            self.previewLog = true
        }
        .sheet(isPresented: $previewLog, content: {
            Text("Preview")
//            LogView(log: self.conflict.babyLog)
        })
    }
}

extension FileVersionInfoStack {
    func loadVersion() {
        let document = BabyLog(fileURL: version.url)
        document.open { (success) in
            print("Version Document Loaded")
            /// Toggle new state with BabyLog to preview
        }
    }
}

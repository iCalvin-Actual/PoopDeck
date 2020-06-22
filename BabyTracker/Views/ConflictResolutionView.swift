//
//  ConflictResolutionViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct ConflictResolutionView: View {
    var conflict: BabyLogConflict
    
    var revert: ((BabyLog) -> Void)
    var replace: ((NSFileVersion) -> Void)
    
    /// Triggers presentation of Log Info for local version
    @State var previewLog: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                self.localSection()
                
                self.conflictSection()
            }
            .groupedStylePlease()
        }
        .navigationBarTitle(
            Text("Resolve Conflict")
        )
    }
    
    private func localSection() -> some View {
        Section {
            HStack {
                
                Text("Local Copy")
                
                Spacer()
                
                Text(DateFormatter.shortDateTime.string(from: conflict.babyLog.fileModificationDate ?? Date()))
                    .multilineTextAlignment(.trailing)
                    .lineLimit(0)
                
            }
            .padding(.horizontal)
            .onTapGesture {
                self.revert(self.conflict.babyLog)
            }.onLongPressGesture {
                self.previewLog = true
            }
            .sheet(isPresented: $previewLog, content: {
                LogView(log: self.conflict.babyLog)
            })
        }
    }
    
    private func conflictSection() -> some View {
        Section(header: Text("Version modified by")) {
            conflictSectionRows()
        }
    }
    
    func conflictSectionRows() -> AnyView {
        /// Sort versions by the devices they come from, if there are more than one from a given source allow presentation of detailed (ish) list
        let groupedVersions =  self.conflict.versions.reduce([:]) { (reduction, version) -> [String: [NSFileVersion]] in
            var reduction = reduction
            var key = version.deviceDisplayName ?? version.personDisplayName ?? "Unknown"
            if key == UIDevice.current.name {
                key = "This Device"
            }
            var arr = reduction[key] ?? []
            arr.append(version)
            reduction[key] = arr
            return reduction
        }
        let keys = groupedVersions.keys.sorted()
        
        return ForEach(keys, id: \.self) { key in
            self.versionInfoOrLink(key, groupedVersions[key] ?? [])
        }
        .anyPlease()
    }
    
    /// If no versions, empty.
    /// If one version, show info and allow selection
    /// If many versions, show count and allow presentation within the NavView
    func versionInfoOrLink(_ key: String, _ versions: [NSFileVersion]) -> AnyView {
        switch versions.count {
        case 0:
            return EmptyView().anyPlease()
        case 1:
            return FileVersionInfoStack(version: versions.first!)
                .onTapGesture {
                    self.replace(versions.first!)
                }
                .anyPlease()
        default:
            return FileVersionGroupSummary(name: key, versions: versions, onSelect: self.replace).anyPlease()
        }
    }
}




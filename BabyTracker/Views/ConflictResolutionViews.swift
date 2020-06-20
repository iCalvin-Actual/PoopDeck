//
//  ConflictResolutionViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

// MARK: - Model

struct LogConflict {
    let babyLog: BabyLog
    var versions: [NSFileVersion]
}

// MARK: - View Controller Extension

extension BBLGSSViewController {
    func resolveConflict(in log: BabyLog, with completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: log.fileURL) else {
            /// No conflicts?
            completion?(.success(log))
            return
        }
        let dateSorted = versions.sorted(by: { ($0.modificationDate ?? Date()) < ($1.modificationDate ?? Date()) })
        self.displayConflictResolution(for: log, with: dateSorted, onResolve: { resolvedLogResult in
            guard case let .success(log) = resolvedLogResult else {
                completion?(.failure(.unknown))
                return
            }
            let result: Result<BabyLog, BabyError>
            do {
                try NSFileVersion.removeOtherVersionsOfItem(at: log.fileURL)
                versions.forEach({ $0.isResolved = true })
                
                versions.forEach({ v in
                    try? v.remove()
                })
                result = .success(log)
            } catch {
                result = .failure(.unknown)
            }
            self.presentedViewController?.dismiss(animated: true, completion: {
                completion?(result)
            })
        })
    }
    
    private func displayConflictResolution(for log: BabyLog, with versions: [NSFileVersion], onResolve: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        let conflict = LogConflict(babyLog: log, versions: versions)
        let resolveView = ConflictResolutionView(
            conflict: conflict,
            revert: { (log) in
                log.revert(toContentsOf: log.fileURL, completionHandler: { success in
                    if success  { onResolve?(.success(log)) }
                    else        { onResolve?(.failure(.unknown)) }
                })
            },
            replace: { version in
                do {
                    try version.replaceItem(at: log.fileURL, options: .byMoving)
                    onResolve?(.success(log))
                } catch {
                    onResolve?(.failure(.unknown))
                }
            })

        let hostController = UIHostingController(rootView: resolveView)
        hostController.view.backgroundColor = .secondarySystemGroupedBackground
        self.present(hostController, animated: true)
    }
}

// MARK: Conflict Resolution View

struct ConflictResolutionView: View {
    var conflict: LogConflict
    
    var revert: ((BabyLog) -> Void)
    var replace: ((NSFileVersion) -> Void)
    
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
    
    func versionInfoOrLink(_ key: String, _ versions: [NSFileVersion]) -> AnyView {
        switch versions.count {
        case 0:
            return EmptyView().anyPlease()
        case 1:
            return VersionInfoStack(version: versions.first!)
                .onTapGesture {
                    self.replace(versions.first!)
                }
                .anyPlease()
        default:
            return VersionGroupSummary(name: key, versions: versions, onSelect: self.replace).anyPlease()
        }
    }
}

// MARK: Version Info Views

struct VersionGroupSummary: View {
    var name: String
    var versions: [NSFileVersion]
    var onSelect: ((NSFileVersion) -> Void)?
    var body: some View {
        NavigationLink(destination: VersionList(versions: versions, onSelect: onSelect)) {
            HStack {
                Text(name)
                    .bold()
                Spacer()
                Text("\(versions.count) versions")
            }
        }
    }
}

struct VersionList: View {
    var versions: [NSFileVersion]
    var onSelect: ((NSFileVersion) -> Void)?
    var body: some View {
        List {
            Section {
                ForEach(versions, id: \.self) { version in
                    VersionInfoStack(version: version, showName: false)
                }
            }
        }
        .navigationBarTitle(
            Text("Versions")
        )
    }
}

struct VersionInfoStack: View {
    var version: NSFileVersion
    var showName: Bool = true
    var nameString: String? {
        return version.personDisplayName
    }
    var deviceString: String? {
        return version.deviceDisplayName
    }
    var body: some View {
        HStack {
            if showName {
                Text("\(deviceString ?? nameString ?? "Unknown")")
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

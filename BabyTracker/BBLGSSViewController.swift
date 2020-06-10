//
//  BBLGSSViewController.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

class BBLGSSViewController: UIViewController {
    
    private let documentBrowser: DocumentBrowserViewController = DocumentBrowserViewController()
    private var hostController: UIViewController? {
        willSet {
            hostController?.removeFromParent()
        }
        didSet {
            guard let newController = hostController else { return }
            newController.view.backgroundColor = .clear
            self.addChild(newController)
            self.view.addSubview(newController.view)
            newController.view.translatesAutoresizingMaskIntoConstraints = false
            hostController?.didMove(toParent: self)
            NSLayoutConstraint.activate([
                self.view.heightAnchor.constraint(equalTo: newController.view.heightAnchor, multiplier: 1.0),
                self.view.widthAnchor.constraint(equalTo: newController.view.widthAnchor, multiplier: 1.0),
                self.view.centerYAnchor.constraint(equalTo: newController.view.centerYAnchor),
                self.view.centerXAnchor.constraint(equalTo: newController.view.centerXAnchor)
            ])
        }
    }
    
    
    var presentedFileURLs: [URL] = [] {
        didSet {
            self.updateCurrentActivity()
        }
    }
    
    @Published
    var docsInView: [BabyLog] = [] {
        didSet {
            updateCurrentActivity()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .secondarySystemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buildSwiftUIView()
    }
    
    func buildSwiftUIView(animated: Bool = false) {
        let hostController: UIViewController
        if self.docsInView.count > 0 {
            let view = DocumentsView(
                logs: self.docsInView,
                onAction: self.onAction)
            hostController = UIHostingController(rootView: view)
        } else {
            let view = NewWindowView(
                onCreate: self.createNewLog)
            hostController = UIHostingController(rootView: view)
        }
        self.hostController = hostController
    }
    
    func rebuildSwiftUIView(animated: Bool = false) {
        dismissPresented(animated: animated) {
            self.buildSwiftUIView(animated: animated)
        }
    }
    
    func createNewLog() {
        self.presentDocumentBrowser()
    }
    
    enum BrowserContext {
        case selectOne
        case selectMany
        case view(_ url: URL)
    }
    
    func presentDocumentBrowser(_ context: BrowserContext = .selectMany, animated: Bool = true, completion: ((UIDocumentBrowserViewController) -> Void)? = nil) {
        /// Switch and configure
        let documentBrowser: DocumentBrowserViewController = DocumentBrowserViewController()
        documentBrowser.logPresenter = self
        documentBrowser.allowsDocumentCreation = false
        
        var fileDestination: URL? = nil
        
        switch context {
        case .view(let url):
            fileDestination = url
        case .selectOne:
            documentBrowser.allowsPickingMultipleItems = false
        default:
            documentBrowser.allowsPickingMultipleItems = true
        }
        
        self.present(documentBrowser, animated: true, completion: {
            if let url = fileDestination {
                documentBrowser.revealDocument(at: url, importIfNeeded: true) { (url, error) in
                    guard error == nil else {
                        documentBrowser.dismiss(animated: true, completion: nil)
                        self.handle(.unknown)
                        return
                    }
                }
            }
            completion?(documentBrowser)
        })
    }
    
    func dismissPresented(animated: Bool = false, _ completion: (() -> Void)? = nil) {
        if let presented = self.presentedViewController {
            presented.dismiss(animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    func updateCurrentActivity() {
        guard let window = view.window else { return }
        let currentActivity =
            self.createViewingDocsActivity() ??
            self.createNewDocActivity()
        
        window.windowScene?.userActivity = currentActivity
        currentActivity.becomeCurrent()
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == ActivityType.viewLogs {
            self.restoreViewingDocsActivity(activity)
        }
        self.restoreNewDocActivity(activity)
    }
    
    func createViewingDocsActivity() -> NSUserActivity? {
        guard !docsInView.filter({ !$0.fileURL.pathComponents.contains(".Trash") }).isEmpty else { return nil }
        var urlData: [Data] = []
        docsInView.map({ $0.fileURL }).forEach { (presentedFileURL) in
            do {
                let didStart = presentedFileURL.startAccessingSecurityScopedResource()
                defer {
                    if didStart {
                        presentedFileURL.stopAccessingSecurityScopedResource()
                    }
                }
                if didStart {
                    let data = try presentedFileURL.bookmarkData()
                    urlData.append(data)
                }
            } catch {
                print("STOP")
            }
        }
        let activity = NSUserActivity(activityType: ActivityType.viewLogs)
        activity.userInfo?["URLBookmarks"] = urlData
        activity.title = "Viewing \(urlData.count) BabyLogs"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func restoreViewingDocsActivity(_ activity: NSUserActivity) {
        guard let urlData = activity.userInfo?["URLBookmarks"] as? [Data] else { return }
        var retrievedURLs: [URL] = []
        urlData.forEach { (presentedURLData) in
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: presentedURLData, bookmarkDataIsStale: &isStale)
                retrievedURLs.append(url)
            } catch {
                print("STOP")
            }
        }
        self.presentDocuments(at: retrievedURLs)
    }
    
    func createNewDocActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: ActivityType.newWindow)
        activity.title = "Open BBLG"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func restoreNewDocActivity(_ activity: NSUserActivity) {
        self.docsInView = []
    }
}

extension BBLGSSViewController: LogPresenter { }
extension BBLGSSViewController {
    func onAction(_ action: DocumentAction) {
        switch action {
        case .createNew:
            self.dismissPresented(animated: true) {
                self.createNewLog()
            }
        case .save(let log):
            self.saveDocument(log, completion: { (result: Result<BabyLog, BabyError>) in
                if case let .failure(error) = result {
                    self.handle(error)
                }
            })
        case .close(let log):
            self.closeDocument(log)
        case .resolve(let log):
            self.resolveConflict(in: log)
        case .show(let log):
            self.presentDocumentBrowser(.view(log.fileURL))
        case .delete(let log):
            self.deleteDocument(log)
        }
    }
}

// MARK: - Error Handling

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
        let alertController = UIAlertController(title: error.localizedTitle, message: error.localizedDescription, preferredStyle: .alert)
        self.present(alertController, animated: true)
    }
}

// MARK: - Document Presentation

extension BBLGSSViewController {
    func presentDocuments(at documentURLs: [URL]) {
        self.presentedFileURLs = documentURLs
        let documents = documentURLs.map({ BabyLog(fileURL: $0) })
        var openedDocs: [BabyLog] = []
        
        let openGroup = DispatchGroup()
        
        documents.forEach { document in
            openGroup.enter()
            
            document.open(completionHandler: { success in
                if success {
                    openedDocs.append(document)
                }
                openGroup.leave()
            })
        }
        
        openGroup.notify(queue: .main) {
            self.docsInView = self.docsInView.filter({ !openedDocs.contains($0) }) + openedDocs
            self.rebuildSwiftUIView()
        }
    }
    
    func createDocument(at documentURL: URL, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        dismissPresented(animated: true) {
            let newBabyView = NewBabyForm(
                onApply: { baby in
                self.createNewDocument(with: baby, at: documentURL) { (result) in
                    switch result {
                    case .failure(let error):
                        self.handle(error)
                    case .success(let log):
                        self.presentDocuments(at: [log.fileURL])
                    }
                }
            })
            let hostingController = UIHostingController(rootView: newBabyView)
            self.present(hostingController, animated: true, completion: nil)
        }
    }
    
    func saveDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        document.save(to: document.fileURL, for: .forOverwriting) { saved in
            guard saved else {
                completion?(.failure(.unknown))
                return
            }
            print("Did Save")
            completion?(.success(document))
        }
    }

    func closeDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        self.saveDocument(document) { (saveResult) in
            if case .success = saveResult, let docIndex = self.docsInView.firstIndex(of: document) {
                self.docsInView.remove(at: docIndex)
            }
            self.rebuildSwiftUIView()
            completion?(saveResult)
        }
    }
    
    func deleteDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        let confirmAlert = UIAlertController(title: "Delete BabyLog", message: "Are you sure you want to delete this baby log?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.closeDocument(document) { closeResult in
                switch closeResult {
                case .success(let closedDoc):
                    do {
                        try FileManager().removeItem(at: closedDoc.fileURL)
                    } catch {
                        completion?(.failure(.unknown))
                    }
                default:
                    completion?(closeResult)
                }
            }
        }))
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(confirmAlert, animated: true, completion: nil)
    }
}

extension BBLGSSViewController {
    func createNewDocument(with baby: Baby, at url: URL?, completion: @escaping ((Result<BabyLog, BabyError>) -> Void)) {
        let saveURL: URL?
        if var importURL = url {
            importURL.deleteLastPathComponent()
            importURL.appendPathComponent("\(baby.name).bblg")
            saveURL = importURL
        } else {
            saveURL = FileManager().url(forUbiquityContainerIdentifier: "iCloud.com.chestnut.BabyTracker")?.appendingPathComponent("\(baby.name).bblg")
        }
        guard let url = saveURL else {
            completion(.failure(.unknown))
            return
        }
        dismissPresented(animated: true) {
            let babyLog = BabyLog(fileURL: url)
            babyLog.baby = baby
            self.saveDocument(babyLog) { saveResult in
                switch saveResult {
                case .success(let log):
                    completion(.success(log))
                case .failure(let error):
                    self.handle(error)
                }
            }
        }
    }
}


struct LogConflict {
    let babyLog: BabyLog
    var versions: [NSFileVersion]
}

// MARK: - Conflict Resolution

extension BBLGSSViewController {
    func resolveConflict(in log: BabyLog, with completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: log.fileURL) else {
            /// No conflicts?
            completion?(.success(log))
            return
        }
        let dateSorted = versions.sorted(by: { ($0.modificationDate ?? Date()) < ($1.modificationDate ?? Date()) })
        self.displayConflictResolution(for: log, with: dateSorted, onResolve: { log in
            do {
                try NSFileVersion.removeOtherVersionsOfItem(at: log.fileURL)
                versions.forEach({ $0.isResolved = true })
                
                versions.forEach({ v in
                    try? v.remove()
                })
            } catch {
                print("🚨 Failed to resolve conflict")
            }
            self.presentedViewController?.dismiss(animated: true, completion: {
                print("Do a thing?")
            })
        })
    }
    
    private func displayConflictResolution(for log: BabyLog, with versions: [NSFileVersion], onResolve: ((BabyLog) -> Void)? = nil) {
        let conflict = LogConflict(babyLog: log, versions: versions)
        let resolveView = ConflictResolutionView(
            conflict: conflict,
            revert: { (log) in
                log.revert(toContentsOf: log.fileURL, completionHandler: { success in
                    print("Reverted? \(success)")
                    onResolve?(log)
                })
            },
            replace: { version in
                do {
                    try version.replaceItem(at: log.fileURL, options: .byMoving)
                    onResolve?(log)
                } catch {
                    // Show error?
                    print(error.localizedDescription)
                }
            })

        let hostController = UIHostingController(rootView: resolveView)
        hostController.view.backgroundColor = .secondarySystemGroupedBackground
        self.present(hostController, animated: true)
    }
}



struct ConflictResolutionView: View {
    var conflict: LogConflict
    
    var revert: ((BabyLog) -> Void)
    var replace: ((NSFileVersion) -> Void)
    
    @State var previewLog: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Local Copy")
                            .padding(.horizontal)
                        Spacer()
                        Text(DateFormatter.shortDisplay.string(from: conflict.babyLog.fileModificationDate ?? Date()))
                            .multilineTextAlignment(.trailing)
                            .lineLimit(0)
                            .padding(.horizontal)
                    }
                    .onTapGesture {
                        self.revert(self.conflict.babyLog)
                    }.onLongPressGesture {
                        self.previewLog = true
                    }
                    .sheet(isPresented: $previewLog, content: {
                        LogView(log: self.conflict.babyLog)
                    })
                }
                Section(header: Text("Version modified by")) {
                    createConflictSection()
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
        }
        .navigationBarTitle(
            Text("Resolve Conflict")
        )
    }
    
    func createConflictSection() -> AnyView {
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
        .anyify()
    }
    
    func versionInfoOrLink(_ key: String, _ versions: [NSFileVersion]) -> AnyView {
        switch versions.count {
        case 0:
            return EmptyView().anyify()
        case 1:
            return VersionInfoStack(version: versions.first!)
                .onTapGesture {
                    self.replace(versions.first!)
                }
                .anyify()
        default:
            return VersionGroupSummary(name: key, versions: versions, onSelect: self.replace).anyify()
        }
    }
}

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
            Text(DateFormatter.shortDisplay.string(from: version.modificationDate ?? Date()))
        }
    }
}
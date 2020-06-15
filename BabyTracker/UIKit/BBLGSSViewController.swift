//
//  BBLGSSViewController.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - Root View Controller

class BBLGSSViewController: UIViewController {
    
// MARK: - Properties
    
    @Published
    var docsInView: [BabyLog] = [] {
        didSet {
            updateCurrentActivity()
            self.rebuildSwiftUIView()
        }
    }
    
    private let documentBrowser: DocumentBrowserViewController = DocumentBrowserViewController()
    
    private var hostController: UIViewController? {
        willSet {
            hostController?.removeFromParent()
            hostController?.view.removeFromSuperview()
        }
        didSet {
            guard let newController = hostController else { return }
            newController.view.backgroundColor = .clear
            addChild(newController)
            view.addSubview(newController.view)
            newController.view.translatesAutoresizingMaskIntoConstraints = false
            hostController?.didMove(toParent: self)
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalTo: newController.view.heightAnchor, multiplier: 1.0),
                view.widthAnchor.constraint(equalTo: newController.view.widthAnchor, multiplier: 1.0),
                view.centerYAnchor.constraint(equalTo: newController.view.centerYAnchor),
                view.centerXAnchor.constraint(equalTo: newController.view.centerXAnchor)
            ])
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        
        documentBrowser.additionalLeadingNavigationBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(rebuildSwiftUIView))
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buildSwiftUIView()
    }
    
    func dismissPresented(animated: Bool = false, _ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let presented = self.presentedViewController {
                presented.dismiss(animated: animated, completion: completion)
            } else {
                completion?()
            }
        }
    }
    
    @objc
    func rebuildSwiftUIView(animated: Bool = false) {
        dismissPresented(animated: animated) {
            self.buildSwiftUIView(animated: animated)
        }
    }
}

extension BBLGSSViewController {
    // MARK: - View Constructor
    
    func buildSwiftUIView(animated: Bool = false) {
        let hostController: UIViewController

        let view = DocumentsView(
            logs: docsInView,
            selected: docsInView.first,
            onAction: onAction)
        
        hostController = UIHostingController(rootView: view)
        
        self.hostController = hostController
    }
}

extension BBLGSSViewController {
    // MARK: - Document Browser
    
    func showDefaultStateBrowser() {
        presentDocumentBrowser()
    }
    
    enum BrowserContext {
        case selectOne
        case selectMany
        case view(_ url: URL)
    }
    
    func presentDocumentBrowser(_ context: BrowserContext = .selectMany, animated: Bool = true, completion: ((UIDocumentBrowserViewController) -> Void)? = nil) {
        
        documentBrowser.logPresenter = self
        
        var fileDestination: URL? = nil
        
        switch context {
        case .view(let url):
            fileDestination = url
        case .selectOne:
            documentBrowser.allowsPickingMultipleItems = false
        default:
            documentBrowser.allowsPickingMultipleItems = true
        }
        documentBrowser.allowsDocumentCreation = true
        
        present(documentBrowser, animated: true) {
            if let url = fileDestination {
                self.documentBrowser.revealDocument(at: url, importIfNeeded: true) { (url, error) in
                    guard error == nil else {
                        self.documentBrowser.dismiss(animated: true, completion: {
                            self.rebuildSwiftUIView()
                            self.handle(.unknown)
                            completion?(self.documentBrowser)
                        })
                        return
                    }
                    completion?(self.documentBrowser)
                }
            } else {
               completion?(self.documentBrowser)
            }
        }
    }
    
    // MARK: - User Activity
    
    func updateCurrentActivity() {
        guard let window = view.window else { return }
        let currentActivity =
            createViewingDocsActivity() ??
            createNewDocActivity()
        
        window.windowScene?.userActivity = currentActivity
        currentActivity.becomeCurrent()
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
                print("Error creating bookmark: \(error.localizedDescription)")
            }
        }
        let activity = NSUserActivity(activityType: ActivityType.viewLogs)
        activity.userInfo?["URLBookmarks"] = urlData
        activity.title = "Viewing \(urlData.count) BabyLogs"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func createNewDocActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: ActivityType.newWindow)
        activity.title = "Open BBLG"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == ActivityType.viewLogs {
            restoreViewingDocsActivity(activity)
        }
        restoreNewDocActivity(activity)
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
                print("Error reading bookmark: \(error.localizedDescription)")
            }
        }
        self.presentDocuments(at: retrievedURLs)
    }
    
    func restoreNewDocActivity(_ activity: NSUserActivity) {
        self.docsInView = []
    }
}

// MARK: - Document Presentation

extension BBLGSSViewController: LogPresenter { }
extension BBLGSSViewController {
    func presentDocuments(at documentURLs: [URL]) {
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
                    self.dismissPresented(animated: true) {
                        self.createNewDocument(with: baby, at: documentURL) { (result) in
                            switch result {
                            case .failure(let error):
                                self.handle(error)
                            case .success(let log):
                                self.presentDocuments(at: [log.fileURL])
                            }
                        }
                    }
            })
            let hostingController = UIHostingController(rootView: newBabyView)
            self.present(hostingController, animated: true, completion: nil)
        }
    }
}

// MARK: - Document Managment

extension BBLGSSViewController {
    func onAction(_ action: DocumentAction) {
        switch action {
        case .showDocuments:
            self.dismissPresented(animated: true) {
                self.showDefaultStateBrowser()
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
        case .forceClose:
            self.forceCloseDocuments()
        case .updateColor(let log, newColor: let newColor):
            guard let logIndex = docsInView.firstIndex(of: log) else { return }
            docsInView[logIndex].baby.themeColor = newColor
            self.rebuildSwiftUIView()
        }
    }
    
    
    func saveDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        document.save(to: document.fileURL, for: .forOverwriting) { saved in
            guard saved else {
                completion?(.failure(.unknown))
                return
            }
            if let last = document.fileURL.pathComponents.last, !last.contains(document.baby.displayName) {
                self.renameDocument(document, completion: completion)
            } else {
                completion?(.success(document))
            }
        }
    }
    
    func renameDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        completion?(.success(document))
        
        // TODO: Doesn't work on secure storage (on device)
//        var expectedURL = document.fileURL
//        expectedURL.deleteLastPathComponent()
//        expectedURL.appendPathComponent("\(document.baby.displayName).bblg")
//        document.close { (closed) in
//            do {
//                try FileManager.default.moveItem(at: document.fileURL, to: expectedURL)
//                let newLog = BabyLog(fileURL: expectedURL)
//                newLog.open { (openSuccess) in
//                    switch openSuccess {
//                    case true:
//                        completion?(.success(newLog))
//                    case false:
//                        completion?(.failure(.unknown))
//                    }
//                }
//                return
//            } catch {
//                document.open { (reopenSuccess) in
//                    completion?(.failure(.unknown))
//                }
//                print("🚨 Failed to rename file \(document.fileURL.absoluteString)")
//            }
//        }
    }

    func forceCloseDocuments() {
        let oldDocsToTryToClose = self.docsInView
        self.docsInView = []
        self.rebuildSwiftUIView()
        oldDocsToTryToClose.forEach({ log in
            self.saveDocument(log)
        })
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
        guard let destinationURL = url else {
            completion(.failure(.unknown))
            return
        }
        let log = BabyLog(fileURL: destinationURL)
        log.baby = baby
        self.saveDocument(log, completion: completion)
    }
}


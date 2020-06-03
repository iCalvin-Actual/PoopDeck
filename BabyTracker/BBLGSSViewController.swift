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
    
    var docsInView: [BabyLog] = [] {
        didSet {
            buildSwiftUIView()
            updateCurrentActivity()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.documentBrowser.logPresenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buildSwiftUIView()
    }
    
    func buildSwiftUIView(animated: Bool = false) {
        guard let first = docsInView.first else {
            /// Welcome view?
            let welcomeView = NewWindowView(
                onCreate: self.createNewLog,
                onImport: self.importLog)
            let hostController = UIHostingController(rootView: welcomeView)
            self.present(hostController, animated: animated)
            return
        }
        dismissPresented(animated: animated) {
            let docsView = DocumentsView(
                logs: self.docsInView,
                selected: first,
                onSave: { document in
                    self.saveDocument(document, completion: { (result: Result<BabyLog, BabyError>) in
                        switch result {
                        case .failure(let error):
                            self.handle(error)
                        case .success:
                            print("Did Save Doc")
                        }
                    })
                },
                onClose: { document in
                    self.closeDocument(document)
                })
            self.hostController = UIHostingController(rootView: docsView)
        }
        
    }
    
    func createNewLog() {
        // Create new document and save?
    }
    
    func importLog() {
        // Show document browser
        self.dismissPresented {
            self.present(self.documentBrowser, animated: true, completion: nil)
        }
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
        
        if let activity = self.createViewingDocsActivity() {
            window.windowScene?.userActivity = activity
            activity.becomeCurrent()
        }
    }
    
    func createViewingDocsActivity() -> NSUserActivity? {
        guard !docsInView.isEmpty else { return nil }
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
        activity.title = "View babylogs"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func restore(_ activity: NSUserActivity) {
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
}

extension BBLGSSViewController: LogPresenter { }

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
            self.docsInView = openedDocs
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

    func closeDocument(_ document: BabyLog) {
        self.saveDocument(document) { (saveResult) in
            switch saveResult {
            case .failure(let error):
                self.handle(error)
            case .success:
                if let docIndex = self.presentedFileURLs.firstIndex(of: document.fileURL) {
                    self.presentedFileURLs.remove(at: docIndex)
                }
            /// Update presented views (If necessary?)
            }
        }
    }
}


// MARK: - State Restoration

//extension BBLGSSViewController {
//    override func encodeRestorableState(with coder: NSCoder) {
//        let dataArray: [Data] = self.presentedFileURLs.map { (url) -> Data in
//            do {
//                let didStart = url.startAccessingSecurityScopedResource()
//                defer {
//                    if didStart {
//                        url.stopAccessingSecurityScopedResource()
//                    }
//                }
//                if didStart {
//                    return try url.bookmarkData()
//                }
//            } catch {
//                print("STOP")
//            }
//            return Data()
//        }
//        coder.encode(dataArray, forKey: "PresentedFileURLS")
//        super.encodeRestorableState(with: coder)
//    }
//
//    override func decodeRestorableState(with coder: NSCoder) {
//        if let presentedURLData = coder.decodeObject(forKey: "PresentedFileURLS") as? [Data] {
//            let urls = presentedURLData.map({ data -> URL in
//                do {
//                    var isStale = false
//                    return try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
//                } catch {
//                    print("🚨 Decoding Root VC State:  \(error.localizedDescription)")
//                }
//                return URL(fileURLWithPath: "")
//            })
//            self.presentedFileURLs = urls
//        }
//
//        super.decodeRestorableState(with: coder)
//    }
//}

struct BBLGSSViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

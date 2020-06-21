//
//  BBLGSViewController_DocumentManager.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit

extension BBLGSViewController {
    func onAction(_ action: DocumentAction) {
        switch action {
        case .showDocuments:
            dismissPresented(animated: true) {
                self.showDefaultStateBrowser()
            }
        case .save(let log):
            saveDocument(log, completion: { (result: Result<BabyLog, BabyError>) in
                if case let .failure(error) = result {
                    self.handle(error)
                }
            })
        case .close(let log):
            closeDocument(log)
        case .resolve(let log):
            resolveConflict(in: log)
        case .show(let log):
            presentDocumentBrowser(.view(log.fileURL))
        case .delete(let log):
            deleteDocument(log)
        case .forceClose:
            forceCloseDocuments()
        case .updateColor(let log, newColor: let newColor):
            guard let logIndex = openDocs.firstIndex(of: log) else { return }
            openDocs[logIndex].baby.themeColor = newColor
            rebuildSwiftUIView()
        }
    }
    
    
    func saveDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        document.save(to: document.fileURL, for: .forOverwriting) { saved in
            guard saved else {
                completion?(.failure(.unknown))
                return
            }
            /// If the name has changed, make sure the doument name matches the new baby name
            if let last = document.fileURL.pathComponents.last, !last.contains(document.baby.displayName) {
                self.renameDocument(document, completion: completion)
            } else {
                completion?(.success(document))
            }
        }
    }
    
    func renameDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        completion?(.success(document))
        /// TODO Having difficulty getting this to work right on an actual device. Likely some security scope issue, functions fine on simulator
    }

    func closeDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        self.saveDocument(document) { (saveResult) in
            if case .success = saveResult, let docIndex = self.openDocs.firstIndex(of: document) {
                self.openDocs.remove(at: docIndex)
            }
            self.rebuildSwiftUIView()
            completion?(saveResult)
        }
    }

    /// Manually reset the open docs to force a close when documents won't close
    func forceCloseDocuments() {
        let oldDocsToTryToClose = self.openDocs
        self.openDocs = []
        self.rebuildSwiftUIView()
        oldDocsToTryToClose.forEach({ log in
            self.saveDocument(log)
        })
    }
    
    func deleteDocument(_ document: BabyLog, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        let confirmAlert = UIAlertController(
            title: "Delete BabyLog",
            message: "Are you sure you want to delete this baby log?",
            preferredStyle: .alert)
        confirmAlert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive,
                handler: { action in
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
                    }}))
        
        confirmAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil))
        
        present(confirmAlert, animated: true, completion: nil)
    }
}

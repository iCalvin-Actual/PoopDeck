//
//  DocumentBrowserViewController.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

protocol LogPresenter {
    func presentDocuments(at documentURLs: [URL])
    func createDocument(at documentURL: URL, completion: ((Result<BabyLog, BabyError>) -> Void)?)
}

class DocumentBrowserViewController: UIDocumentBrowserViewController {
    
    var logPresenter: LogPresenter?
    
    private var presentedFileURLs: [URL] = [] {
        didSet {
            guard !self.presentedFileURLs.isEmpty else { return }
            self.logPresenter?.presentDocuments(at: self.presentedFileURLs)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
}

extension DocumentBrowserViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = Bundle.main.url(forResource: "MyBabyLog", withExtension: "bblg")
        
        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .copy)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        self.presentedFileURLs = documentURLs
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        self.logPresenter?.createDocument(at: destinationURL, completion: nil)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
}
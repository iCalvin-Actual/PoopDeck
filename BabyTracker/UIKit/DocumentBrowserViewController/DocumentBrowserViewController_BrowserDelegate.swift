//
//  DocumentBrowserViewController_BrowserDelegate.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit

extension DocumentBrowserViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        
        /// This is tricky. I have a template file in the project, so it wants us to copy that file into the chosen URL. But ideally the file should save with the Baby's name as the filename, so this will need to be renamed, which is harder than it should be
        let newDocumentURL: URL? = Bundle.main.url(forResource: "MyBabyLog", withExtension: "bblg")
        
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

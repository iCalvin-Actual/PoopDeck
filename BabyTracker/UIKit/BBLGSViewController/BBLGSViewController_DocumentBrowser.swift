//
//  BBLGSViewController_DocumentBrowser.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit

extension BBLGSViewController {
    func showDefaultStateBrowser() {
        presentDocumentBrowser()
    }
    
    func presentDocumentBrowser(_ context: BrowserContext = .select, animated: Bool = true, completion: ((UIDocumentBrowserViewController) -> Void)? = nil) {
        
        documentBrowser.logPresenter = self
        
        var fileDestination: URL?
        
        switch context {
        case .view(let url):
            fileDestination = url
        default:
            documentBrowser.allowsPickingMultipleItems = true
        }
        documentBrowser.allowsDocumentCreation = true
        
        present(documentBrowser, animated: true) {
            guard let url = fileDestination else {
                completion?(self.documentBrowser)
                return
            }
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
        }
    }
}

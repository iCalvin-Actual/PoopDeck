//
//  DocumentBrowserViewController.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

class DocumentBrowserViewController: UIDocumentBrowserViewController {
    
    var logPresenter: LogPresenter?
    
    var presentedFileURLs: [URL] = [] {
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

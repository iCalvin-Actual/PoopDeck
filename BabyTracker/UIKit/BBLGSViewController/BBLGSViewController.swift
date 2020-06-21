//
//  BBLGSViewController.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

/// Root ViewController of the UIKit hosting app.
/// SwiftUI Views are displayed as child view controllers
/// Handles presentation of modals and managing open documents
class BBLGSViewController: UIViewController {
    
    /// Array of documents to show as open and to allow actions on
    var openDocs: [BabyLog] = [] {
        didSet {
            updateCurrentActivity()
            rebuildSwiftUIView()
        }
    }
    
    /// Wrapped value updates the SwiftUI HostingController presented as a child view
    var hostController: UIViewController? {
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
    
    /// Document browser allows user to import files from Files app
    lazy var documentBrowser: DocumentBrowserViewController = {
        let documentBrowser = DocumentBrowserViewController()
        
        documentBrowser.additionalLeadingNavigationBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(rebuildSwiftUIView))
        ]
        
        return documentBrowser
    }()
    
    @objc
    func rebuildSwiftUIView(animated: Bool = false) {
        dismissPresented(animated: animated) {
            self.buildSwiftUIView(animated: animated)
        }
    }
}

extension BBLGSViewController {
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


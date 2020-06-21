//
//  BBLGSViewController_Lifecycle.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

extension BBLGSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Root background for the app
        view.backgroundColor = .secondarySystemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buildSwiftUIView()
    }
    
    func buildSwiftUIView(animated: Bool = false) {
        let view = DocumentsView(
            logs: openDocs,
            selected: openDocs.first,
            onAction: onAction)
        
        self.hostController = UIHostingController(rootView: view)
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
}

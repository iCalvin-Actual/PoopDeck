//
//  BBLGSViewController_LogPresenter.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

extension BBLGSViewController: LogPresenter {
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
            self.openDocs = self.openDocs.filter({ !openedDocs.contains($0) }) + openedDocs
            self.rebuildSwiftUIView()
        }
    }
    
    func createDocument(at documentURL: URL, completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        dismissPresented(animated: true) {
            let newBabyView =
                BabyFormView(
                    onApply: { (formToApply) in
                        let newBaby = Baby()
                        newBaby.name = formToApply.name
                        newBaby.emoji = formToApply.emoji
                        newBaby.prefersEmoji = formToApply.useEmojiName
                        
                        newBaby.themeColor = formToApply.color
                        
                        if formToApply.saveBirthday {
                            newBaby.birthday = formToApply.birthday
                        }
                        
                        self.dismissPresented(animated: true) {
                            self.createNewDocument(with: newBaby, at: documentURL) { (result) in
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

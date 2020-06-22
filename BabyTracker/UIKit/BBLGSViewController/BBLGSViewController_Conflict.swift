//
//  BBLGSViewController_Conflict.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/21/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

extension BBLGSViewController {
    
    func resolveConflict(in log: BabyLog, with completion: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        
        guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: log.fileURL) else {
            /// No conflicts?
            completion?(.success(log))
            return
        }
        
        let dateSorted = versions.sorted(by: { ($0.modificationDate ?? Date()) < ($1.modificationDate ?? Date()) })
        
        self.displayConflictResolution(
            for: log,
            with: dateSorted,
            onResolve: { resolvedLogResult in
                guard case let .success(log) = resolvedLogResult else {
                    completion?(.failure(.unknown))
                    return
                }
                let result: Result<BabyLog, BabyError>
                do {
                    try NSFileVersion.removeOtherVersionsOfItem(at: log.fileURL)
                    versions.forEach({ $0.isResolved = true })
                    
                    versions.forEach({ v in
                        try? v.remove()
                    })
                    result = .success(log)
                } catch {
                    result = .failure(.unknown)
                }
                self.presentedViewController?.dismiss(animated: true, completion: {
                    completion?(result)
                })
            })
    }
    
    private func displayConflictResolution(for log: BabyLog, with versions: [NSFileVersion], onResolve: ((Result<BabyLog, BabyError>) -> Void)? = nil) {
        
        let conflict = BabyLogConflict(
            babyLog: log,
            versions: versions)
        
        let resolveView = ConflictResolutionView(
            conflict: conflict,
            revert: { (log) in
                log.revert(toContentsOf: log.fileURL, completionHandler: { success in
                    onResolve?(success ? .success(log) : .failure(.unknown))
                })
            },
            replace: { version in
                do {
                    try version.replaceItem(at: log.fileURL, options: .byMoving)
                    onResolve?(.success(log))
                } catch {
                    onResolve?(.failure(.unknown))
                }
            })

        let hostController = UIHostingController(rootView: resolveView)
        hostController.view.backgroundColor = .secondarySystemGroupedBackground
        self.present(hostController, animated: true)
    }
}

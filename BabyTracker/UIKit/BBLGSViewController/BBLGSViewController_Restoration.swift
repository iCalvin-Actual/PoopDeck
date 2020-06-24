//
//  BBLGSViewController_Restoration.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

// MARK: - Saving State
extension BBLGSViewController {
    
    private var groupDefaults: UserDefaults {
        return UserDefaults(suiteName: "group.com.chestnut.BabyTracker") ?? .standard
    }
    
    func updateCurrentActivity() {
        guard let window = view.window else { return }
        let currentActivity =
            createViewingDocsActivity() ??
            createNewDocActivity()
        
        window.windowScene?.userActivity = currentActivity
        currentActivity.becomeCurrent()
    }
    
    func createViewingDocsActivity() -> NSUserActivity? {
        /// Try to prevent app from re-opening any documents that have been moved to the trash
        let docs = openDocs.filter({ !$0.fileURL.pathComponents.contains(".Trash") })
        guard !docs.isEmpty else { return nil }
        
        /// Create security scoped bookmarks for each document
        var urlData: [Data] = []
        openDocs.map({ $0.fileURL }).forEach { (presentedFileURL) in
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
                print("Error creating bookmark: \(error.localizedDescription)")
            }
        }
        do {
            self.groupDefaults.setValue(try JSONEncoder().encode(urlData), forKey: "RecentURLBookmarks")
            self.groupDefaults.synchronize()
        } catch {
            print("STOP")
        }
        let activity = NSUserActivity(activityType: ActivityType.viewLogs)
        activity.userInfo?["URLBookmarks"] = urlData
        activity.title = "Viewing \(urlData.count) BabyLogs"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func createNewDocActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: ActivityType.newWindow)
        activity.title = "Poop Deck - Get Started"
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        return activity
    }
}

// MARK: - Restoring State
extension BBLGSViewController {
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == ActivityType.viewLogs {
            restoreViewingDocsActivity(activity)
        }
        restoreNewDocActivity(activity)
    }
    
    func restoreViewingDocsActivity(_ activity: NSUserActivity) {
        guard let urlData = activity.userInfo?["URLBookmarks"] as? [Data] else { return }
        var retrievedURLs: [URL] = []
        urlData.forEach { (presentedURLData) in
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: presentedURLData, bookmarkDataIsStale: &isStale)
                retrievedURLs.append(url)
            } catch {
                print("Error reading bookmark: \(error.localizedDescription)")
            }
        }
        presentDocuments(at: retrievedURLs)
    }
    
    func restoreNewDocActivity(_ activity: NSUserActivity) {
        openDocs = []
    }
}

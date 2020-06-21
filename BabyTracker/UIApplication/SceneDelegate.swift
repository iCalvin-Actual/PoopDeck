//
//  SceneDelegate.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var rootView: BBLGSSViewController = BBLGSSViewController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = self.rootView
            self.window = window
            window.makeKeyAndVisible()
        }
        
        if let restorationActivity = session.stateRestorationActivity {
            self.restoreUserActivityState(restorationActivity)
        }
    }
}

extension SceneDelegate {
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        self.rootView.restoreUserActivityState(activity)
        super.restoreUserActivityState(activity)
    }
}



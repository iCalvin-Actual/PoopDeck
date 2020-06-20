//
//  KeyboardResponder.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/15/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Publishes the height of the keyboard anytime a frame change notification is received
class KeyboardResponder {
    private var notificationCenter: NotificationCenter
    
    @Published var currentKeyboardHeight: CGFloat = 0
    
    init(center: NotificationCenter = .default) {
        self.notificationCenter = center
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc
    func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        currentKeyboardHeight = keyboardSize.height
    }
    
    @objc
    func keyboardWillHide(notification: Notification) {
        currentKeyboardHeight = 0
    }
}

extension KeyboardResponder: ObservableObject { }

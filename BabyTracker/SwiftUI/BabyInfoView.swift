//
//  BabyInfoView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/12/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

/// Summary view for identifiable information at the top of the LogView
struct BabyInfoView: View {
    
    /// The active document containing the baby
    @ObservedObject var log: BabyLog
    
    /// Toggles presentation of baby form
    @State var editBaby: Bool = false
    
    /// Sends color change up to top level to update other subviews
    var onColorUpdate: ((_: BabyLog, _: ThemeColor) -> Void)?
    
    /// Binding boolean to pass to drop handler
    @State private var targetDrop: Bool = false
    
    // MARK: - Views
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            editButton()
                .accentColor(log.baby.themeColor?.colorValue)
                
            
            Spacer()
            
            if log.baby.birthday != nil {
                AgeView(birthday: log.baby.birthday)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .floatingPlease()
        .padding(.horizontal)
        
        // Handles drop events for custom colors
        .onDrop(of: ["com.apple.uikit.color"], isTargeted: $targetDrop, perform: { (items) in
            guard let item = items.first else { return false }
            _ = item.loadObject(ofClass: UIColor.self) { color, _ in
                if let color = color as? UIColor {
                    self.onColorUpdate?(self.log, ThemeColor(uicolor: color))
                }
            }
            return true
        })
        .sheet(
            isPresented: $editBaby,
            content: editingForm)
    }
    
    func emojiLabel() -> AnyView {
        guard !log.baby.emoji.isEmpty else { return EmptyView().anyPlease() }
        return Text(log.baby.emoji)
            .anyPlease()
    }
    
    func nameLabel() -> some View {
        Text(log.baby.name)
            .fontWeight(.heavy)
            .foregroundColor(log.baby.themeColor?.colorValue ?? .primary)
    }
    
    func editButton() -> some View {
        Button(action: {
            self.editBaby = true
        }) {
            if !log.baby.emoji.isEmpty {
                emojiLabel()
            }
            if log.baby.displayName != log.baby.emoji {
                nameLabel()
                .font(.largeTitle)
            }
        }
    }
    
    func editingForm() -> some View {
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
                
                self.log.baby = newBaby
                self.editBaby = false
        },
            restoreContent: .init(
                name: log.baby.name,
                emoji: log.baby.emoji,
                useEmojiName: log.baby.prefersEmoji,
                color: log.baby.themeColor ?? ThemeColor.random,
                birthday: log.baby.birthday ?? .oneWeekAgo,
                saveBirthday: log.baby.birthday == nil))
    }
}

// MARK: - Previews
struct BabyInfoView_Previews: PreviewProvider {
    static var babyLog: BabyLog {
        let log = BabyLog(fileURL: Bundle.main.url(forResource: "MyBabyLog", withExtension: "bblg")!)
        log.baby = baby
        return log
    }
    static var baby: Baby {
        let baby = Baby()
        baby.name = "Sophia"
        baby.emoji = "👶"
        var components = DateComponents()
        components.month = 3
        components.day = 14
        components.year = 2020
        components.calendar = .current
        if let date = components.date {
            baby.birthday = date
        }
        baby.themeColor = ThemeColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        BabyInfoView(log: babyLog)
    }
}

//
//  BabyInfoView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/12/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

// MARK: - BabyInfoView
struct BabyInfoView: View {
    @ObservedObject var log: BabyLog
    @State var editBaby: Bool = false
    
    var onColorUpdate: ((_: BabyLog, _: PreferredColor) -> Void)?
    
    @State private var targetDrop: Bool = true
    
    // MARK: - Views
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            editButton()
                .accentColor(log.baby.themeColor?.color)
                
            
            Spacer()
            
            if log.baby.birthday != nil {
                AgeView(birthday: log.baby.birthday)
                    .floatingPlease(padding: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(22)
        .padding(.horizontal)
        .onDrop(of: ["com.apple.uikit.color"], isTargeted: $targetDrop, perform: { (items) in
            guard let item = items.first else { return false }
            _ = item.loadObject(ofClass: UIColor.self) { color, _ in
                if let color = color as? UIColor {
                    self.onColorUpdate?(self.log, PreferredColor(uicolor: color))
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
            .foregroundColor(log.baby.themeColor?.color ?? .primary)
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
        NewBabyForm(
            onApply: { (babyToApply) in
            self.log.baby = babyToApply
            self.editBaby = false
        },
            babyTextName: self.log.baby.name,
            babyEmojiName: self.log.baby.emoji,
            useEmojiName: self.log.baby.prefersEmoji,
            userPrefersEmoji: self.log.baby.prefersEmoji,
            color: self.log.baby.themeColor ?? .random,
            birthday: self.log.baby.birthday ?? .oneWeekAgo,
            saveBirthday: self.log.baby.birthday != nil)
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
        baby.themeColor = PreferredColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        BabyInfoView(log: babyLog)
    }
}

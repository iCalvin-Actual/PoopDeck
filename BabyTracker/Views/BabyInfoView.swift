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
    
    // MARK: - Views
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if !log.baby.emoji.isEmpty {
                emojiLabel()
            }
            if !log.baby.name.isEmpty {
                nameLabel()
                .font(.largeTitle)
            }
            editButton()
                .accentColor(log.baby.themeColor?.color)
                .font(.title)
            
            Spacer()
            
            if log.baby.birthday != nil {
                AgeView(birthday: log.baby.birthday)
                    .raisedButtonPlease(padding: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(22)
        .padding(.horizontal)
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
        Text(log.baby.displayName)
            .fontWeight(.heavy)
            .foregroundColor(log.baby.themeColor?.color ?? .primary)
    }
    
    func editButton() -> some View {
        Button(action: {
            self.editBaby = true
        }) {
            Image(systemName: "arrowtriangle.right.circle.fill")
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

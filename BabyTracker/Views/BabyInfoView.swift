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
    @Binding var editBaby: Bool
    
    // MARK: - Views
    var body: some View {
        HStack(spacing: 8) {
            babyInfoStack()
            
            Spacer()
                
            editButton()
            .sheet(
                isPresented: $editBaby,
                content: editingForm)
        }
        .padding()
        .cornerRadius(22)
        .padding(.horizontal)
    }
    
    func babyInfoStack() -> some View {
        VStack(alignment: .leading) {
            if !log.baby.emoji.isEmpty {
                emojiLabel()
            }
            
            if !log.baby.name.isEmpty {
                nameLabel()
            }
            if log.baby.birthday != nil {
                AgeView(birthday: log.baby.birthday)
            }
        }
    }
    
    func emojiLabel() -> AnyView {
        guard !log.baby.emoji.isEmpty else { return EmptyView().anyPlease() }
        return Text(log.baby.emoji)
            .anyPlease()
    }
    
    func nameLabel() -> some View {
        Text(log.baby.displayName)
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
            babyTextName: self.log.baby.nameComponents != nil ? self.log.baby.name : "",
            babyEmojiName: self.log.baby.emoji,
            useEmojiName: self.log.baby.nameComponents == nil,
            color: self.log.baby.themeColor ?? .random,
            birthday: self.log.baby.birthday ?? Date(),
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
        BabyInfoView(log: babyLog, editBaby: .constant(false))
    }
}

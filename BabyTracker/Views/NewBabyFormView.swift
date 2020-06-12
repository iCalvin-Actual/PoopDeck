//
//  NewBabyFormView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

extension Baby {
    var validName: Bool {
        return !name.isEmpty || !emoji.isEmpty
    }
}

struct NewBabyForm: View {
    var onApply: ((Baby) -> Void)?
    
    @State var babyTextName: String = ""
    @State var babyEmojiName: String = Baby.emojiSet.randomElement() ?? ""
    @State var useEmojiName: Bool = true
    @State private var userPrefersEmoji: Bool = false
    
    private var activeName: String {
        if useEmojiName { return babyEmojiName }
        return babyTextName
    }
    
    @State var color: PreferredColor = PreferredColor.prebuiltSet.randomElement()!
    @State var birthday: Date = .oneWeekAgo
    
    @State var saveBirthday: Bool = true
    
    private var babyFromForm: Baby {
        let baby = Baby()
        baby.name = activeName
        if self.saveBirthday {
            baby.birthday = birthday
        }
        baby.emoji = babyEmojiName
        baby.themeColor = color
        
        return baby
    }
    
    var body: some View {
        VStack {
            ZStack {
                headerView()
                
                HStack {
                    Spacer()
                    saveButton()
                }
            }
            .padding()
            NavigationView {
                Form {
                    nameSection()
                    
                    birthdaySection()
                    
                    colorSection()
                }
                .groupedStylePlease()
                .hideNavBarPlease()
            }
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Spacer()
            BabyIconView(baby: self.babyFromForm)
            Spacer()
        }
    }
    
    private func saveButton() -> some View {
        Button(action: {
            self.validateAndApply()
        }) {
            HStack {
                Text("Save")
                Image(systemName: "arrow.down.circle.fill")
            }
            .padding(2)
            .raisedButtonPlease(padding: 4)
        }
    }
    
    private func nameSection() -> some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $babyTextName)
                .autocapitalization(.words)
                .textContentType(.name)
                .onReceive(Just(babyTextName)) { (newTextName) in
                    if !self.userPrefersEmoji {
                        self.useEmojiName = newTextName.isEmpty
                    }
                }
            
            Picker("Emoji", selection: $babyEmojiName) {
                ForEach(Baby.emojiSet + [""], id: \.self) { Text($0) }
            }
            
            Toggle(isOn: $useEmojiName, label: {
                Text("Use Emoji as 'Name'")
            })
            .onTapGesture(perform: {
                self.userPrefersEmoji = !self.useEmojiName
            })
            .onAppear {
                if self.babyEmojiName.isEmpty && self.useEmojiName {
                    self.useEmojiName = false
                }
            }
            .onReceive(Just(userPrefersEmoji)) { (newValue) in
                if !self.babyTextName.isEmpty {
                    self.userPrefersEmoji = newValue
                }
            }
        }
    }
    
    private func birthdaySection() -> some View {
        Section {
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            Toggle(isOn: $saveBirthday, label: {
                Text("Save birthday")
            })
        }
    }
    
    private func colorSection() -> some View {
        Section(footer: Text("Theme color to use for this BabyLog")) {
            Picker("Color", selection: $color) {
                ForEach(PreferredColor.prebuiltSet, id: \.self) { color in
                    ColoredCircle(color: color)
                        .frame(width: 44, height: 44, alignment: .trailing)
                }
            }
        }
    }
    
    private func validateAndApply() {
        let baby = self.babyFromForm
        guard baby.validName else { return }
        onApply?(baby)
    }
}

struct NewBabyFormView_Previews: PreviewProvider {
    static var previews: some View {
        NewBabyForm()
    }
}

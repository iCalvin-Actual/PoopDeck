//
//  BabyFormView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

struct BabyFormView: View {
    var onApply: ((FormContent) -> Void)?
    
    @State var content: FormContent = .init()
    var restoreContent: FormContent?
    
    /// content.useEmoji can be flipped if the baby name is invalid. This boolean tracks whether the user has explicitely expressed an emoji preference
    @State var userPrefersEmoji: Bool = false
    
    var body: some View {
        VStack {
            /// Use ZStack to header view stays center without accomidating for save button
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
        .onAppear {
            if let contentToRestore = self.restoreContent {
                self.content = contentToRestore
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
            .floatingPlease(padding: 4)
        }
    }
    
    private func nameSection() -> some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $content.name)
                .autocapitalization(.words)
                .textContentType(.name)
                .onReceive(Just(content.name)) { (newTextName) in
                    if !self.userPrefersEmoji {
                        self.content.useEmojiName = newTextName.isEmpty
                    }
                }
            
            Picker("Emoji", selection: $content.emoji) {
                ForEach(Baby.emojiSet + [""], id: \.self) { Text($0) }
            }
            
            Toggle(isOn: $content.useEmojiName, label: {
                Text("Use Emoji as 'Name'")
            })
            .onTapGesture(perform: {
                /// On an explicit touch gesture mark the user's preference
                self.userPrefersEmoji = !self.content.useEmojiName
            })
            .onReceive(Just(userPrefersEmoji)) { (newValue) in
                /// Should prevent new value from applying if the name isn't empty, although on second look this doesn't seem correct
                if !self.content.name.isEmpty {
                    self.userPrefersEmoji = newValue
                }
            }
        }
    }
    
    private func birthdaySection() -> some View {
        Section {
            DatePicker("Birthday", selection: $content.birthday, displayedComponents: .date)
            
            Toggle(isOn: $content.saveBirthday, label: {
                Text("Save birthday")
            })
        }
    }
    
    private func colorSection() -> some View {
        Section(footer: Text("Theme color to use for this BabyLog")) {
            Picker("Color", selection: $content.color) {
                ForEach(ThemeColor.prebuiltSet, id: \.self) { color in
                    ThemeColorView(theme: color)
                        .frame(width: 44, height: 44, alignment: .trailing)
                }
            }
        }
    }
}

struct NewBabyFormView_Previews: PreviewProvider {
    static var previews: some View {
        BabyFormView()
    }
}

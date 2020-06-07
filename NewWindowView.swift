//
//  NewWindowView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

struct NewWindowView: View {
    
    var onCreate: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            Text("PoopDeck")
                .font(.system(.largeTitle, design: .rounded))
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.onCreate?()
                }) {
                    VStack {
                        Image(systemName: "plus.square.fill")
                        Text("New")
                    }
                }
                
                
                Spacer()
            }
            Spacer()
        }
    }
}

extension Baby {
    var invalidName: Bool {
        return name.isEmpty && emoji.isEmpty
    }
}

struct NewBabyForm: View {
    var onApply: ((Baby) -> Void)?
    
    @State var babyTextName: String = ""
    @State var babyEmojiName: String = Baby.emojiSet.randomElement() ?? ""
    var babyName: String {
        if useEmoji { return babyEmojiName }
        return babyTextName
    }
    @State var color: PreferredColor = PreferredColor.prebuiltSet.randomElement()!
    @State var birthday: Date = Date(timeIntervalSinceNow: -10080)
    
    @State var useEmoji: Bool = true
    @State var useBirthday: Bool = false
    
    var baby: Baby {
        let baby = Baby()
        baby.name = babyName
        if self.useBirthday {
            baby.birthday = birthday
        }
        baby.emoji = babyEmojiName
        baby.color = color
        
        return baby
    }
    
//    var emojiFormSet: [
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    BabyIconView(baby: self.baby)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {
                        self.validateAndApply()
                    }) {
                        HStack {
                            Text("Save")
                            Image(systemName: "arrow.down.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                    }
                }
            }
            .padding()
            NavigationView {
                Form {
                    Section(header: Text("Name")) {
                        TextField("Name", text: $babyTextName)
                            .autocapitalization(.words)
                            .textContentType(.name)
                        Picker("Emoji", selection: $babyEmojiName) {
                            ForEach(Baby.emojiSet + [""], id: \.self) { Text($0) }
                        }
                        
                        Toggle(isOn: $useEmoji, label: {
                            Text("Use Emoji as 'Name'")
                        })
                        .onAppear {
                            if self.babyEmojiName.isEmpty && self.useEmoji {
                                self.useEmoji = false
                            }
                        }
                    }
                    
                    Section {
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                        Toggle(isOn: $useBirthday, label: {
                            Text("Save birthday")
                        })
                    }
                    
                    Section(footer: Text("Theme color to use for this BabyLog")) {
                        Picker("Color", selection: $color) {
                            ForEach(PreferredColor.prebuiltSet, id: \.self) { color in
                                ColoredCircle(color: color)
                                    .frame(width: 44, height: 44, alignment: .trailing)
                            }
                        }
                    }
                    
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    func borderIfNeeded(_ text: String) -> AnyView {
        if text == babyName {
            return RoundedRectangle(cornerRadius: 22.0, style: .circular)
                .stroke(Color(.tertiarySystemBackground), lineWidth: 1)
                .anyify()
        }
        return EmptyView().anyify()
    }
    
    func validateAndApply() {
        let baby = self.baby
        guard !baby.invalidName else { return }
        onApply?(baby)
    }
}

struct NewWindowView_Previews: PreviewProvider {
    static var previews: some View {
        NewBabyForm()
    }
}

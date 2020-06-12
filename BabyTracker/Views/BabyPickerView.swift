//
//  BabyPickerView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

// MARK: - Baby Actions
enum BabyAction {
    case select(_ baby: Baby?)
    case show(_ baby: Baby)
    case save(_ baby: Baby)
    case close(_ baby: Baby)
    case delete(_ baby: Baby)
}

// MARK: - Baby Picker
struct BabyPickerView: View {
    var babies: [Baby] = []
    var selected: Baby?
    
    var onAction: ((BabyAction) -> Void)?
    
    // MARK: - Views
    
    var body: some View {
        HStack {
            openDocsView()
            
            Spacer()
            
            newDocButton()
        }
        .padding(.horizontal)
    }
    
    private func openDocsView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(babies, id: \.self) { baby in
                    BabyIconView(baby: baby, onSelect: { baby in
                        self.onAction?(.select(baby))
                    })
                    .contextMenu {
                        
                        self.revealButton(baby)
                        self.saveButton(baby)
                        self.closeButton(baby)
                        self.deleteButton(baby)
                        
                    }
                }
            }
            .frame(height: 44.0, alignment: .top)
            .padding(2)
        }
    }
    
    // MARK: - Buttons
    
    private func revealButton(_ baby: Baby) -> some View {
        Button(action: {
            self.onAction?(.show(baby))
        }) {
            Text("Show File")
            Image(systemName: "doc.text.magnifyingglass")
        }
    }
    
    private func saveButton(_ baby: Baby) -> some View {
        Button(action: {
            self.onAction?(.save(baby))
        }) {
            Text("Save Now")
            Image(systemName: "doc.append")
        }
    }
    
    private func closeButton(_ baby: Baby) -> some View {
        Button(action: {
            self.onAction?(.save(baby))
        }) {
            Text("Close")
            Image(systemName: "xmark.square")
        }
    }
    
    private func deleteButton(_ baby: Baby) -> some View {
        Button(action: {
            self.onAction?(.save(baby))
        }) {
            Text("Delete")
            Image(systemName: "trash")
        }
    }
    
    private func newDocButton() -> some View {
        Button(action: {
            self.onAction?(.select(nil))
        }) {
            Image(systemName: "plus.square.on.square.fill")
            .padding(8)
        }
        .padding(.trailing, 8)
    }
}

// MARK: - Previews
struct BabyPickerView_Previews: PreviewProvider {
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
        BabyPickerView(babies: [baby], selected: baby, onAction: nil)
    }
}

//
//  BabyPickerView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

// MARK: - Log Picker Actions
enum LogPickerAction {
    case select(_ baby: BabyLog?)
    case show(_ baby: BabyLog)
    case save(_ baby: BabyLog)
    case close(_ baby: BabyLog)
    case delete(_ baby: BabyLog)
    case forceClose
}

// MARK: - Baby Picker
struct BabyPickerView: View {
    var logs: [BabyLog] = []
    @ObservedObject var selected: BabyLog
    
    var onAction: ((LogPickerAction) -> Void)?
    
    // MARK: - Views
    
    var body: some View {
        HStack {
            openDocsView()
            
            Spacer()
            
            newDocButton()
            .contextMenu {
                
                Button(action: {
                    self.onAction?(.forceClose)
                }) {
                    Text("Close All")
                    Image(systemName: "xmark.circle")
                }
                
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private func openDocsView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(logs, id: \.self) { log in
                    BabyIconView(baby: log.baby, selected: log == self.selected, onSelect: { baby in
                        withAnimation {
                            self.onAction?(.select(log))
                        }
                    })
                    .contextMenu {
                        
                        self.revealButton(log)
                        self.saveButton(log)
                        self.closeButton(log)
                        self.deleteButton(log)
                        
                    }
                }
                .padding(6)
            }
            .frame(height: 56.0, alignment: .top)
        }
    }
    
    // MARK: - Buttons
    
    private func revealButton(_ babyLog: BabyLog) -> some View {
        Button(action: {
            self.onAction?(.show(babyLog))
        }) {
            Text("Show File")
            Image(systemName: "doc.text.magnifyingglass")
        }
    }
    
    private func saveButton(_ babyLog: BabyLog) -> some View {
        Button(action: {
            self.onAction?(.save(babyLog))
        }) {
            Text("Save Now")
            Image(systemName: "doc.append")
        }
    }
    
    private func closeButton(_ babyLog: BabyLog) -> some View {
        Button(action: {
            self.onAction?(.close(babyLog))
        }) {
            Text("Close")
            Image(systemName: "xmark.square")
        }
    }
    
    private func deleteButton(_ babyLog: BabyLog) -> some View {
        Button(action: {
            self.onAction?(.delete(babyLog))
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
        }
        .font(.system(size: 20.0, weight: .semibold))
        .raisedButtonPlease()
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
        VStack {
            BabyPickerView(logs: [babyLog, babyLog], selected: babyLog, onAction: nil)
            Spacer()
        }
        .background(Color(.secondarySystemBackground))
    }
}

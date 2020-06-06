//
//  DocumentsView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

enum DocumentAction {
    case createNew
    case show(_ log: BabyLog)
    case save(_ log: BabyLog)
    case close(_ log: BabyLog)
    case delete(_ log: BabyLog)
    case resolve(_ log: BabyLog)
}

struct DocumentsView: View {
    @State var logs: [BabyLog] = []
    
    @State var selected: BabyLog?
    
    var onAction: ((DocumentAction) -> Void)?
    
    var body: some View {
        VStack {
            BabyPickerView(babies: logs.map({ $0.baby }), onAction: self.onBabyAction)
                .background(Color(.secondarySystemBackground))
    
            Divider()
            self.selectedOrEmpty
            
        }
        .background(Color(.secondarySystemBackground))
        .onAppear {
            if self.selected == nil, let first = self.logs.first {
                self.selected = first
            }
        }
    }
    
    func onBabyAction(_ babyAction: BabyAction) {
        switch babyAction {
        case .show(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.show(actionDoc))
        case .select(let baby):
            guard let baby = baby else {
                self.onAction?(.createNew)
                return
            }
            self.selected = self.log(for: baby)
        case .save(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.save(actionDoc))
        case .close(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.close(actionDoc))
        case .delete(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.delete(actionDoc))
        }
    }
    
    func log(for baby: Baby) -> BabyLog? {
        return logs.first(where: { $0.baby == baby })
    }
    
    var selectedOrEmpty: AnyView {
        if let selected = self.selected {
            return LogView(log: selected, onAction: self.onAction).anyify()
        }
        /// Better no open docs view?
        return EmptyView().anyify()
    }
}

enum BabyAction {
    case select(_ baby: Baby?)
    case show(_ baby: Baby)
    case save(_ baby: Baby)
    case close(_ baby: Baby)
    case delete(_ baby: Baby)
}

struct BabyPickerView: View {
    var babies: [Baby] = []
    var selected: Baby?
    
    var onAction: ((BabyAction) -> Void)?
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(babies, id: \.self) { baby in
                        BabyIconView(baby: baby, onSelect: { baby in
                            self.onAction?(.select(baby))
                        })
                        .contextMenu {
                            
                            Button(action: {
                                self.onAction?(.show(baby))
                            }) {
                                Text("Show File")
                                Image(systemName: "doc.text.magnifyingglass")
                            }
                            
                            Button(action: {
                                self.onAction?(.save(baby))
                            }) {
                                Text("Save Now")
                                Image(systemName: "doc.append")
                            }
                            
                            Button(action: {
                                self.onAction?(.close(baby))
                            }) {
                                Text("Close")
                                Image(systemName: "xmark.square")
                            }
                            
                            Button(action: {
                                self.onAction?(.delete(baby))
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .frame(height: 44.0, alignment: .top)
                .padding(2)
            }
            
            Spacer()
            Button(action: {
                self.onAction?(.select(nil))
            }) {
                Image(systemName: "plus.square.on.square.fill")
                .padding(8)
                    .background(Color(.secondarySystemBackground))
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal)
    }
}

struct BabyIconView: View {
    @ObservedObject var baby: Baby
    var selected = false
    
    var onSelect: ((Baby) -> Void)?
    
    var body: some View {
        Button(action: {
            self.onSelect?(self.baby)
        }) {
            ZStack {
                ColoredCircle(color: baby.color ?? .random)
                    
                Circle()
                    .stroke(selected ? Color.black : Color(.secondarySystemBackground), lineWidth: 2)
                
                Text(baby.displayInitial)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 44, height: 44, alignment: .center)
    }
}

struct ColoredCircle: View {
    let color: PreferredColor
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(red: color.r, green: color.g, blue: color.b))
            
            Circle()
                .foregroundColor(Color(UIColor.tertiarySystemBackground.withAlphaComponent(0.75)))
        }
    }
}

struct AgeView: View {
    var birthday: Date?
    var body: some View {
        self.birthdayInfoIfNeeded()
    }
    
    @State var ageStyle: DateView = .days
    
    enum DateView {
        case days
        case weeks
        case months
        case full
        
        var dateFormatter: DateFormatter {
            switch self {
            case .days:
                return DateFormatter()
            case .weeks:
                return DateFormatter()
            case .months:
                return DateFormatter()
            case .full:
                return DateFormatter()
            }
        }
    }
    
    func birthdayInfoIfNeeded() -> AnyView {
        guard let birthday = birthday else {
            return EmptyView().anyify()
        }
        
        return Text(self.ageStyle.dateFormatter.string(from: birthday))
            .font(.headline)
            .anyify()
    }
}

struct LogView: View {
    @ObservedObject var log: BabyLog
    @Environment(\.editMode) var editMode
    
    @State private var allowChanges: Bool = true
    @State private var resolvingConflict: Bool = false
    @State private var editBaby: Bool = false
    
    var onAction: ((DocumentAction) -> Void)?
    
    var emojiLabel: AnyView {
        guard let emoji = log.baby.emoji, !emoji.isEmpty else { return EmptyView().anyify() }
        return Text(emoji).anyify()
    }
    
    var body: some View {
        VStack {
            HStack {
                emojiLabel
                VStack(alignment: .leading) {
                    Text(log.baby.displayName)
                        .font(.system(size: 42.0, weight: .heavy, design: .rounded))
                        .foregroundColor(log.baby.color?.color ?? .primary)
                    AgeView(birthday: nil)
                }
                Spacer()
                Button(action: {
                    self.editBaby = true
                }) {
                    Image(systemName: "arrowtriangle.right.circle.fill")
                }
                .sheet(isPresented: $editBaby, content: {
                    NewBabyForm(
                        onApply: { (babyToApply) in
                        self.log.baby = babyToApply
                        self.editBaby = false
                    },
                        babyTextName: self.log.baby.nameComponents != nil ? self.log.baby.name : "",
                        babyEmojiName: self.log.baby.emoji ?? "",
                        color: self.log.baby.color ?? .random,
                        birthday: self.log.baby.birthday ?? Date(),
                        useEmoji: self.log.baby.nameComponents == nil,
                        useBirthday: self.log.baby.birthday != nil)
                })
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(22)
            .padding(.horizontal)
            .padding(.bottom)
            
            FeedView(babyLog: log)
        }
        .background(Color(.secondarySystemBackground))
        .onReceive(NotificationCenter.default.publisher(for: UIDocument.stateChangedNotification, object: log), perform: self.handleStateChange)
    }
    
    func handleStateChange(_ notification: Notification) {
        switch log.documentState {
        case .editingDisabled:
            self.allowChanges = false
            print("Pause changes")
        case .inConflict:
            /// Already in conflict mode
            guard !self.resolvingConflict else { return }
            self.resolvingConflict = true
            self.onAction?(.resolve(self.log))
        case .savingError:
            print("Error saving")
        case .closed:
            print("Do something?")
        case .progressAvailable:
            print("Show progress?")
        case .normal:
            self.allowChanges = true
            print("Normal?")
        default:
            print("Unknown Value? \(log.documentState)")
        }
    }
}

struct FeedSummaryView: View {
    @Binding var manager: BabyEventRecordsManager
    
    @State var feedEvents: [UUID: FeedEvent] = [:]
    
    var allowChanges: Bool = false
    
    var dateSortedEvents: [FeedEvent] {
        return feedEvents.values.sorted(by: { $0.date > $1.date })
    }
    
    var latestEvent: FeedEvent? {
        return dateSortedEvents.last
    }
    
    var body: some View {
        Text("\(feedEvents.count) Events")
            .onTapGesture {
                guard self.allowChanges else { return }
                let feedEvent = FeedEvent(source: .breast(.both))
                self.manager.save(feedEvent) { (result) in
                    switch result {
                    case .failure:
                        /// Bubble up error
                        print("Bubble")
                    case .success:
                        self.reloadEvents()
                    }
                }
            }
            .onAppear {
                self.reloadEvents()
            }
    }
    
    func reloadEvents() {
        manager.groupOfType { (result: Result<[UUID: FeedEvent], BabyError>) in
            if case let .success(newEvents) = result {
                feedEvents = newEvents
            }
        }
    }
}

struct BabyIconView_Preview: PreviewProvider {
    static var babyLog: BabyLog {
        let log = BabyLog(fileURL: Bundle.main.url(forResource: "NewBaby", withExtension: "bblg")!)
        log.baby = baby
        return log
    }
    static var baby: Baby {
        let baby = Baby()
        baby.name = "Sophia"
        baby.color = PreferredColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        DocumentsView(logs: [babyLog])
    }
}

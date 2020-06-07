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
        Button(action: {
            switch self.ageStyle {
            case .days:
                self.ageStyle = .weeks
            case .weeks:
                self.ageStyle = .months
            case .months:
                self.ageStyle = .full
            case .full:
                self.ageStyle = .days
            }
        }) {
            Text(ageString)
            .font(.headline)
            .foregroundColor(.primary)
        }
    }
    
    @State var ageStyle: DateView = .days
    var formatter: DateComponentsFormatter = .init()
    
    var ageString: String {
        guard let birthday = birthday else {
            return ""
        }
        switch ageStyle {
        case .days:
            formatter.allowedUnits = [.day]
        case .weeks:
            formatter.allowedUnits = [.weekOfMonth, .day]
        case .months:
            formatter.allowedUnits = [.month, .weekOfMonth, .day]
        case .full:
            formatter.allowedUnits = [.year, .month, .day]
        }
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 2
        return formatter.string(from: birthday, to: Date()) ?? ""
    }
    
    enum DateView {
        case days
        case weeks
        case months
        case full
    }
}

struct LogView: View {
    @ObservedObject var log: BabyLog
    @Environment(\.editMode) var editMode
    
    @State private var allowChanges: Bool = true
    @State private var resolvingConflict: Bool = false
    @State private var editBaby: Bool = false
    @State var targetDate: Date = Date()
    
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    
    var onAction: ((DocumentAction) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            BabyInfoView(log: log, editBaby: $editBaby)
            
            DateStepperView(targetDate: $targetDate)
            
            EventSummaryView(log: log, filter: { (event: FeedEvent) -> Bool in
                if case .bottle = event.source {
                    return true
                }
                return false
            }, onAction: self.onEventAction)
            
            FeedView(babyLog: log)
        }
        .padding(.top)
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
    
    func onEventAction(_ action: EventAction<FeedEvent>) {
        switch action {
        case .create(let event), .update(let event):
            self.log.save(event) { (_) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .showDetail(let events):
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: EventAction<DiaperEvent>) {
        print("Handle Diaper")
    }
    
}

struct DateStepperView: View {
    @Binding var targetDate: Date
    
    @State var currentDate: Date = Date() {
        didSet {
            self.updateTargetDate()
        }
    }
    @State var showDatePicker: Bool = false
    @State var showTimePicker: Bool = false
    
    @State var components: DateComponents = .init() {
        didSet {
            self.updateTargetDate()
        }
    }
    
    func updateTargetDate() {
        self.targetDate = self.calendar.date(byAdding: self.components, to: self.currentDate) ?? Date()
    }
    
    let ticker: TickPublisher = .init()
    
    var calendar: Calendar { return .current }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            /// Time Display
            HStack {
                Text(DateFormatter.shortDisplay.string(from: targetDate))
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    withAnimation(.default, {
                        self.showDatePicker.toggle()
                    })
                }) {
                    Image(systemName: self.showDatePicker ? "calendar.circle" : "calendar.circle.fill")
                        .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                }
                Button(action: {
                    withAnimation(.default) {
                        self.showTimePicker.toggle()
                    }
                }) {
                    Image(systemName: self.showTimePicker ? "clock" : "clock.fill")
                        .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                }
            }
            
            if self.showDatePicker {
                /// Date Editor
                HStack {
                    Text("Date")
                    .font(.title)
                    Spacer()
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, day: -1))
                    }) {
                        Image(systemName: "arrowtriangle.left.circle.fill")
                            .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                    }
                    Text(DateFormatter.shortDateDisplay.string(from: targetDate))
                        .font(.title)
                        .fontWeight(.heavy)
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, day: 1))
                    }) {
                        Image(systemName: "arrowtriangle.right.circle.fill")
                            .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                    }
                    Spacer()
                }
            }
            
            if self.showTimePicker {
                /// Time Editor
                HStack {
                    Text("Time")
                    .font(.title)
                    Spacer()
                    
                    /// Hour editor
                    VStack {
                        Button(action: {
                            self.changeDate(DateComponents(calendar: self.calendar, hour: 1))
                        }) {
                            Image(systemName: "arrowtriangle.up.circle.fill")
                                .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                        }
                        
                        Text(DateFormatter.hourFormatter.string(from: self.targetDate))
                            .font(.title)
                            .fontWeight(.heavy)
                        
                        Button(action: {
                            self.changeDate(DateComponents(calendar: self.calendar, hour: -1))
                        }) {
                            Image(systemName: "arrowtriangle.down.circle.fill")
                                .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                        }
                    }
                    
                    Text(":")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                self.changeDate(DateComponents(calendar: self.calendar, minute: 10))
                            }) {
                                Image(systemName: "arrowtriangle.up.circle.fill")
                                    .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                            }
                            
                            Button(action: {
                                self.changeDate(DateComponents(calendar: self.calendar, minute: 1))
                            }) {
                                Image(systemName: "arrowtriangle.up.circle.fill")
                                    .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                            }
                        }
                        
                        Text(DateFormatter.minuteFormatter.string(from: targetDate))
                            .font(.title)
                            .fontWeight(.heavy)
                        HStack {
                            Button(action: {
                                self.changeDate(DateComponents(calendar: self.calendar, minute: -10))
                            }) {
                                Image(systemName: "arrowtriangle.down.circle.fill")
                                    .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                            }
                            
                            Button(action: {
                                self.changeDate(DateComponents(calendar: self.calendar, minute: -1))
                            }) {
                                Image(systemName: "arrowtriangle.down.circle.fill")
                                    .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                            }
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            self.changeDate(DateComponents(calendar: self.calendar, hour: 12))
                        }) {
                            Image(systemName: "arrowtriangle.up.circle.fill")
                                .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                        }
                        
                        Text(DateFormatter.ampmFormatter.string(from: targetDate))
                            .font(.title)
                            .fontWeight(.heavy)
                            
                        Button(action: {
                            self.changeDate(DateComponents(calendar: self.calendar, hour: -12))
                        }) {
                            Image(systemName: "arrowtriangle.down.circle.fill")
                                .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .onReceive(ticker.currentTimePublisher) { newCurrentTime in
            self.currentDate = newCurrentTime
        }
    }
    
    func changeDate(_ components: DateComponents) {
        let newComponents = DateComponents(
            calendar: .current,
            day: (self.components.day ?? 0) + (components.day ?? 0),
            hour: (self.components.hour ?? 0) + (components.hour ?? 0),
            minute: (self.components.minute ?? 0) + (components.minute ?? 0))
        self.components = newComponents
    }
}

enum EventAction<E: BabyEvent> {
    case create(_: E)
    case update(_: E)
    case remove(_: E)
    case showDetail(_: [E])
    case undo
    case redo
}

struct EventSummaryView<E: BabyEvent>: View {
    @State var log: BabyLog
    var filter: ((_ event: E) -> Bool)?
    
    var onAction: ((EventAction<E>) -> Void)?
    
    @State var isLoading: Bool = true
    @State var events: [E] = []
    @State var items: [UUID: E] = [:]
    
    var filteredEvents: [E] {
        guard let filter = self.filter else {
            return []
        }
        return items.values.filter(filter)
    }
    
    var sortedEvents: [E] {
        return filteredEvents.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        
        Text("Events: \(sortedEvents.count)")
            .onTapGesture {
                let feedEvent = FeedEvent(source: .bottle)
                self.onAction?(.create(feedEvent as! E))
            }
            .onAppear {
                if self.isLoading {
                    self.runFilter()
                }
        }
    }
    
    func runFilter() {
        self.log.groupOfType(completion: { (result: Result<[UUID: E], BabyError>) in
            guard let filter = self.filter else {
                self.isLoading = false
                return
            }
            if case let .success(groupDict) = result {
                self.items = groupDict
                self.events = groupDict.values.filter(filter).sorted(by: { $0.date < $1.date })
            }
            self.isLoading = false
        })
    }
}

struct BabyInfoView: View {
    let log: BabyLog
    @Binding var editBaby: Bool
    
    var emojiLabel: AnyView {
        guard !log.baby.emoji.isEmpty else { return EmptyView().anyify() }
        return Text(log.baby.emoji)
            .font(.headline)
            .anyify()
    }
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading) {
                if !log.baby.emoji.isEmpty {
                    emojiLabel
                }
                if !log.baby.name.isEmpty {
                    Text(log.baby.displayName)
                        .font(.system(size: 42.0, weight: .heavy, design: .rounded))
                        .foregroundColor(log.baby.color?.color ?? .primary)
                }
                if log.baby.birthday != nil {
                    AgeView(birthday: log.baby.birthday)
                }
            }
            Spacer()
            Button(action: {
                self.editBaby = true
            }) {
                Image(systemName: "arrowtriangle.right.circle.fill")
                    .font(.system(size: 24.0, weight: .heavy, design: .rounded))
            }
            .sheet(isPresented: $editBaby, content: {
                NewBabyForm(
                    onApply: { (babyToApply) in
                    self.log.baby = babyToApply
                    self.editBaby = false
                },
                    babyTextName: self.log.baby.nameComponents != nil ? self.log.baby.name : "",
                    babyEmojiName: self.log.baby.emoji,
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
        baby.emoji = "👶"
        var components = DateComponents()
        components.month = 3
        components.day = 14
        components.year = 2020
        components.calendar = .current
        if let date = components.date {
            baby.birthday = date
        }
        baby.color = PreferredColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        DocumentsView(logs: [babyLog])
    }
}

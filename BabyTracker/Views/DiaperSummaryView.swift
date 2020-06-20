//
//  DiaperSummaryView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Combine
import SwiftUI

enum DiaperAction {
    case create(_: DiaperSummaryView.FormContent)
    case remove(_: UUID)
    case showDetail(_: [DiaperEvent])
    case toggleUnit(_: DiaperEvent)
    case undo
    case redo
}

struct DiaperSummaryView: View {
    struct FormContent {
        var date: ObservableDate = .init()
        
        var id: UUID?
        var pee: Bool = false
        var poo: Bool = false
    }
    
    private enum DeleteState {
        case discard
        case delete
    }
    
    @State private var confirmDelete: Bool = false
    @State private var deleteState: DeleteState = .discard
    
    // MARK: - Variables
    @ObservedObject var log: BabyLog
    @State var date: ObservableDate
    
    @State var newEventTemplate: DiaperEvent = .new
    
    var onAction: ((DiaperAction) -> Void)?
    
    @State private var isLoading: Bool = true
    @State private var editing: Bool = false {
        didSet {
            if editing != oldValue, !editing {
                self.updateEvents()
            }
            if !editing {
                guard activeIndex < restoreContent.count else {
                    self.content = .init()
                    return
                }
                self.content = restoreContent[activeIndex]
                
            }
        }
    }
    @State private var items: [UUID: DiaperEvent] = [:]
    
    var filter: ((DiaperEvent) -> Bool)? = { diaper in
        return true
    }
    
    // MARK: Computed Properties
    
    var filteredEvents: [DiaperEvent] {
        guard let filter = self.filter else {
            return []
        }
        return items.values.filter(filter)
    }
    
    var sortedEvents: [DiaperEvent] {
        return filteredEvents.sorted(by: { $0.date < $1.date })
    }
    
    @State var content: FormContent = .init()
    var restoreContent: [FormContent] {
        return sortedEvents.reversed().map(({
            FormContent(
                date: .init($0.date),
                id: $0.id,
                pee: $0.pee,
                poo: $0.poop) }))
    }
    @State private var activeIndex: Int = 0
    
    var activeEvent: DiaperEvent {
//        return lastEvent ?? newEventTemplate
        guard sortedEvents.count > activeIndex else { return newEventTemplate }
        return sortedEvents[activeIndex]
    }
    
    func updateEvents() {
        self.log.groupOfType(completion: { (result: Result<[UUID: DiaperEvent], BabyError>) in
            if case let .success(groupDict) = result, groupDict != items {
                
                self.items = groupDict
                
                
                
                self.isLoading = false
            }
        })
    }
    
    var lastEvent: DiaperEvent? {
        return sortedEvents.last
    }
    
    // MARK: Views
    var body: some View {
        VStack {
            headerRow()
            
            actionRow()
        }
        .foregroundColor(.white)
        .padding()
        .background(DiaperEvent.type.colorValue)
        .cornerRadius(22)
        .padding(.horizontal)
        .onReceive(Just(log), perform: { (_) in
            self.updateEvents()
        })
        .onAppear {
            if let firstEvent = self.restoreContent.first {
                self.content = firstEvent
            }
            if self.isLoading {
                self.updateEvents()
            }
        }
    }
    
    func headerRow() -> some View {
        HStack {
            Color.white
                .frame(width: 18, height: 18)
                .mask(Image(BabyEventType.diaper.imageName).resizable())
                
            Text(BabyEventType.diaper.displayTitle)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
            
            Spacer()
            
            if restoreContent.count > 1 {
                Button(action: {
                    guard self.activeIndex < self.restoreContent.count - 1 else { return }
                    withAnimation {
                        let newOffset = self.activeIndex + 1
                        self.editing = false
                        self.activeIndex = newOffset
                        self.content = self.restoreContent[newOffset]
                    }
                }) {
                    Image(systemName: "arrow.left.circle")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
                .appearDisabledPlease(activeIndex >= restoreContent.count - 1)

                Button(action: {
                    guard self.activeIndex > 0 else { return }
                    withAnimation {
                        let newOffset = self.activeIndex - 1
                        self.editing = false
                        self.activeIndex = newOffset
                        self.content = self.restoreContent.sorted(by: { $0.date.date > $1.date.date })[newOffset]
                    }
                }) {
                    Image(systemName: "arrow.right.circle")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
                .appearDisabledPlease(activeIndex == 0)
            }
        }
    }
    
    // MARK: - Summary View
    func defaultSummaryView(_ events: [DiaperEvent], _ selected: DiaperEvent?) -> AnyView {
        guard events.count > 0 else {
            return Text("No Changes Today")
                .anyPlease()
        }
        let poops = events.filter({ $0.poop }).count
        let pees = events.filter({ $0.pee }).count
        
        return VStack(alignment: .leading) {
            Spacer()
            Text("\(events.count) \(events.count == 1 ? "Diaper Change" : "Diaper Changes")")
            Spacer()
            if events.count > 0 {
                Text("💩 \(poops)")
                Text("💦 \(pees)")
                Spacer()
            }
        }
        .anyPlease()
    }
    
    func actionRow() -> some View {
        HStack {
            if editing || !restoreContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    
                    TimeStepperView(targetDate: $content.date, editing: $editing)
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.content.pee.toggle()
                                self.editing = true
                            }
                        }) {
                            Text("💦")
                        }
                        .floatingPlease(content.pee ? BabyEventType.diaper.colorValue : .gray)

                        Button(action: {
                            withAnimation {
                                self.content.poo.toggle()
                                self.editing = true
                            }
                        }) {
                            Text("💩")
                        }
                        .floatingPlease(content.poo ? BabyEventType.diaper.colorValue : .gray)
                        
                        Spacer()
                    }
                    
                    if editing {
                        Spacer()
                        
                        HStack {
                            
                            Button(action: {
                                withAnimation {
                                    if self.editing {
                                        self.editing = false
                                    }
                                    self.confirmDelete = true
                                    self.deleteState = .delete
                                }
                            }) {
                                Text("Delete")
                                .bold()
                                .foregroundColor(BabyEventType.diaper.colorValue)
                            }
                            .appearDisabledPlease(restoreContent.isEmpty)
                            
                            Spacer()
                                                    
                            Button(action: {
                                withAnimation {
                                    guard self.content.id != nil else {
                                        if self.editing {
                                            self.editing = false
                                        }
                                        return
                                    }
                                    self.onAction?(.create(self.content))
                                    self.editing = false
                                }
                            }) {
                                Text("Update")
                                .bold()
                                .foregroundColor(BabyEventType.diaper.colorValue)
                            }
                            .appearDisabledPlease(restoreContent.isEmpty)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    var contentToCreate = self.content
                                    contentToCreate.id = nil
                                    self.onAction?(.create(contentToCreate))
                                    self.editing = false
                                    self.content = self.restoreContent.first ?? .init()
                                }
                            }) {
                                Text("Save")
                                .bold()
                                .foregroundColor(BabyEventType.diaper.colorValue)
                            }
                        }
                    }
                }
                .foregroundColor(BabyEventType.diaper.colorValue)
                Spacer()
            } else {
                Button(action: {
                    withAnimation {
                        self.editing = true
                    }
                }, label: {
                    Image(systemName: "plus")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                })
            }
        }
        .floatingPlease()
        .alert(isPresented: $confirmDelete) {
            Alert(
                title: Text("\(self.deleteState == .discard ? "Discard" : "Delete") \(self.content.id == nil || self.deleteState == .delete ? "Event" : "Changes")"),
                message: Text(self.deleteState == .delete ? "Are you sure you want to delete this event?" : "Continue without saving?"),
                primaryButton:
                .destructive(Text(self.deleteState == .delete ? "Delete" : "Discard"), action: {
                        withAnimation {
                            switch self.deleteState {
                            case .discard:
                                self.content = self.restoreContent [self.activeIndex]
                            case .delete:
                                if let id = self.content.id {
                                    self.onAction?(.remove(id))
                                }
                            }
                            self.editing = false
                        }}),
                secondaryButton:
                .cancel()
            )
        }
    }
}

// MARK: - Diaper Actions
extension DiaperSummaryView {
    func removeLast() {
        guard let id = content.id else { return }
        self.onAction?(.remove(id))
        self.editing = false
    }
}

struct DiaperSummaryView_Previews: PreviewProvider {
    static var babyLog: BabyLog {
        let log = BabyLog(fileURL: Bundle.main.url(forResource: "MyBabyLog", withExtension: "bblg")!)
        log.baby = baby
        let event = DiaperEvent(pee: false, poop: true)
        log.save(event, completion: { _ in })
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
        DiaperSummaryView(log: babyLog, date: .init())
    }
}

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
    case create(_: DiaperEvent, _: (_: Bool, _: Bool))
    case update(_: DiaperEvent, _: (_: Bool, _: Bool))
    case remove(_: DiaperEvent)
    case showDetail(_: [DiaperEvent])
    case toggleUnit(_: DiaperEvent)
    case undo
    case redo
}

struct DiaperSummaryView: View {
    // MARK: - Variables
    @ObservedObject var log: BabyLog
    @ObservedObject var date: ObservableDate
    
    @State var newEventTemplate: DiaperEvent = .new
    
    var onAction: ((DiaperAction) -> Void)?
    
    @State private var poopActive: Bool = false
    @State private var wetActive: Bool = false
    
    @State private var isLoading: Bool = true
    @State private var editing: Bool = false {
        didSet {
            if editing != oldValue, !editing {
                self.updateEvents()
            }
            if !editing {
                self.wetActive = activeEvent.pee
                self.poopActive = activeEvent.poop
                
            }
        }
    }
    @State private var items: [UUID: DiaperEvent] = [:]
    
    private var allowPresentList: Bool {
        return !items.isEmpty
    }
    
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
    
    var activeEvent: DiaperEvent {
        return lastEvent ?? newEventTemplate
    }
    
    func updateEvents() {
        self.log.groupOfType(completion: { (result: Result<[UUID: DiaperEvent], BabyError>) in
            if case let .success(groupDict) = result, groupDict != items {
                
                self.items = groupDict
                
                if let last = groupDict.values.filter(self.filter ?? { _ in return false }).sorted(by: { $0.date < $1.date }).last {
                    self.wetActive = last.pee
                    self.poopActive = last.poop
                } else {
                    self.wetActive = self.newEventTemplate.pee
                    self.poopActive = self.newEventTemplate.poop
                }
                self.isLoading = false
            }
        })
    }
    
    var lastEvent: DiaperEvent? {
        return sortedEvents.last
    }
    
    var stateIntValue: Int {
        var ret = 0
        if wetActive { ret += 1 }
        if poopActive { ret += 2 }
        return ret
    }
    
    // MARK: Views
    var body: some View {
        VStack {
            headerRow()
            
            contentRow()
            
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
            if self.isLoading {
                self.updateEvents()
            }
        }
    }
    
    func headerRow() -> some View {
        HStack {
            Text("🧷")
            
            Text("Diapers")
            
            Spacer()
            
            lastEventDateLabel()
            
            if allowPresentList {
                Image(systemName: "chevron.right.circle")
            }
        }
    }
    
    func lastEventDateLabel() -> AnyView {
        guard let lastEvent = lastEvent else {
            return EmptyView().anyPlease()
        }
        return Text(DateFormatter.shortTimeDisplay.string(from: lastEvent.date)).anyPlease()
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
    
    func contentRow() -> some View {
        HStack {
            defaultSummaryView(filteredEvents, activeEvent)
            
            Spacer()
            
            Button(action: {
                self.poopActive.toggle()
                self.editing = true
            }) {
                Text("💩")
                    .foregroundColor(.primary)
                    .padding()
                    .background(self.poopActive ? Color.gray : Color.white)
                    .cornerRadius(32)
            }
            
            Spacer()
            
            Button(action: {
                self.wetActive.toggle()
                self.editing = true
            }) {
                Text("💦")
                    .foregroundColor(.primary)
                    .padding()
                    .background(self.wetActive ? Color.gray : Color.white)
                    .cornerRadius(32)
            }
            Spacer()
        }
    }
    
    func actionRow() -> some View {
        HStack {
            if lastEvent != nil {
                Button(action: {
                    self.removeLast()
                }, label: {
                    Image(systemName: "trash")
                })
            }
            Spacer()
            Button(action: {
                self.onAction?(.create(self.newEventTemplate, (self.wetActive, self.poopActive)))
                self.editing = false
            }, label: {
                Image(systemName: "plus")
            })
            Spacer()
            if lastEvent != nil {
                Button(action: {
                    self.onAction?(.update(self.lastEvent ?? self.newEventTemplate, (self.wetActive, self.poopActive)))
                    self.editing = false
                }, label: {
                    Image(systemName: "pencil.and.outline")
                })
            }
        }
    }
}

// MARK: - Diaper Actions
extension DiaperSummaryView {
    func removeLast() {
        guard let lastEvent = lastEvent else { return }
        self.onAction?(.remove(lastEvent))
        self.editing = false
    }
}

struct DiaperSummaryView_Previews: PreviewProvider {
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
        DiaperSummaryView(log: babyLog, date: .init())
    }
}

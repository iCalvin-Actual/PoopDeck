//
//  MeasuredEventFormView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/18/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Combine
import SwiftUI

struct MeasuredEventFormView<E: MeasuredBabyEvent>: View {
    
    struct FormContent {
        var date: ObservableDate = .init()
        
        var id: UUID?
        var measurement: Measurement<Unit>?
    }
    
    private enum DeleteState {
        case discard
        case delete
    }
    
    @State private var confirmDelete: Bool = false
    @State private var deleteState: DeleteState = .discard
    
    @ObservedObject var log: BabyLog
    @State var date: ObservableDate
    
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
    @State private var items: [UUID: E] = [:]
    
    var filter: ((_ event: E) -> Bool)?
    var sort: ((_ lhs: E, _ rhs: E) -> Bool) = { $0.date < $1.date }
    var onAction: ((MeasuredEventFormAction<E>) -> Void)?
    
    var filteredEvents: [E] {
        guard let filter = self.filter else {
            return []
        }
        return items.values.filter(filter)
    }
    
    var sortedEvents: [E] {
        return filteredEvents.sorted(by: { $0.date < $1.date })
    }
    
    @State var content: FormContent = .init()
    var restoreContent: [FormContent] {
        return sortedEvents.reversed().map(({
            FormContent(
                date: .init($0.date),
                id: $0.id,
                measurement: $0.measurement) }))
    }
    @State private var activeIndex: Int = 0
    
    @State private var collectMeasurement: Bool = false
    
    var body: some View {
        VStack {
            headerRow()
            
            actionRow()
        }
        .foregroundColor(.white)
        .padding()
        .background(E.type.colorValue)
        .cornerRadius(22)
        .padding(.horizontal)
        .onReceive(Just(log), perform: { (_) in
            self.updateEvents()
        })
        .onAppear {
            if let firstEvent = self.restoreContent.first {
                self.content = firstEvent
            }
        }
    }
    
    func headerRow() -> some View {
        HStack {
            Color.white
                .frame(width: 18, height: 18)
                .mask(Image("Napping").resizable())
                
            Text("Naps")
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
                    .disablePlease(activeIndex >= restoreContent.count - 1)

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
                    .disablePlease(activeIndex == 0)
                }
        }
    }
    
    func actionRow() -> some View {
        HStack {
            if editing || !restoreContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    
                    TimeStepperView(targetDate: $content.date, editing: $editing)
                    
                    MeasurementStepperView(target: $content.measurement, defaultValue: E.self.defaultMeasurement, onValueChange: { (newMeasurement) in
                        print("Do anything?")
                    }, editing: $editing)
                    
                    if editing {
                            
                        Spacer()
                        
                        HStack {
                            
                            Button(action: {
                                guard !self.restoreContent.isEmpty else { return }
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
                                .foregroundColor(E.type.colorValue)
                            }
                            .disablePlease(restoreContent.isEmpty)
                            
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
                                .foregroundColor(E.type.colorValue)
                            }
                            .disablePlease(restoreContent.isEmpty)
                            
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
                                    .foregroundColor(E.type.colorValue)
                            }
                        }
                    }
                }
                .foregroundColor(E.type.colorValue)
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
        .raisedButtonPlease()
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

// MARK: - Functions
extension MeasuredEventFormView {
    func updateEvents() {
        self.log.groupOfType(completion: { (result: Result<[UUID: E], BabyError>) in
            if case let .success(groupDict) = result, groupDict != items {
                self.items = groupDict
                guard self.activeIndex < self.restoreContent.count else {
                    self.content = .init()
                    self.collectMeasurement = false
                    return
                }
                self.content = self.restoreContent[self.activeIndex]
                self.collectMeasurement = self.content.measurement != nil
            }
        })
    }
}

struct MeasuredEventFormView_Previews: PreviewProvider {
    static var babyLog: BabyLog {
        let log = BabyLog(fileURL: Bundle.main.url(forResource: "MyBabyLog", withExtension: "bblg")!)
        log.baby = baby
        let napEvent = NapEvent(measurement: NapEvent.defaultMeasurement)
        log.save(napEvent) { (result: Result<NapEvent, BabyError>) in
            print("Saved")
        }
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
        MeasuredEventFormView<NapEvent>(log: babyLog, date: .init())
    }
}

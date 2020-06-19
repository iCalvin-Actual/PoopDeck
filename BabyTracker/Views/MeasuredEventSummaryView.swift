//
//  MeasuredEventSummaryView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/12/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - Measured Event Summary
struct MeasuredEventSummaryView<E: MeasuredBabyEvent>: View {
    @ObservedObject var log: BabyLog
    @ObservedObject var date: ObservableDate
    
    @State var increment: Int? = nil
    
    var emojiLabel: String?
    var summaryTitle: String?
    
    var singularValue: String = "event"
    var pluralValue: String = "events"
    
    var allowPresentList: Bool = true
    
    @State var newEventTemplate: E?
    var filter: ((_ event: E) -> Bool)?
    var sort: ((_ lhs: E, _ rhs: E) -> Bool) = { $0.date < $1.date }
    var onAction: ((MeasuredEventAction<E>) -> Void)?
    
    var buildSummaryContent: ((_ events: [E], _ selected: E?) -> AnyView)?
    
    var measurementTextConstructor: ((_: E, _: Int?) -> String?)
    
    @State var showAverage: Bool = false
    
    @State var isLoading: Bool = true
    @State var items: [UUID: E] = [:]
    
    @State var editing: Bool = false {
        didSet {
            if editing {
                increment = 0
            } else {
                increment = nil
            }
        }
    }
    
    // MARK: - Computed Properties
    var filteredEvents: [E] {
        guard let filter = self.filter else {
            return []
        }
        return items.values.filter(filter)
    }
    
    var sortedEvents: [E] {
        return filteredEvents.sorted(by: { $0.date < $1.date })
    }
    
    var activeEvent: E {
        return lastEvent ?? newEventTemplate ?? .new
    }
    
    var lastEvent: E? {
        return sortedEvents.last
    }
    
    var summaryViewBuilder: ((_ events: [E], _ selected: E?) -> AnyView) {
        if let buildSummaryContent = buildSummaryContent {
            return buildSummaryContent
        }
        return defaultSummaryView
    }
    
    // MARK: - Views
    var body: some View {
        VStack {
            headerRow()
            
            contentRow()
            
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
            if self.isLoading {
                self.updateEvents()
            }
        }
    }
    
    // MARK: - Header Row
    func headerRow() -> some View {
        HStack {
            if !(emojiLabel?.isEmpty ?? true) {
                Text(emojiLabel ?? "")
            }
            if !(summaryTitle?.isEmpty ?? true) {
                Text(summaryTitle ?? "")
            }
            
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
    
    // MARK: - Content Row
    func contentRow() -> some View {
        HStack {
            summaryViewBuilder(filteredEvents, activeEvent)
            
            self.measurementModifierIfNeeded()
        }
    }
    
    func defaultSummaryView(_ events: [E], _ selected: E?) -> AnyView {
        guard events.count > 0 else {
            return Text("No \(pluralValue) Today")
                .anyPlease()
        }
        var isAmbiguous: Bool = false
        var count: Int = 0
        let calculations = events.reduce((total: 0.0, avg: 0.0)) { (tuple: (total: Double, avg: Double), event) -> (Double, Double) in
            var ret = (total: 0.0, avg: 0.0)
            
            if let newValue = event.measurement?.value, newValue > 0 {
                let newTotal = tuple.total + newValue
                ret.total = tuple.total + newValue
                count += 1
                ret.avg = newTotal / Double(count)
                
            } else {
                isAmbiguous = true
                ret.total = tuple.total
                ret.avg = tuple.avg
            }
            return ret
        }
        
        let totalVisible: Bool = !self.showAverage && calculations.0 != 0 && events.count > 1
        let averageVisible: Bool = self.showAverage && calculations.1 != 0 && events.count > 1
        
        
        let totalMeasurementText = MeasurementFormatter.defaultFormatter.string(from: Measurement(value: calculations.0, unit: UnitVolume.fluidOunces))
        let averageMeasurementText = MeasurementFormatter.defaultFormatter.string(from: Measurement(value: calculations.1, unit: UnitVolume.fluidOunces))
        
        let averageText: String = "Avg.: \(isAmbiguous ? "~" : "")\(averageMeasurementText)"
        let totalText: String = "Total: \(isAmbiguous ? ">" : "")\(totalMeasurementText)"
        
        return VStack(alignment: .leading) {
            Spacer()
            Text("\(sortedEvents.count) \(sortedEvents.count == 1 ? singularValue : pluralValue)")
            Spacer()
            if totalVisible || averageVisible {
                Button(action: {
                    self.showAverage.toggle()
                }) {
                    if totalVisible {
                        Text(totalText)
                    }
                    if averageVisible {
                        Text(averageText)
                    }
                }
                Spacer()
            }
        }
        .anyPlease()
    }
    
    func measurementModifierIfNeeded() -> AnyView {
        if let measurementString = self.measurementTextConstructor(activeEvent, increment) {
            return HStack {
                Spacer()
                if editing {
                    Button(action: {
                        if self.increment == nil {
                            self.increment = 0
                        } else {
                            self.increment! -= 1
                        }
                    }) {
                        Image(systemName: "arrowtriangle.left.circle.fill")
                    }
                }
                
                Text(measurementString)
                .padding()
                .onTapGesture {
                    self.editing.toggle()
                }
                
                if editing {
                    Button(action: {
                        if self.increment == nil {
                            self.increment = 0
                        } else {
                            self.increment! += 1
                        }
                    }) {
                        Image(systemName: "arrowtriangle.right.circle.fill")
                    }
                }
            }
            .anyPlease()
        }
        return EmptyView().anyPlease()
    }
    
    // MARK: - Content Row
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
                self.onAction?(.create(self.newEventTemplate ?? E.new, self.increment))
                self.editing = false
            }, label: {
                Image(systemName: "plus")
            })
            
            Spacer()
            
            if lastEvent != nil {
                Button(action: {
                    self.onAction?(.update(self.lastEvent ?? self.newEventTemplate ?? E.new, self.increment))
                    self.editing = false
                }, label: {
                    Image(systemName: "pencil.and.outline")
                })
            }
        }
    }
}

// MARK: - Functions
extension MeasuredEventSummaryView {
    func updateEvents() {
        self.log.groupOfType(completion: { (result: Result<[UUID: E], BabyError>) in
            if case let .success(groupDict) = result, groupDict != items {
                self.items = groupDict
                self.newEventTemplate?.measurement = self.lastEvent?.measurement
                self.isLoading = false
            }
        })
    }
    
    func removeLast() {
        guard let lastEvent = lastEvent else { return }
        self.onAction?(.remove(lastEvent))
    }
}

// MARK: Previews
struct MeasuredEventSummaryView_Previews: PreviewProvider {
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
        MeasuredEventSummaryView(
            log: babyLog,
            date: .init(),
            emojiLabel: "💤",
            summaryTitle: "Naps",
            singularValue: "Nap",
            pluralValue: "Naps",
            allowPresentList: true,
            newEventTemplate: { () -> NapEvent in
                var new = NapEvent()
                new.measurement = Measurement(value: 1, unit: UnitDuration.hours)
                return new
            }(),
            filter: { (event: NapEvent) -> Bool in
                return true
            },
            sort: { $0.date < $1.date },
            onAction: nil,
            measurementTextConstructor: { (event, increment) in
                let unit = event.measurement?.unit ?? UnitDuration.supported.first ?? UnitDuration.minutes
                guard let modifier = unit.modifier else {
                    return "0"
                }
                let value: Double = event.measurement?.value ?? (increment != nil ? unit.defaultValue : nil) ?? 0
                let newValue = value + (Double(increment ?? 0) * modifier)
                let size = Measurement(value: newValue, unit: unit)
                
                return MeasurementFormatter.defaultFormatter.string(from: size)
                    
            })
    }
}

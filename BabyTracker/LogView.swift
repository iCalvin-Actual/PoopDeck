//
//  LogView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

struct LogView: View {
    @Environment(\.editMode) var editMode
    
    @ObservedObject var log: BabyLog
    
    @State private var resolvingConflict: Bool = false
    @State private var allowChanges: Bool = true
    @State private var editBaby: Bool = false
    
    
    @State var targetDate: ObservableDate = .init()
    var startOfTargetDate: Date {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: targetDate.date)
        
        let components = DateComponents(calendar: .current, day: calendar.component(.hour, from: targetDate.date) < 5 ? -1 : 0, hour: 5)
        return calendar.date(byAdding: components, to: dateStart) ?? dateStart
    }
    
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    
    var onAction: ((DocumentAction) -> Void)?
    
    var body: some View {
        VStack(spacing: 2) {
            BabyInfoView(log: log, editBaby: $editBaby)

            DateStepperView(targetDate: $targetDate)
            
            ScrollView(.vertical) {
                MeasuredEventSummaryView(
                    log: log,
                    date: targetDate,
                    emojiLabel: "🍼",
                    summaryTitle: "Bottle Feedings",
                    singularValue: "Bottle",
                    pluralValue: "Bottles",
                    allowPresentList: true,
                    newEventTemplate: FeedEvent(source: .bottle),
                    filter: { (event: FeedEvent) -> Bool in
                        guard
                            case .bottle = event.source,
                            self.startOfTargetDate <= event.date,
                            event.date <= self.targetDate.date
                            else { return false }
                        return true
                    },
                    sort: { $0.date < $1.date },
                    onAction: onEventAction,
                    measurementTextConstructor: { (event, increment) in
                        let unit = event.measurement?.unit ?? UnitVolume.supported.first ?? UnitVolume.fluidOunces
                        guard let modifier = unit.modifier else {
                            return "0"
                        }
                        let value: Double = event.measurement?.value ?? (increment != nil ? unit.defaultValue : nil) ?? 0
                        let newValue = value + (Double(increment ?? 0) * modifier)
                        let size = Measurement(value: newValue, unit: unit)
                        
                        return MeasurementFormatter.defaultFormatter.string(from: size)
                        
                })
                
                MeasuredEventSummaryView(
                    log: log,
                    date: targetDate,
                    emojiLabel: "🤱🏻",
                    summaryTitle: "Breast Feedings",
                    singularValue: "Feeding",
                    pluralValue: "Feedings",
                    allowPresentList: true,
                    newEventTemplate: FeedEvent(source: .breast(.both)),
                    filter: { (event: FeedEvent) -> Bool in
                        guard
                            case .breast = event.source,
                            self.startOfTargetDate <= event.date,
                            event.date <= self.targetDate.date
                            else { return false }
                        return true
                    },
                    sort: { $0.date < $1.date },
                    onAction: onEventAction,
                    measurementTextConstructor: { (event, increment) in
                        let unit = event.measurement?.unit ?? UnitVolume.supported.first ?? UnitVolume.fluidOunces
                        guard let modifier = unit.modifier else {
                            return "0"
                        }
                        let value: Double = event.measurement?.value ?? (increment != nil ? unit.defaultValue : nil) ?? 0
                        let newValue = value + (Double(increment ?? 0) * modifier)
                        let size = Measurement(value: newValue, unit: unit)
                        
                        return MeasurementFormatter.defaultFormatter.string(from: size)
                        
                    })
                
                DiaperSummaryView(
                    log: log,
                    date: targetDate,
                    newEventTemplate: .new,
                    onAction: self.onEventAction) { (event) -> Bool in
                        guard
                            self.startOfTargetDate <= event.date,
                            event.date <= self.targetDate.date
                            else { return false }
                        return true
                    }
                    
                MeasuredEventSummaryView(
                    log: log,
                    date: targetDate,
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
                        guard
                            self.startOfTargetDate <= event.date,
                            event.date <= self.targetDate.date
                            else { return false }
                        return true
                    },
                    sort: { $0.date < $1.date },
                    onAction: onEventAction,
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
                            
                    MeasuredEventSummaryView(
                        log: log,
                        date: targetDate,
                        emojiLabel: "🚼",
                        summaryTitle: "Tummy Time",
                        singularValue: "Tummy Time",
                        pluralValue: "Tummy Times",
                        allowPresentList: true,
                        newEventTemplate: { () -> TummyTimeEvent in
                            var new = TummyTimeEvent()
                            new.measurement = Measurement(value: 5, unit: UnitDuration.minutes)
                            return new
                        }(),
                        filter: { (event: TummyTimeEvent) -> Bool in
                            guard
                                self.startOfTargetDate <= event.date,
                                event.date <= self.targetDate.date
                                else { return false }
                            return true
                        },
                        sort: { $0.date < $1.date },
                        onAction: onEventAction,
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
                                
                    MeasuredEventSummaryView<WeightEvent>(
                        log: log,
                        date: targetDate,
                        emojiLabel: "⚖️",
                        summaryTitle: "Weight Check",
                        singularValue: "Weight Check",
                        pluralValue: "Weight Check",
                        allowPresentList: true,
                        newEventTemplate: { () -> WeightEvent in
                            return WeightEvent(measurement: Measurement(value: 10, unit: UnitMass.pounds))
                        }(),
                        filter: { (event: WeightEvent) -> Bool in
                            guard
                                self.startOfTargetDate <= event.date,
                                event.date <= self.targetDate.date
                                else { return false }
                            return true
                        },
                        sort: { $0.date < $1.date },
                        onAction: onEventAction,
                        measurementTextConstructor: { (event, increment) in
                            let unit = event.measurement?.unit ?? UnitMass.supported.first ?? UnitMass.pounds
                            guard let modifier = unit.modifier else {
                                return "0"
                            }
                            let value: Double = event.measurement?.value ?? (increment != nil ? unit.defaultValue : nil) ?? 0
                            let newValue = value + (Double(increment ?? 0) * modifier)
                            let size = Measurement(value: newValue, unit: unit)
                            
                            return MeasurementFormatter.defaultFormatter.string(from: size)
                        })
                                
                    MeasuredEventSummaryView(
                        log: log,
                        date: targetDate,
                        emojiLabel: "😾",
                        summaryTitle: "Fussies",
                        singularValue: "Fussy",
                        pluralValue: "Fussies",
                        allowPresentList: true,
                        newEventTemplate: { () -> FussEvent in
                            var new = FussEvent()
                            new.measurement = Measurement(value: 5, unit: UnitDuration.minutes)
                            return new
                        }(),
                        filter: { (event: FussEvent) -> Bool in
                            guard
                                self.startOfTargetDate <= event.date,
                                event.date <= self.targetDate.date
                                else { return false }
                            return true
                        },
                        sort: { $0.date < $1.date },
                        onAction: onEventAction,
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
                
                ForEach(log.eventStore.customEvents.values.filter({ startOfTargetDate <= $0.date && $0.date <= targetDate.date }).reduce([:], { (inputValue, event) -> [String: CustomEvent] in
                    var input = inputValue
                    
                    let inputEvent = inputValue[event.event]
                    
                    if inputEvent == nil || (inputEvent != nil && inputEvent?.date ?? Date() < event.date ) {
                        input[event.event] = event
                    }
                    return input
                }).values.sorted(by: { $0.date < $1.date }) as? [CustomEvent] ?? [], id: \.id) { event in
                    CustomEventView(
                        date:  self.targetDate,
                        existingEvent: event,
                        title: event.event,
                        info: "",
                        onAction: self.onEventAction)
                }
                
                CustomEventView(
                    date: targetDate,
                    onAction: self.onEventAction)
            }
        }
        .padding(.vertical)
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
    
    func onEventAction(_ action: MeasuredEventAction<FeedEvent>) {
        switch action {
        case .create(var event, let increment), .update(var event, let increment):
            if case .create = action {
                event.id = UUID()
            }
            event.date = self.targetDate.date
            let unit = event.measurement?.unit ?? UnitVolume.milliliters
            if let modifier = unit.modifier {
                let value = event.measurement?.value ?? unit.defaultValue ?? 0
                let adjustment = modifier * Double(increment ?? 0)
                event.measurement = Measurement(value: value + adjustment, unit: unit)
                print("Updated")
            }
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard let size = event.measurement else { return }
            let values = UnitVolume.supported
            let index = values.lastIndex(of: size.unit) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = size.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("Did Save")
            }
        case .showDetail(let events):
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventAction<NapEvent>) {
        switch action {
        case .create(var event, let increment), .update(var event, let increment):
            if case .create = action {
                event.id = UUID()
            }
            event.date = self.targetDate.date
            let unit = event.measurement?.unit ?? UnitDuration.minutes
            if let modifier = unit.modifier {
                let value = event.measurement?.value ?? unit.defaultValue ?? 0
                let adjustment = modifier * Double(increment ?? 0)
                event.measurement = Measurement(value: value + adjustment, unit: unit)
                print("Updated")
            }
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard var measurement = event.measurement else { return }
            let values = UnitDuration.supported
            let index = values.lastIndex(of: measurement.unit as! UnitDuration) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = measurement.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("Did Save")
            }
        case .showDetail(let events):
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventAction<TummyTimeEvent>) {
        switch action {
        case .create(var event, let increment), .update(var event, let increment):
            if case .create = action {
                event.id = UUID()
            }
            event.date = self.targetDate.date
            let unit = event.measurement?.unit ?? UnitDuration.minutes
            if let modifier = unit.modifier {
                let value = event.measurement?.value ?? 5
                let adjustment = modifier * Double(increment ?? 0)
                event.measurement = Measurement(value: value + adjustment, unit: unit)
            }
            self.log.save(event) { (savedEvent) in
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
            }
        case .toggleUnit(var event):
            print("Toggle")
        case .showDetail(let events):
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventAction<FussEvent>) {
        switch action {
        case .create(var event, let increment), .update(var event, let increment):
            if case .create = action {
                event.id = UUID()
            }
            event.date = self.targetDate.date
            let unit = event.measurement?.unit ?? UnitDuration.minutes
            if let modifier = unit.modifier {
                let value = event.measurement?.value ?? unit.defaultValue ?? 0
                let adjustment = modifier * Double(increment ?? 0)
                event.measurement = Measurement(value: value + adjustment, unit: unit)
                print("Updated")
            }
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard var measurement = event.measurement else { return }
            let values = UnitDuration.supported
            let index = values.lastIndex(of: measurement.unit as! UnitDuration) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = measurement.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("Did Save")
            }
        case .showDetail(let events):
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventAction<WeightEvent>) {
        switch action {
        case .create(var event, let increment), .update(var event, let increment):
            if case .create = action {
                event.id = UUID()
            }
            event.date = self.targetDate.date
            let unit = event.measurement?.unit ?? UnitMass.pounds
            if let modifier = unit.modifier {
                let value = event.measurement?.value ?? unit.defaultValue ?? 0
                let adjustment = modifier * Double(increment ?? 0)
                event.measurement = Measurement(value: value + adjustment, unit: unit)
                print("Updated")
            }
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard var measurement = event.measurement else { return }
            let values = UnitMass.supported
            let index = values.lastIndex(of: measurement.unit) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = measurement.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("Did Save")
            }
        case .showDetail(let events):
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: DiaperAction) {
        switch action {
        case .create(var event, let diaperContents), .update(var event, let diaperContents):
            if case .create = action {
                event.id = UUID()
            }
            event.pee = diaperContents.0
            event.poop = diaperContents.1
            event.date = self.targetDate.date
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit:
            print("Do nothing")
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: CustomAction) {
        switch action {
        case .create(var event, let titlePair), .update(var event, let titlePair):
            if case .create = action {
                event.id = UUID()
            }
            event.event = titlePair.0
            
            event.date = self.targetDate.date
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit:
            print("Do nothing")
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
}

struct DateStepperView: View {
    @Binding var targetDate: ObservableDate
    
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
        self.targetDate = .init(self.calendar.date(byAdding: self.components, to: self.currentDate) ?? Date())
    }
    
    let ticker: TickPublisher = .init()
    
    var calendar: Calendar { return .current }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            /// Time Display
            HStack {
                Text(DateFormatter.shortDisplay.string(from: targetDate.date))
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
                    Text(DateFormatter.shortDateDisplay.string(from: targetDate.date))
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
                        
                        Text(DateFormatter.hourFormatter.string(from: self.targetDate.date))
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
                        
                        Text(DateFormatter.minuteFormatter.string(from: targetDate.date))
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
                        
                        Text(DateFormatter.ampmFormatter.string(from: targetDate.date))
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
        .padding(.horizontal)
        .padding(.horizontal)
        .padding(.bottom)
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

enum MeasuredEventAction<E: MeasuredBabyEvent> {
    case create(_: E, _: Int?)
    case update(_: E, _: Int?)
    case remove(_: E)
    case showDetail(_: [E])
    case toggleUnit(_: E)
    case undo
    case redo
}

enum DiaperAction {
    case create(_: DiaperEvent, _: (_: Bool, _: Bool))
    case update(_: DiaperEvent, _: (_: Bool, _: Bool))
    case remove(_: DiaperEvent)
    case showDetail(_: [DiaperEvent])
    case toggleUnit(_: DiaperEvent)
    case undo
    case redo
}

enum CustomAction {
    case create(_: CustomEvent, _: (_: String, _: String))
    case update(_: CustomEvent, _: (_: String, _: String))
    case remove(_: CustomEvent)
    case showDetail(_: [CustomEvent])
    case toggleUnit(_: CustomEvent)
    case undo
    case redo
}

enum MeasurementStyle {
    case none
    case volume
    case mass
    case duration
    
    var unit: Unit? {
        switch self {
        case .none:
            return nil
        case .volume:
            return UnitVolume.milliliters
        case .mass:
            return UnitMass.kilograms
        case .duration:
            return UnitDuration.minutes
        }
    }
}

struct NewEventModel {
    var incrementModifier: Int
}

struct CustomEventView: View {
    
    @ObservedObject var date: ObservableDate = .init()
    
    @State var allowPresentList: Bool = true
    
    @State var existingEvent: CustomEvent?
    
    @State var title: String = ""
    @State var info: String = ""
    @State var editing: Bool = false
    
    var onAction: ((CustomAction) -> Void)?
    

    var body: some View {
        VStack {
            HStack {
                Text("👨‍👩‍👧")
                Text("Custom Event")
                .font(.system(size: 24.0, weight: Font.Weight.heavy, design: .rounded))
                Spacer()
                Text(DateFormatter.shortDisplay.string(from: existingEvent?.date ?? date.date))
                if allowPresentList {
                    Image(systemName: "chevron.right.circle")
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Create Custom Event")
                    TextField("Event", text: $title, onEditingChanged: { (editing) in
                        self.editing = true
                    }) {
                        print("Return Tapped")
                    }
                    TextField("Info", text: self.$info)
                }
                Spacer()
            }
            .font(.system(size: 16.0, weight: Font.Weight.bold, design: .rounded))
            
            
            
            HStack {
                if existingEvent != nil {
                    Button(action: {
                        guard let event = self.existingEvent else { return }
                        self.onAction?(.remove(event))
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
                Spacer()
                Button(action: {
                    self.onAction?(.create(self.existingEvent ?? .new, (self.title, self.info)))
                    self.editing = false
                    self.title = self.existingEvent?.event ?? ""
                    self.info = ""
                }, label: {
                    Image(systemName: "plus")
                })
                Spacer()
                if existingEvent != nil {
                    Button(action: {
                        self.onAction?(.update(self.existingEvent ?? .new, (self.title, self.info)))
                        self.editing = false
                        self.title = self.existingEvent?.event ?? ""
                        self.info = ""
                    }, label: {
                        Image(systemName: "pencil.and.outline")
                    })
                }
            }
            .font(.system(size: 20.0, weight: Font.Weight.heavy, design: .rounded))
        }
        .foregroundColor(.white)
        .padding()
        .background(CustomEvent.type.colorValue)
        .cornerRadius(22)
        .padding(.horizontal)
    }
}

struct DiaperSummaryView: View {
    @ObservedObject var log: BabyLog
    @ObservedObject var date: ObservableDate
    
    @State var poopActive: Bool = false
    @State var wetActive: Bool = false
    
    var allowPresentList: Bool {
        return !items.isEmpty
    }
    
    @State var newEventTemplate: DiaperEvent = .new
    
    var onAction: ((DiaperAction) -> Void)?
    
    @State var isLoading: Bool = true
    @State var editing: Bool = false {
        didSet {
            if editing != oldValue, !editing {
                self.updateEvents()
            }
            if !editing {
                self.wetActive = activeEvent().pee
                self.poopActive = activeEvent().poop
                
            }
        }
    }
    @State var items: [UUID: DiaperEvent] = [:]
    
    var filter: ((DiaperEvent) -> Bool)? = { diaper in
        return true
    }
    
    var filteredEvents: [DiaperEvent] {
        guard let filter = self.filter else {
            return []
        }
        return items.values.filter(filter)
    }
    
    var sortedEvents: [DiaperEvent] {
        return filteredEvents.sorted(by: { $0.date < $1.date })
    }
    
    func activeEvent() -> DiaperEvent {
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
    
    var lastEventDateLabel: AnyView {
        guard let lastEvent = lastEvent else {
            return EmptyView().anyPlease()
        }
        return Text(DateFormatter.shortTimeDisplay.string(from: lastEvent.date)).anyPlease()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("🧷")
                    .font(.headline)
                Text("Diapers")
                    .font(.system(size: 24.0, weight: Font.Weight.heavy, design: .rounded))
                Spacer()
                lastEventDateLabel
                if allowPresentList {
                    Image(systemName: "chevron.right.circle")
                }
            }
            
            HStack {
                defaultSummaryView(filteredEvents, activeEvent())
                
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
            .font(.system(size: 16.0, weight: Font.Weight.bold, design: .rounded))
            
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
            .font(.system(size: 20.0, weight: Font.Weight.heavy, design: .rounded))
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
    
    var stateIntValue: Int {
        var ret = 0
        if wetActive { ret += 1 }
        if poopActive { ret += 2 }
        return ret
    }
    
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
    
    func removeLast() {
        guard let lastEvent = lastEvent else { return }
        self.onAction?(.remove(lastEvent))
        self.editing = false
    }
}

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
        
//    var measurementText: String? {
//        let event = activeEvent()
//        let unit = event.measurement?.unit ?? UnitVolume.supported.first ?? UnitVolume.fluidOunces
//        guard let modifier = unit.modifier else {
//            return "0"
//        }
//        let value: Double = event.measurement?.value ?? (increment != nil ? unit.defaultValue : nil) ?? 0
//        let newValue = value + (Double(increment ?? 0) * modifier)
//        let size = Measurement(value: newValue, unit: unit)
//
//        return MeasurementFormatter.defaultFormatter.string(from: size)
//    }
    
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
    
    var filteredEvents: [E] {
        guard let filter = self.filter else {
            return []
        }
        return items.values.filter(filter)
    }
    
    var sortedEvents: [E] {
        return filteredEvents.sorted(by: { $0.date < $1.date })
    }
    
    func activeEvent() -> E {
        return lastEvent ?? newEventTemplate ?? .new
    }
    
    func updateEvents() {
        self.log.groupOfType(completion: { (result: Result<[UUID: E], BabyError>) in
            if case let .success(groupDict) = result, groupDict != items {
                self.items = groupDict
                self.newEventTemplate?.measurement = self.lastEvent?.measurement
                self.isLoading = false
            }
        })
    }
    
    var lastEvent: E? {
        return sortedEvents.last
    }
    
    var lastEventDateLabel: AnyView {
        guard let lastEvent = lastEvent else {
            return EmptyView().anyPlease()
        }
        return Text(DateFormatter.shortTimeDisplay.string(from: lastEvent.date)).anyPlease()
    }
    
    var summaryViewBuilder: ((_ events: [E], _ selected: E?) -> AnyView) {
        if let buildSummaryContent = buildSummaryContent {
            return buildSummaryContent
        }
        return defaultSummaryView
    }
    
    var body: some View {
        VStack {
            HStack {
                if !(emojiLabel?.isEmpty ?? true) {
                    Text(emojiLabel ?? "")
                        .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                    .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                }
                if !(summaryTitle?.isEmpty ?? true) {
                    Text(summaryTitle ?? "")
                    .font(.system(size: 24.0, weight: Font.Weight.heavy, design: .rounded))
                }
                Spacer()
                lastEventDateLabel
                if allowPresentList {
                    Image(systemName: "chevron.right.circle")
                }
            }
            
            HStack {
                summaryViewBuilder(filteredEvents, activeEvent())
                    .font(.system(size: 16.0, weight: Font.Weight.bold, design: .rounded))
                
                self.measurementModifierIfNeeded()
                .font(.system(size: 16.0, weight: Font.Weight.bold, design: .rounded))
            }
            
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
            .font(.system(size: 20.0, weight: Font.Weight.heavy, design: .rounded))
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
        if let measurementString = self.measurementTextConstructor(activeEvent(), increment) {
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
                            .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                    }
                }
                
                Text(measurementString)
                .padding()
                .onTapGesture {
//                    self.onAction?(.toggleUnit(self.activeEvent()))
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
                            .font(.system(size: 24.0, weight: .heavy, design: .rounded))
                    }
                }
            }
//            .onTapGesture {
//                self.editing.toggle()
//            }
            .anyPlease()
        }
        return EmptyView().anyPlease()
    }
    
    func removeLast() {
        guard let lastEvent = lastEvent else { return }
        self.onAction?(.remove(lastEvent))
    }
}

struct BabyInfoView: View {
    @ObservedObject var log: BabyLog
    @Binding var editBaby: Bool
    
    var emojiLabel: AnyView {
        guard !log.baby.emoji.isEmpty else { return EmptyView().anyPlease() }
        return Text(log.baby.emoji)
            .font(.headline)
            .anyPlease()
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
                        .foregroundColor(log.baby.themeColor?.color ?? .primary)
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
                    useEmojiName: self.log.baby.nameComponents == nil,
                    color: self.log.baby.themeColor ?? .random,
                    birthday: self.log.baby.birthday ?? Date(),
                    saveBirthday: self.log.baby.birthday != nil)
            })
        }
        .padding()
        .cornerRadius(22)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct LogView_Previews: PreviewProvider {
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
        LogView(log: babyLog)
    }
}

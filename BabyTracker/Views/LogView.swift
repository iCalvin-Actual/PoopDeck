//
//  LogView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - LogView
struct LogView: View {
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
    
    // MARK: - Views
    
    var body: some View {
        VStack(spacing: 2) {
            BabyInfoView(log: log)

            DateStepperView(targetDate: $targetDate)
            
            ScrollView(.vertical) {
                bottleSummaryView()
                
                breastFeedSummaryView()
                
                diaperSummaryView()
                
                napSummaryView()
                
                tummyTimeSummaryView()
                
                fussySummaryView()
                
                customEventsViews()
                
                newCustomEventView()
            }
        }
        .padding(.vertical)
        .onReceive(NotificationCenter.default.publisher(for: UIDocument.stateChangedNotification, object: log), perform: self.handleStateChange)
    }
    
    // MARK: Bottle Feedings
    func bottleSummaryView() -> some View {
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
    }
    
    // MARK: Breast Feedings
    func breastFeedSummaryView() -> some View {
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
    }
    
    // MARK: Diapers
    func diaperSummaryView() -> some View {
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
    }
    
    // MARK: Naps
    func napSummaryView() -> some View {
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
    }
    
    // MARK: Tummy Times
    func tummyTimeSummaryView() -> some View {
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
    }
    
    // MARK: Weight Checks
    func weightSummaryView() -> some View {
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
    }
    
    // MARK: Fussies
    func fussySummaryView() -> some View {
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
    }
    
    // MARK: Custom
    func customEventsViews() -> some View {
        ForEach(log.eventStore.customEvents.values.filter({ startOfTargetDate <= $0.date && $0.date <= targetDate.date }).reduce([:], { (inputValue, event) -> [String: CustomEvent] in
            var input = inputValue
            
            let inputEvent = inputValue[event.event]
            
            if inputEvent == nil || (inputEvent != nil && inputEvent?.date ?? Date() < event.date ) {
                input[event.event] = event
            }
            return input
        }).values.sorted(by: { $0.date < $1.date }), id: \.id) { event in
            CustomEventView(
                date:  self.targetDate,
                existingEvent: event,
                title: event.event,
                info: "",
                onAction: self.onEventAction)
        }
    }
    
    func newCustomEventView() -> some View {
        CustomEventView(
            date: targetDate,
            onAction: self.onEventAction)
    }
}

// MARK: - Document State Changes
extension LogView {
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
            guard let progress = log.progress else {
                // No progress to handle
                return
            }
            let percentage = progress.completedUnitCount / progress.totalUnitCount
            print("Show Progress: \(percentage)")
        case .normal:
            self.allowChanges = true
            print("Normal?")
        default:
            print("Unknown Value? \(log.documentState)")
        }
    }
}

// MARK: - Event Actions
enum MeasuredEventAction<E: MeasuredBabyEvent> {
    case create(_: E, _: Int?)
    case update(_: E, _: Int?)
    case remove(_: E)
    case showDetail(_: [E])
    case toggleUnit(_: E)
    case undo
    case redo
}

extension LogView {
    // MARK: Feed Events
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
            self.log.save(event) { (_) in
                print("💾: Event added to log")
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
            self.log.save(event) { (_) in
                print("💾: Event added to log")
            }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    // MARK: Nap Events
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
            self.log.save(event) { (_) in
                print("💾: Event added to log")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard let measurement = event.measurement else { return }
            let values = UnitDuration.supported
            let index = values.lastIndex(of: measurement.unit) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = measurement.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("💾: Event added to log")
            }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    // MARK: Tummy Time Events
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
                print("💾: Event added to log")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("💾: Event removed from log")
            }
        case .toggleUnit:
            print("Toggle Unit")
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    // MARK: Fuss Events
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
                print("💾: Event added to log")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard let measurement = event.measurement else { return }
            let values = UnitDuration.supported
            let index = values.lastIndex(of: measurement.unit) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = measurement.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("💾: Event added to log")
            }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    // MARK: Weight Events
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
                print("💾: Event added to log")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(var event):
            guard let measurement = event.measurement else { return }
            let values = UnitMass.supported
            let index = values.lastIndex(of: measurement.unit) ?? values.endIndex
            let newIndex = (index + 1) % values.count
            let newUnit = values[newIndex]
            event.measurement = measurement.converted(to: newUnit)
            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
            self.log.save(event) { (saveEvent) in
                print("💾: Event added to log")
            }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    // MARK: Diaper Events
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
    
    // MARK: Custom Events
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

// MARK: Previews
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

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
    
    @ObservedObject var keyboardResponder: KeyboardResponder = .init()
    
    @State private var resolvingConflict: Bool = false
    @State private var allowChanges: Bool = true
    @State private var editBaby: Bool = false
    
    @State var targetDate: ObservableDate = .init()
    var startOfTargetDate: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: targetDate.date)
    }
    var endOfTargetDate: Date {
        let start = startOfTargetDate
        
        let components = DateComponents(calendar: .current, day:1)
        return Date.apply(components, to: start)
    }
    
    var onAction: ((DocumentAction) -> Void)?
    
    // MARK: - Views
    
    var body: some View {
        VStack(spacing: 2) {
            BabyInfoView(
                log: self.log,
                onColorUpdate: { (log, color) in
                    self.onAction?(.updateColor(log, newColor: color))
                })

            DateStepperView(targetDate: self.$targetDate, accentColor: self.log.baby.themeColor?.color)
            
            ScrollView(.vertical) {
                self.bottleSummaryView()
                
                self.breastFeedSummaryView()
                
                self.diaperSummaryView()
                
                self.napSummaryView()
                
                self.tummyTimeSummaryView()
                
                self.weightSummaryView()
                
                self.customEventsViews()
                
                self.newCustomEventView()
                    .padding(.bottom, 300)
            }
        }
        .padding(.vertical)
        .onReceive(NotificationCenter.default.publisher(for: UIDocument.stateChangedNotification, object: log), perform: self.handleStateChange)
    }
    
    // MARK: Bottle Feedings
    func bottleSummaryView() -> some View {
        MeasuredEventFormView<FeedEvent>(
            log: log,
            date: targetDate,
            displayTitle: FeedEvent.Source.bottle.displayTitle,
            imageName: FeedEvent.Source.bottle.imageName,
            filter: { (event: FeedEvent) -> Bool in
                guard self.startOfTargetDate <= event.date,
                    event.date < self.endOfTargetDate
                    else { return false }
                return event.source == FeedEvent.Source.bottle
            },
            sort: { $0.date < $1.date },
            onAction: onBottleEventAction)
    }
    
    // MARK: Breast Feedings
    func breastFeedSummaryView() -> some View {
        MeasuredEventFormView<FeedEvent>(
            log: log,
            date: targetDate,
            displayTitle: FeedEvent.Source.breast(.both).displayTitle,
            imageName: FeedEvent.Source.breast(.both).imageName,
            filter: { (event: FeedEvent) -> Bool in
                guard self.startOfTargetDate <= event.date,
                    event.date < self.endOfTargetDate
                    else { return false }
                return event.source != FeedEvent.Source.bottle
            },
            sort: { $0.date < $1.date },
            onAction: onEventAction)
    }
    
    // MARK: Diapers
    func diaperSummaryView() -> some View {
        DiaperSummaryView(
            log: log,
            date: targetDate,
            onAction: onEventAction,
            filter: { (event: DiaperEvent) -> Bool in
                guard self.startOfTargetDate <= event.date,
                    event.date < self.endOfTargetDate
                    else { return false }
                return true
            })
    }
    
    // MARK: Naps
    func napSummaryView() -> some View {
        MeasuredEventFormView(
            log: log,
            date: targetDate,
            displayTitle: BabyEventType.nap.displayTitle,
            imageName: BabyEventType.nap.imageName,
            filter: { (event: NapEvent) -> Bool in
                guard
                    self.startOfTargetDate <= event.date,
                    event.date < self.endOfTargetDate
                    else { return false }
                return true
            },
            sort: { $0.date < $1.date },
            onAction: onEventAction)
    }
    
    // MARK: Tummy Times
    func tummyTimeSummaryView() -> some View {
        MeasuredEventFormView<TummyTimeEvent>(
            log: log,
            date: targetDate,
            displayTitle: BabyEventType.tummyTime.displayTitle,
            imageName: BabyEventType.tummyTime.imageName,
            filter: { (event: TummyTimeEvent) -> Bool in
                guard
                    self.startOfTargetDate <= event.date,
                    event.date < self.endOfTargetDate
                    else { return false }
                return true
            },
            sort: { $0.date < $1.date },
            onAction: onEventAction,
            overrideIncrement: 1.0)
    }
    
    // MARK: Weight Checks
    func weightSummaryView() -> some View {
        MeasuredEventFormView<WeightEvent>(
            log: log,
            date: targetDate,
            displayTitle: BabyEventType.weight.displayTitle,
            imageName: BabyEventType.weight.imageName,
            filter: { (event: WeightEvent) -> Bool in
                let start = self.startOfTargetDate
                let end = self.endOfTargetDate
                guard
                    start <= event.date,
                    event.date < end
                    else { return false }
                return true
            },
            sort: { $0.date < $1.date },
            onAction: onEventAction)
    }
    
    // MARK: Custom
    func customEventsViews() -> some View {
        ForEach(
            log.eventStore.customEvents.values
                .filter({ event -> Bool in
                    return startOfTargetDate <= event.date && event.date < endOfTargetDate
                })
                .reduce([:], { (inputValue, event) -> [String: [CustomEvent]] in
                    var input = inputValue
                    
                    var inputEvents: [CustomEvent] = inputValue[event.event] ?? []
                    inputEvents.append(event)

                    input[event.event] = inputEvents
                    return input
                })
                .values
                .sorted(by: { (_ a: [CustomEvent], _ b: [CustomEvent]) -> Bool in
                    return a.sorted(by: { $0.date < $1.date }).last!.date < b.sorted(by: { $0.date < $1.date }).last!.date }),
            id: \.self)
            { events in
                CustomEventFormView(
                    restoreContent: events.map({ event in
                        return .init(
                            date: .init(event.date),
                            id: event.id,
                            title: event.event,
                            info: event.detail ?? "")
                        }),
                    onAction: self.onEventAction)
            }
    }
    
    func newCustomEventView() -> some View {
        CustomEventFormView(
            content: .init(),
            onAction: onEventAction)
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

enum MeasuredEventFormAction<E: MeasuredBabyEvent> {
    case create(_: MeasuredEventFormView<E>.FormContent)
    case remove(_: UUID)
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
            if unit.modifier > 0 {
                let value = event.measurement?.value ?? unit.defaultValue
                let adjustment = unit.modifier * Double(increment ?? 0)
                event.measurement = Measurement(value: value + adjustment, unit: unit)
            }
            self.log.save(event) { (_) in
                print("💾: Event added to log")
            }
        case .remove(let event):
            self.log.delete(event) { (_) in
                print("Did Delete?")
            }
        case .toggleUnit(let event):
            guard event.measurement != nil else { return }
//            let values = UnitVolume.supported
//            let index = values.lastIndex(of: size.unit) ?? values.endIndex
//            let newIndex = (index + 1) % values.count
//            let newUnit = values[newIndex]
//            event.measurement = size.converted(to: newUnit)
//            let absCount = round((event.measurement?.value ?? 0) / (newUnit.modifier ?? 1))
//            event.measurement?.value = max((absCount * (newUnit.modifier ?? 0)), 0)
//            self.log.save(event) { (_) in
//                print("💾: Event added to log")
//            }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventFormAction<FeedEvent>) {
        switch action {
        case .create(let form):
            let event = FeedEvent(
                id: form.id ?? UUID(),
                date: form.date.date,
                source: .breast(.both),
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<FeedEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
    
    func onBottleEventAction(_ action: MeasuredEventFormAction<FeedEvent>) {
        switch action {
        case .create(let form):
            let event = FeedEvent(
                id: form.id ?? UUID(),
                date: form.date.date,
                source: .bottle,
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<FeedEvent?, BabyError>) in
                print("Did Delete?")
            }
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
            if unit.modifier > 0 {
                let value = event.measurement?.value ?? unit.defaultValue
                let adjustment = unit.modifier * Double(increment ?? 0)
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
        case .toggleUnit(let event):
            guard event.measurement != nil else { return }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventFormAction<NapEvent>) {
        switch action {
        case .create(let form):
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: form.date.date)
            let date = Date.apply(timeComponents, to: startOfTargetDate)
            let event = NapEvent(
                id: form.id ?? UUID(),
                date: date,
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<NapEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
    
    func onEventAction(_ action: MeasuredEventFormAction<TummyTimeEvent>) {
        switch action {
        case .create(let form):
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: form.date.date)
            let date = Date.apply(timeComponents, to: startOfTargetDate)
            let event = TummyTimeEvent(
                id: form.id ?? UUID(),
                date: date,
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<TummyTimeEvent?, BabyError>) in
                print("Did Delete?")
            }
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
            if unit.modifier > 0 {
                let value = event.measurement?.value ?? unit.defaultValue
                let adjustment = unit.modifier * Double(increment ?? 0)
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
            if unit.modifier > 0 {
                let value = event.measurement?.value ?? unit.defaultValue
                let adjustment = unit.modifier * Double(increment ?? 0)
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
        case .toggleUnit(let event):
            guard event.measurement != nil else { return }
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
            if unit.modifier > 0 {
                let value = event.measurement?.value ?? unit.defaultValue
                let adjustment = unit.modifier * Double(increment ?? 0)
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
        case .toggleUnit(let event):
            guard event.measurement != nil else { return }
        case .showDetail:
            print("Present list of items")
        case .undo:
            self.log.undoManager.undo()
        case .redo:
            self.log.undoManager.redo()
        }
    }
    
    func onEventAction(_ action: MeasuredEventFormAction<WeightEvent>) {
        switch action {
        case .create(let form):
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: form.date.date)
            let date = Date.apply(timeComponents, to: startOfTargetDate)
            let event = WeightEvent(
                id: form.id ?? UUID(),
                date: date,
                measurement: form.measurement
            )
            self.log.save(event) { (saveResult) in
                print("💾: Event added to log")
            }
        case .remove(let id):
            self.log.delete(id) { (deleteResult: Result<WeightEvent?, BabyError>) in
                print("Did Delete?")
            }
        }
    }
    
    // MARK: Diaper Events
    func onEventAction(_ action: DiaperAction) {
        switch action {
        case .create(let form):
            let event = DiaperEvent(
                id: form.id ?? UUID(),
                date: form.date.date,
                pee: form.pee,
                poop: form.poo)
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let uuid):
            print("in delete")
            self.log.delete(uuid) { (deleteResult: Result<DiaperEvent?, BabyError>) in
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
        case .create(let form):
            let event = CustomEvent(
                id: form.id ?? .init(),
                date: form.date.date,
                event: form.title,
                detail: form.info.isEmpty ? nil : form.info)
            self.log.save(event) { (savedEvent) in
                print("Did Save?")
            }
        case .remove(let uuid):
            self.log.delete(uuid) { (_: Result<CustomEvent?, BabyError>) in
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

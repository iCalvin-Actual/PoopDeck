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
    
    /// Presents Conflict Resolution view
    @State var resolvingConflict: Bool = false
    
    /// Document in flux state, prevent changes until state change
    /// Not enforced...
    @State var allowChanges: Bool = true
    
    /// Active date to query for in summary views
    @State var targetDate: ObservableDate = .init()
    
    /// Date range to perform search within
    var startOfTargetDate: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: targetDate.date)
    }
    var endOfTargetDate: Date {
        let start = startOfTargetDate
        
        let components = DateComponents(calendar: .current, day:1)
        return Date.apply(components, to: start)
    }
    
    /// Send document actions up to the DocumentView
    var onAction: ((DocumentAction) -> Void)?
    
    // MARK: - Views
    
    var body: some View {
        VStack(spacing: 2) {
            BabyInfoView(
                log: self.log,
                onColorUpdate: { (log, color) in
                    self.onAction?(.updateColor(log, newColor: color))
                })

            DateStepperView(targetDate: self.$targetDate, accentColor: self.log.baby.themeColor?.colorValue)
            
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
        DiaperFormView(
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
    
    /// For custom events show a new entry form as a separate card
    func newCustomEventView() -> some View {
        CustomEventFormView(
            content: .init(),
            onAction: onEventAction)
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
        baby.themeColor = ThemeColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        LogView(log: babyLog)
    }
}

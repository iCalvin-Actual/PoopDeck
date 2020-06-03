//
//  ContentViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct TimeDurationView: View {
    let startDate: Date
    let duration: TimeInterval?
    var body: some View {
        VStack {
            Text(DateFormatter.timeDisplay.string(from: startDate))
            if duration ?? 0 > 0 {
                Text(DateComponentsFormatter.durationDisplay.string(from: duration ?? 0) ?? "")
            }
        }
    }
}

public struct FeedView: View {
    
    @State var showNewEventForm: Bool = false
    @State var newEventType: BabyEventType? = nil
    
    @State var recordManager: BabyEventRecordsManager
    public var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(recordManager.dateSortedModels) { event in
                        NavigationLink(destination: EventFormView(
                            eventID: event.id,
                            eventType: event.type,
                            recordManager: self.recordManager,
                            didUpdate: self.reloadEvents)) {
                            FeedCard(event: event)
                                .cornerRadius(8)
                                .contextMenu {
                                    Button(action: {
//                                        self.recordManager.delete(event.id) { result in
//                                            self.reloadEvents()
//                                        }
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash.fill")
                                    }

                                    Button(action: {
//                                        self.recordManager.duplicate(event.id) { result in
//                                            self.reloadEvents()
//                                        }
                                    }) {
                                        Text("Duplicate")
                                        Image(systemName: "doc.on.doc.fill")
                                    }
                           }
                        }
                    }
                    .padding(.trailing, 4)
                    .frame(maxWidth: 835.0)
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                
                Spacer()
                NewEventTypeSelector(didSelect: { eventType in
                    self.presentNewEventSheet(type: eventType)
                })
            }
            .navigationBarTitle(
                Text("Sophia Events")
            )
            .sheet(isPresented: self.$showNewEventForm) {
                NavigationView {
                    EventFormView(eventType: self.newEventType!,
                                  recordManager: self.recordManager,
                                  didUpdate: self.reloadEvents)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func reloadEvents() {
        self.showNewEventForm = false
//        EventManager.shared.fetchSummary { summary in
//            guard let summary = summary else {
//                return
//            }
//            self.feed = summary.dateSortedModels
//        }
    }
    
    func presentNewEventSheet(type: BabyEventType) {
        self.newEventType = type
        self.showNewEventForm = true
    }
}

struct NewEventTypeSelector: View {
    let didSelect: ((BabyEventType) -> Void)?
    
    @State var selected: BabyEventType = .feed
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 2) {
                NewEventButton(type: .feed, didSelect: self.didSelect)
                NewEventButton(type: .diaper, didSelect: self.didSelect)
                NewEventButton(type: .nap, didSelect: self.didSelect)
                NewEventButton(type: .tummyTime, didSelect: self.didSelect)
                NewEventButton(type: .weight, didSelect: self.didSelect)
                NewEventButton(type: .fuss, didSelect: self.didSelect)
                NewEventButton(type: .custom, didSelect: self.didSelect)
            }
            .padding()
        }
    }
}

struct NewEventButton: View {
    let type: BabyEventType
    let didSelect: ((BabyEventType) -> Void)?
    
    var body: some View {
        Button(action: {
            self.didSelect?(self.type)
        }) {
            ZStack {
                Circle()
                    .foregroundColor(type.colorValue)
                
                Text(type.emojiValue)
                    .font(.largeTitle)
            }
            .frame(width: 88.0, height: 88.0)
        }
    }
}

extension BabyEventType {
    var emojiValue: String {
        switch self {
        case .feed:
            return "🤱🏻"
        case .diaper:
            return "🧷"
        case .nap:
            return "💤"
        case .fuss:
            return "😾"
        case .weight:
            return "⚖️"
        case .tummyTime:
            return "🚼"
        case .custom:
            return "👨‍👩‍👧"
        }
    }
    
    var colorValue: Color {
        switch self {
        case .feed:
            return .yellow
        case .diaper:
            return .blue
        case .nap:
            return .red
        case .fuss:
            return .purple
        case .weight:
            return .orange
        case .tummyTime:
            return .green
        case .custom:
            return .pink
        }
    }
}



struct ContentViews_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}

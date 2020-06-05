//
//  DocumentsView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

enum DocumentAction {
    case save(_ log: BabyLog)
    case close(_ log: BabyLog)
    case resolve(_ log: BabyLog)
}

struct DocumentsView: View {
    var logs: [BabyLog] = []
    
    @State var selected: BabyLog
    
    var onAction: ((DocumentAction) -> Void)?
    
    var body: some View {
        VStack {
//            BabyPickerView(babies: logs.map({ $0.baby }), onSelect: { (baby: Baby) in
//                if let selectedLog =  self.logs.first(where: { $0.baby == baby }) {
////                    self.selected = selectedLog
//                    self.onAction?(.close(selectedLog))
//                }
//            })
//            Spacer()
            LogView(log: selected, onAction: self.onAction)
        }
    }
}

struct BabyPickerView: View {
    var babies: [Baby] = []
    
    var onSelect: ((Baby) -> Void)?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("BabyA")
                Spacer()
                Button(action: {
                    print("New baby form")
                }) {
                    Image(systemName: "person.crop.circle.badge.plus")
                }
            }
        }
    }
}

struct LogView: View {
    @ObservedObject var log: BabyLog
    @Environment(\.editMode) var editMode
    
    @State private var allowChanges: Bool = true
    @State private var resolvingConflict: Bool = false
    
    var onAction: ((DocumentAction) -> Void)?
    
    var body: some View {
        VStack {
//            TextField("Baby Name", text: $log.baby.name, onCommit: {
//                self.onAction?(.save(self.log))
//            })
//            .font(.system(.largeTitle, design: .rounded))
//            .disabled(!allowChanges)
//            .onAppear(perform: {
//                EventManager().fetchSummary { summary in
//                    guard let summary = summary else { return }
//                    DispatchQueue.main.async {
//                        self.log.importSummary(summary)
//                    }
//                }
//            })
            
            
//            FeedSummaryView(manager: $log.recordManager, allowChanges: self.allowChanges)
            FeedView(babyLog: log)
        }
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

//struct DocumentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentsView(logs: [], selected: .constant(0))
//    }
//}

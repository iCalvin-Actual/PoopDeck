//
//  DocumentsView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct DocumentsView: View {
    var logs: [BabyLog] = []
    
    @State var selected: BabyLog
    
    var onSave: ((BabyLog) -> Void)?
    var onClose: ((BabyLog) -> Void)?
    
    var body: some View {
        VStack {
            BabyPickerView(babies: logs.map({ $0.baby }), onSelect: { (baby: Baby) in
                if let selectedLog =  self.logs.first(where: { $0.baby == baby }) {
//                    self.selected = selectedLog
                    self.onClose?(selectedLog)
                }
            })
            Spacer()
            LogView(log: selected, onSave: self.onSave)
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
                    Image("person.crop.circle.badge.plus")
                }
            }
        }
    }
}

struct LogView: View {
    @ObservedObject var log: BabyLog
    @Environment(\.editMode) var editMode
    
    @State private var allowChanges: Bool = true
    var onSave: ((BabyLog) -> Void)?
    
    var body: some View {
        VStack {
            TextField("Baby Name", text: $log.baby.name, onCommit: {
                self.onSave?(self.log)
            })
            .disabled(!allowChanges)
            
            
            FeedSummaryView(manager: $log.recordManager, allowChanges: self.allowChanges)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDocument.stateChangedNotification, object: log), perform: self.handleStateChange)
    }
    
    func handleStateChange(_ notification: Notification) {
        switch log.documentState {
        case .editingDisabled:
            self.allowChanges = false
            print("Pause changes")
        case .inConflict:
            guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: log.fileURL) else {
                self.allowChanges = false
                return
            }
            let dateSorted = versions.sorted(by: { ($0.modificationDate ?? Date()) < ($1.modificationDate ?? Date()) })
            if let last = dateSorted.last {
                do {
                    try last.replaceItem(at: self.log.fileURL, options: .byMoving)
                } catch {
                    print("🚨 Failed to resolve conflict")
                }
            }
            self.log.revert(toContentsOf: self.log.fileURL, completionHandler: { success in
                do {
                    try NSFileVersion.removeOtherVersionsOfItem(at: self.log.fileURL)
                    versions.forEach({ $0.isResolved = true })
                    
                    versions.forEach({ v in
                        try? v.remove()
                    })
                } catch {
                    print("🚨 Failed to resolve conflict")
                }
            })
        case .savingError:
            print("Error saving")
        default:
            self.allowChanges = true
            print("No conflict")
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

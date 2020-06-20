//
//  Document.swift
//  DocBasedBabyTracker
//
//  Created by Calvin Chestnut on 6/1/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

// MARK: - Archive
struct BabyLogArchive: Codable {
    let baby: Baby
    let eventStore: BabyEventStore
    
    init(_ log: BabyLog) {
        self.baby = log.baby
        self.eventStore = log.eventStore
    }
    init(_ baby: Baby) {
        self.baby = baby
        self.eventStore = .init()
    }
}

// MARK: - Baby Log
class BabyLog: UIDocument {
    @Published
    var eventStore: BabyEventStore = .init() {
        willSet {
            let oldValue = eventStore
            undoManager?.registerUndo(withTarget: self) { $0.eventStore = oldValue }
        }
    }
    
    @Published
    public var baby: Baby = .new {
        willSet {
            guard !baby.name.isEmpty else { return }
            let oldValue = self.baby
            undoManager.registerUndo(withTarget: self) { $0.baby = oldValue }
        }
    }
    
    // MARK: - File I/O
    
    override func contents(forType typeName: String) throws -> Any {
        return try JSONEncoder.safe.encode(BabyLogArchive(self))
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contentData = contents as? Data else {
            throw BabyError.unknown
        }
        do {
            let archive = try JSONDecoder.safe.decode(BabyLogArchive.self, from: contentData)
            self.baby = archive.baby
            self.eventStore = archive.eventStore
        } catch {
            throw BabyError.unknown
        }
    }
    
    override func presentedItemDidMove(to newURL: URL) {
        /// Make sure this is tracked?
        if newURL.pathComponents.contains(".Trash") {
            /// Alert and close document
            self.close { (closed) in
                print("Closed? \(closed)")
            }
        }
        super.presentedItemDidMove(to: newURL)
    }
    
//    override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
//        super.save(to: url, for: saveOperation) { (success) in
//            if let last = url.pathComponents.last, !last.contains(self.baby.displayName) {
//                var expectedURL = url
//                expectedURL.deleteLastPathComponent()
//                expectedURL.appendPathComponent("\(self.baby.displayName).bblg")
//                self.close { (closed) in
//                    do {
//                        try FileManager.default.moveItem(at: self.fileURL, to: expectedURL)
//                        let newLog = BabyLog(fileURL: expectedURL)
//                        newLog.open { (openSuccess) in
//                            completionHandler?(openSuccess)
//                        }
//                        return
//                    } catch {
//                        self.open { (reopenSuccess) in
//                            completionHandler?(false)
//                        }
//                        print("🚨 Failed to rename file \(url.absoluteString)")
//                    }
//                }
//            } else {
//                completionHandler?(success)
//            }
//        }
//    }
}

protocol UndoRegister: AnyObject {
    func registerUndo<U: AnyObject>(withTarget: U, handler: ((_: U) -> Void))
}


// MARK: - Event Store
/// TODO: Refactor events into
/// MeasuredEvents
///    Type
///        bottle
///        breast
///        diaper
///        nap
///        tummy
///        weight
///
///    Measurement
///
/// var measuredEvents: [EventType: [UUID: MeasuredEvent]]
struct BabyEventStore: Codable {
    var feedings:       [UUID: FeedEvent] = [:]
    var changes:        [UUID: DiaperEvent] = [:]
    var naps:           [UUID: NapEvent] = [:]
    var weighIns:       [UUID: WeightEvent] = [:]
    var tummyTimes:     [UUID: TummyTimeEvent] = [:]
    var customEvents:   [UUID: CustomEvent] = [:]
}

extension BabyLog {
    // MARK: - Get Group
    func groupOfType<E: BabyEvent>(completion: ((Result<[UUID: E], BabyError>) -> Void)) {
        if FeedEvent.self == E.self, let feedings = eventStore.feedings as? [UUID: E] {
            completion(.success(feedings))
        } else if NapEvent.self == E.self, let naps = eventStore.naps as? [UUID: E] {
            completion(.success(naps))
        } else if DiaperEvent.self == E.self, let changes = eventStore.changes as? [UUID: E] {
            completion(.success(changes))
        } else if WeightEvent.self == E.self, let weighIns = eventStore.weighIns as? [UUID: E] {
            completion(.success(weighIns))
        } else if TummyTimeEvent.self == E.self, let tummyTimes = eventStore.tummyTimes as? [UUID: E] {
            completion(.success(tummyTimes))
        } else if FeedEvent.self == E.self, let customEvents = eventStore.customEvents as? [UUID: E] {
            completion(.success(customEvents))
        }
    
        completion(.failure(.unknown))
    }
    
    // MARK: - Get Group
    func setGroup<E: BabyEvent>(newValue: [UUID: E], completion: ((Result<[UUID: E], BabyError>) -> Void)) {
        if let newFeedings = newValue as? [UUID: FeedEvent] {
            eventStore.feedings = newFeedings
            completion(.success(newValue))
        } else if let newChanges = newValue as? [UUID: DiaperEvent] {
            eventStore.changes = newChanges
            completion(.success(newValue))
        } else if let newNaps = newValue as? [UUID: NapEvent] {
            eventStore.naps = newNaps
            completion(.success(newValue))
        } else if let newWeighIns = newValue as? [UUID: WeightEvent] {
            eventStore.weighIns = newWeighIns
            completion(.success(newValue))
        } else if let newTummies = newValue as? [UUID: TummyTimeEvent] {
            eventStore.tummyTimes = newTummies
            completion(.success(newValue))
        } else if let newCustoms = newValue as? [UUID: CustomEvent] {
            eventStore.customEvents = newCustoms
            completion(.success(newValue))
        }
        completion(.failure(.unknown))
    }
    
    // MARK: - Get Item
    func fetch<E: BabyEvent>(_ id: UUID, completion: ((Result<E, BabyError>) -> Void)) {
        if let feedEvent = eventStore.feedings[id] as? E {
            completion(.success(feedEvent))
        } else if let changeEvent = eventStore.changes[id] as? E {
           completion(.success(changeEvent))
        } else if let napEvent = eventStore.naps[id] as? E {
            completion(.success(napEvent))
        } else if let weightEvent = eventStore.weighIns[id] as? E {
            completion(.success(weightEvent))
        } else if let tummyEvent = eventStore.tummyTimes[id] as? E {
            completion(.success(tummyEvent))
        } else if let customEvent = eventStore.customEvents[id] as? E {
            completion(.success(customEvent))
        }
    }
    
    // MARK: - Delete
    func delete<E: BabyEvent>(_ event: E, completion: ((Result<E?, BabyError>) -> Void)) {
        self.delete(event.id, completion: completion)
    }
    
    func delete<E: BabyEvent>(_ id: UUID, completion: ((Result<E?, BabyError>) -> Void)) {
        if let _ = eventStore.feedings[id] as? E {
            eventStore.feedings[id] = nil
            completion(.success(nil))
        } else if let _ = eventStore.changes[id] as? E {
            eventStore.changes[id] = nil
            completion(.success(nil))
        } else if let _ = eventStore.naps[id] as? E {
            eventStore.naps[id] = nil
            completion(.success(nil))
        } else if let _ = eventStore.weighIns[id] as? E {
            eventStore.weighIns[id] = nil
            completion(.success(nil))
        } else if let _ = eventStore.tummyTimes[id] as? E {
            eventStore.tummyTimes[id] = nil
            completion(.success(nil))
        } else if let _ = eventStore.customEvents[id] as? E {
            eventStore.customEvents[id] = nil
            completion(.success(nil))
        } else {
            completion(.failure(.unknown))
        }
    }
    
    // MARK: - Duplicate
    func duplicate<E: BabyEvent>(_ id: UUID, completion: ((Result<E, BabyError>) -> Void)) {
        self.fetch(id) { (fetchItemResult: Result<E, BabyError>) in
            switch fetchItemResult {
            case .failure(let error):
                completion(.failure(error))
            case .success(let event):
                var newEvent = event
                newEvent.id = UUID()
                newEvent.date = Date()
                self.save(newEvent, completion: completion)
            }
        }
    }
    
    // MARK: - Save
    func save<E: BabyEvent>(_ event: E, completion: ((Result<E, BabyError>) -> Void)) {
        if let feedEvent = event as? FeedEvent {
            eventStore.feedings[event.id] = feedEvent
            completion(.success(event))
        } else if let changeEvent = event as? DiaperEvent {
            eventStore.changes[event.id] = changeEvent
           completion(.success(event))
        } else if let napEvent = event as? NapEvent {
            eventStore.naps[event.id] = napEvent
            completion(.success(event))
        } else if let weightEvent = event as? WeightEvent {
            eventStore.weighIns[event.id] = weightEvent
            completion(.success(event))
        } else if let tummyEvent = event as? TummyTimeEvent {
            eventStore.tummyTimes[event.id] = tummyEvent
            completion(.success(event))
        } else if let customEvent = event as? CustomEvent {
            eventStore.customEvents[event.id] = customEvent
            completion(.success(event))
        } else {
            completion(.failure(.unknown))
        }
    }
}

extension BabyLog: Identifiable { }
extension BabyLog: ObservableObject { }

struct BabyLog_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

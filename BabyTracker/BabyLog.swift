//
//  Document.swift
//  DocBasedBabyTracker
//
//  Created by Calvin Chestnut on 6/1/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI

/*
 Baby
    Birthday
    Name
    Color
 
 Feedings
 DiaperChanges
 Naps
 TummyTimes
 Weights
 Fussies
 Custom
 
 */

struct PreferredColor {
    let r, g, b, a: Double
}

class Baby: Codable, Equatable {
    static func == (lhs: Baby, rhs: Baby) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID
    
    init() {
        self.id = UUID()
    }
    
    var name: String = ""
    var birthday: Date?
    
    private var imageData: Data?
    
    private var color: PreferredColor?
}

extension PreferredColor: Codable { }
extension Baby {
    static var new: Baby {
        return Baby()
    }
}
extension Baby {
    var displayName: String {
        guard !name.isEmpty else {
            return "Little Baby"
        }
        return name
    }
    
    var displayInitial: String {
        return String(displayName.first!)
    }
    
    var preferredColor: Color? {
        get {
            guard let color = self.color else { return nil }
            return Color(red: color.r, green: color.g, blue: color.b)
        }
    }
}

struct BabyLogArchive: Codable {
    let baby: Baby
    let recordManager: BabyEventRecordsManager
    
    init(_ log: BabyLog) {
        self.baby = log.baby
        self.recordManager = log.recordManager
    }
}

class BabyLog: UIDocument {
    private var hasEdited: Bool = false
    override var hasUnsavedChanges: Bool {
        return hasEdited
    }
    
    @Published
    var recordManager: BabyEventRecordsManager = .init() {
        willSet {
            let oldValue = self.recordManager
            undoManager.registerUndo(withTarget: self) { (target) in
                target.recordManager = oldValue
            }
            hasEdited = true
        }
    }
    
    @Published
    public var baby: Baby = .new {
        willSet {
            guard !baby.name.isEmpty else { return }
            let oldValue = self.baby
            undoManager.registerUndo(withTarget: self) { (target) in
                target.baby = oldValue
            }
            hasEdited = true
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let contents = try JSONEncoder().encode(BabyLogArchive(self))
        self.hasEdited = false
        return contents
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contentData = contents as? Data else {
            throw BabyError.unknown
        }
        if let archive = try? JSONDecoder().decode(BabyLogArchive.self, from: contentData) {
            self.baby = archive.baby
            self.recordManager = archive.recordManager
        } else {
            let baby = try JSONDecoder().decode(Baby.self, from: contentData)
            self.baby = baby
        }
    }
    
    override func presentedItemDidMove(to newURL: URL) {
        super.presentedItemDidMove(to: newURL)
    }
}

class BabyEventRecordsManager: Codable {
    private var feedings:       [UUID: FeedEvent] = [:]
    private var changes:        [UUID: DiaperEvent] = [:]
    private var naps:           [UUID: NapEvent] = [:]
    private var fussies:        [UUID: FussEvent] = [:]
    private var weighIns:       [UUID: WeightEvent] = [:]
    private var tummyTimes:     [UUID: TummyTimeEvent] = [:]
    private var customEvents:   [UUID: CustomEvent] = [:]
    
    func groupOfType<E: BabyEvent>(completion: ((Result<[UUID: E], BabyError>) -> Void)) {
        if let feedings = feedings as? [UUID: E] {
            completion(.success(feedings))
        } else if let changes = changes as? [UUID: E] {
            completion(.success(changes))
        } else if let naps = naps as? [UUID: E] {
            completion(.success(naps))
        } else if let fussies = fussies as? [UUID: E] {
            completion(.success(fussies))
        } else if let weighIns = weighIns as? [UUID: E] {
            completion(.success(weighIns))
        } else if let tummyTimes = tummyTimes as? [UUID: E] {
            completion(.success(tummyTimes))
        } else if let customEvents = customEvents as? [UUID: E] {
            completion(.success(customEvents))
        }
        completion(.failure(.unknown))
    }
    
    func setGroup<E: BabyEvent>(newValue: [UUID: E], completion: ((Result<[UUID: E], BabyError>) -> Void)) {
        if let newFeedings = newValue as? [UUID: FeedEvent] {
            self.feedings = newFeedings
            completion(.success(newValue))
        } else if let newChanges = newValue as? [UUID: DiaperEvent] {
            self.changes = newChanges
            completion(.success(newValue))
        } else if let newNaps = newValue as? [UUID: NapEvent] {
            self.naps = newNaps
            completion(.success(newValue))
        } else if let newFussies = newValue as? [UUID: FussEvent] {
            self.fussies = newFussies
            completion(.success(newValue))
        } else if let newWeighIns = newValue as? [UUID: WeightEvent] {
            self.weighIns = newWeighIns
            completion(.success(newValue))
        } else if let newTummies = newValue as? [UUID: TummyTimeEvent] {
            self.tummyTimes = newTummies
            completion(.success(newValue))
        } else if let newCustoms = newValue as? [UUID: CustomEvent] {
            self.customEvents = newCustoms
            completion(.success(newValue))
        }
        completion(.failure(.unknown))
    }
    
    func fetch<E: BabyEvent>(_ id: UUID, completion: ((Result<E, BabyError>) -> Void)) {
        if let feedEvent = self.feedings[id] as? E {
            completion(.success(feedEvent))
        } else if let changeEvent = self.changes[id] as? E {
           completion(.success(changeEvent))
        } else if let napEvent = self.naps[id] as? E {
            completion(.success(napEvent))
        } else if let fussEvent = self.fussies[id] as? E {
            completion(.success(fussEvent))
        } else if let weightEvent = self.weighIns[id] as? E {
            completion(.success(weightEvent))
        } else if let tummyEvent = self.tummyTimes[id] as? E {
            completion(.success(tummyEvent))
        } else if let customEvent = self.customEvents[id] as? E {
            completion(.success(customEvent))
        }
    }
    
    func delete<E: BabyEvent>(_ id: UUID, completion: ((Result<E?, BabyError>) -> Void)) {
        if let _ = self.feedings[id] as? E {
            self.feedings[id] = nil
            completion(.success(nil))
        } else if let _ = self.changes[id] as? E {
            self.feedings[id] = nil
           completion(.success(nil))
        } else if let _ = self.naps[id] as? E {
            self.naps[id] = nil
            completion(.success(nil))
        } else if let _ = self.fussies[id] as? E {
            self.fussies[id] = nil
            completion(.success(nil))
        } else if let _ = self.weighIns[id] as? E {
            self.weighIns[id] = nil
            completion(.success(nil))
        } else if let _ = self.tummyTimes[id] as? E {
            self.tummyTimes[id] = nil
            completion(.success(nil))
        } else if let _ = self.customEvents[id] as? E {
            self.customEvents[id] = nil
            completion(.success(nil))
        }
        completion(.failure(.unknown))
    }
    
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
    
    func save<E: BabyEvent>(_ event: E, completion: ((Result<E, BabyError>) -> Void)) {
        if let feedEvent = event as? FeedEvent {
            self.feedings[event.id] = feedEvent
            completion(.success(event))
        } else if let changeEvent = event as? DiaperEvent {
            self.changes[event.id] = changeEvent
           completion(.success(event))
        } else if let napEvent = event as? NapEvent {
            self.naps[event.id] = napEvent
            completion(.success(event))
        } else if let fussEvent = event as? FussEvent {
            self.fussies[event.id] = fussEvent
            completion(.success(event))
        } else if let weightEvent = event as? WeightEvent {
            self.weighIns[event.id] = weightEvent
            completion(.success(event))
        } else if let tummyEvent = event as? TummyTimeEvent {
            self.tummyTimes[event.id] = tummyEvent
            completion(.success(event))
        } else if let customEvent = event as? CustomEvent {
            self.customEvents[event.id] = customEvent
            completion(.success(event))
        } else {
            completion(.failure(.unknown))
        }
    }
}

extension BabyLog: Identifiable { }
extension BabyLog {
    var dateSortedModels: [FeedViewModel] {
        return self.recordManager.dateSortedModels
    }
}
extension BabyEventRecordsManager {
    var dateSortedModels: [FeedViewModel] {
        var models: [FeedViewModel] = []
        
        models.append(contentsOf: self.feedings.values.map({ $0.viewModel }))
        models.append(contentsOf: self.changes.values.map({ $0.viewModel }))
        models.append(contentsOf: self.naps.values.map({ $0.viewModel }))
        models.append(contentsOf: self.fussies.values.map({ $0.viewModel }))
        models.append(contentsOf: self.weighIns.values.map({ $0.viewModel }))
        models.append(contentsOf: self.tummyTimes.values.map({ $0.viewModel }))
        models.append(contentsOf: self.customEvents.values.map({ $0.viewModel }))
        
        models.sort(by: { $0.date > $1.date })
        
        return models
    }
}


extension BabyLog:  ObservableObject { }
extension Baby:     ObservableObject { }


struct BabyLog_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

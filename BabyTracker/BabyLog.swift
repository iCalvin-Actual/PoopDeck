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

struct PreferredColor: Hashable {
    let r, g, b: Double
    
    init(r: Double, g: Double, b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }
    init(uicolor: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uicolor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.r = Double(r)
        self.g = Double(g)
        self.b = Double(b)
    }
    
    var color: Color {
        return Color(red: r, green: g, blue: b)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
    }}

extension PreferredColor {
    static var prebuiltSet: [PreferredColor] {
        return [
            PreferredColor(r: 0, g: 0, b: 0),
            PreferredColor(r: 0, g: 0, b: 1),
            PreferredColor(r: 0, g: 1, b: 0),
            PreferredColor(r: 0, g: 1, b: 1),
            PreferredColor(r: 1, g: 0, b: 0),
            PreferredColor(r: 1, g: 0, b: 1),
            PreferredColor(r: 1, g: 1, b: 0)
        ]
    }
    static var random: PreferredColor {
        return prebuiltSet.randomElement()!
    }
}

class Baby: Codable, Equatable, Hashable {
    static func == (lhs: Baby, rhs: Baby) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: UUID
    
    init() {
        self.id = UUID()
    }
    
    var name: String = ""
    var emoji: String = ""
    var birthday: Date?
    
    private var imageData: Data?
    
    var color: PreferredColor? = .random
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
        hasher.combine(name)
        hasher.combine(color)
        hasher.combine(birthday)
    }
}

extension PreferredColor: Codable { }
extension Baby {
    static var new: Baby {
        return Baby()
    }
}
extension Baby {
    var nameComponents: PersonNameComponents? {
        return PersonNameComponentsFormatter.decodingFormatter.personNameComponents(from: name)
    }
    var displayName: String {
        guard let components = nameComponents else {
            return name
        }
        return PersonNameComponentsFormatter.shortNameFormatter.string(from: components)
    }
    
    var displayInitial: String {
        guard let components = nameComponents else {
            return name
        }
        return PersonNameComponentsFormatter.initialFormatter.string(from: components)
    }
}

struct BabyLogArchive: Codable {
    let baby: Baby
    let eventStore: BabyEventStore
    
    init(_ log: BabyLog) {
        self.baby = log.baby
        self.eventStore = log.eventStore
    }
}

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
    
    override func contents(forType typeName: String) throws -> Any {
        let contents = try JSONEncoder().encode(BabyLogArchive(self))
            return contents
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contentData = contents as? Data else {
            throw BabyError.unknown
        }
        if let archive = try? JSONDecoder().decode(BabyLogArchive.self, from: contentData) {
            self.baby = archive.baby
            self.eventStore = archive.eventStore
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
}

protocol UndoRegister: AnyObject {
    func registerUndo<U: AnyObject>(withTarget: U, handler: ((_: U) -> Void))
}

struct BabyEventStore: Codable {
    var feedings:       [UUID: FeedEvent] = [:]
    var changes:        [UUID: DiaperEvent] = [:]
    var naps:           [UUID: NapEvent] = [:]
    var fussies:        [UUID: FussEvent] = [:]
    var weighIns:       [UUID: WeightEvent] = [:]
    var tummyTimes:     [UUID: TummyTimeEvent] = [:]
    var customEvents:   [UUID: CustomEvent] = [:]
}

extension BabyLog {

    func groupOfType<E: BabyEvent>(completion: ((Result<[UUID: E], BabyError>) -> Void)) {
        if FeedEvent.self == E.self, let feedings = eventStore.feedings as? [UUID: E] {
            completion(.success(feedings))
        } else if NapEvent.self == E.self, let naps = eventStore.naps as? [UUID: E] {
            completion(.success(naps))
        } else if DiaperEvent.self == E.self, let changes = eventStore.changes as? [UUID: E] {
            completion(.success(changes))
        } else if FussEvent.self == E.self, let fussies = eventStore.fussies as? [UUID: E] {
            completion(.success(fussies))
        } else if WeightEvent.self == E.self, let weighIns = eventStore.weighIns as? [UUID: E] {
            completion(.success(weighIns))
        } else if TummyTimeEvent.self == E.self, let tummyTimes = eventStore.tummyTimes as? [UUID: E] {
            completion(.success(tummyTimes))
        } else if FeedEvent.self == E.self, let customEvents = eventStore.customEvents as? [UUID: E] {
            completion(.success(customEvents))
        }
    
        completion(.failure(.unknown))
    }
    
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
        } else if let newFussies = newValue as? [UUID: FussEvent] {
            eventStore.fussies = newFussies
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
    
    func fetch<E: BabyEvent>(_ id: UUID, completion: ((Result<E, BabyError>) -> Void)) {
        if let feedEvent = eventStore.feedings[id] as? E {
            completion(.success(feedEvent))
        } else if let changeEvent = eventStore.changes[id] as? E {
           completion(.success(changeEvent))
        } else if let napEvent = eventStore.naps[id] as? E {
            completion(.success(napEvent))
        } else if let fussEvent = eventStore.fussies[id] as? E {
            completion(.success(fussEvent))
        } else if let weightEvent = eventStore.weighIns[id] as? E {
            completion(.success(weightEvent))
        } else if let tummyEvent = eventStore.tummyTimes[id] as? E {
            completion(.success(tummyEvent))
        } else if let customEvent = eventStore.customEvents[id] as? E {
            completion(.success(customEvent))
        }
    }
    
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
        } else if let _ = eventStore.fussies[id] as? E {
            eventStore.fussies[id] = nil
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
            eventStore.feedings[event.id] = feedEvent
            completion(.success(event))
        } else if let changeEvent = event as? DiaperEvent {
            eventStore.changes[event.id] = changeEvent
           completion(.success(event))
        } else if let napEvent = event as? NapEvent {
            eventStore.naps[event.id] = napEvent
            completion(.success(event))
        } else if let fussEvent = event as? FussEvent {
            eventStore.fussies[event.id] = fussEvent
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
    
    func importSummary(_ summary: ActivitySummary) {
        eventStore.feedings = summary.feedings.reduce([:], { (result, event) -> [UUID: FeedEvent] in
            var result = result
            result[event.id] = event
            return result
        })
        eventStore.changes = summary.diaperChanges.reduce([:], { (result, event) -> [UUID: DiaperEvent] in
            var result = result
            result[event.id] = event
            return result
        })
        eventStore.naps = summary.naps.reduce([:], { (result, event) -> [UUID: NapEvent] in
            var result = result
            result[event.id] = event
            return result
        })
        eventStore.fussies = summary.fussies.reduce([:], { (result, event) -> [UUID: FussEvent] in
            var result = result
            result[event.id] = event
            return result
        })
        eventStore.weighIns = summary.weighIns.reduce([:], { (result, event) -> [UUID: WeightEvent] in
            var result = result
            result[event.id] = event
            return result
        })
        eventStore.tummyTimes = summary.tummyTimes.reduce([:], { (result, event) -> [UUID: TummyTimeEvent] in
            var result = result
            result[event.id] = event
            return result
        })
        eventStore.customEvents = summary.customEvents.reduce([:], { (result, event) -> [UUID: CustomEvent] in
            var result = result
            result[event.id] = event
            return result
        })
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
        var models: [FeedViewModel] = []
        
        models.append(contentsOf: eventStore.feedings.values.map({ $0.viewModel }))
        models.append(contentsOf: eventStore.changes.values.map({ $0.viewModel }))
        models.append(contentsOf: eventStore.naps.values.map({ $0.viewModel }))
        models.append(contentsOf: eventStore.fussies.values.map({ $0.viewModel }))
        models.append(contentsOf: eventStore.weighIns.values.map({ $0.viewModel }))
        models.append(contentsOf: eventStore.tummyTimes.values.map({ $0.viewModel }))
        models.append(contentsOf: eventStore.customEvents.values.map({ $0.viewModel }))
        
        models.sort(by: { $0.date > $1.date })
        
        return models
    }
}


extension Baby {
    static var emojiSet: [String] {
        return [
        "👶🏿",
        "👶🏾",
        "👶🏽",
        "👶🏼",
        "👶🏻",
        "👶"
        ]
    }
}


extension BabyLog: ObservableObject { }
extension Baby: ObservableObject { }
class ObservableDate: ObservableObject {
    var date: Date
    init(_ date: Date = .init()) {
        self.date = date
    }
}


struct BabyLog_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

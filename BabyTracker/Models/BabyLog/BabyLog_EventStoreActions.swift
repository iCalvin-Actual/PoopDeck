//
//  BabyLog_EventStoreActions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

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
    
    // MARK: - Set Group
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

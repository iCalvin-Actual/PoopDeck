//
//  Models.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

enum BabyError: Error {
    case unknown
}

struct ActivitySummary {
    var feedings: [FeedEvent] = []
    var diaperChanges: [DiaperEvent] = []
    var naps: [NapEvent] = []
    var fussies: [FussEvent] = []
    var weighIns: [WeightEvent] = []
    var tummyTimes: [TummyTimeEvent] = []
    var customEvents: [CustomEvent] = []
}

protocol BabyEvent: Identifiable, Codable, Equatable {
    static var type: BabyEventType { get }
    static var new: Self { get }

    var id: UUID { get set }
    var date: Date { get set }
    var viewModel: FeedViewModel { get }
}

//protocol Event: Identifiable, Codable, Equatable {
//    static var type: BabyEventType { get }
//    
//    var id: UUID { get set }
//    var date: Date { get set }
//}
//
//extension Event {
//    var type: BabyEventType { return Self.type }
//}
//
//struct TrackedEvent: Event {
//    static let type: BabyEventType = .diaper
//}
//
//struct MeasureEvent: Event {
//    static let type: BabyEventType = .feed
//    static var new: MeasureEvent {
//        /// Remove this
//        return MeasureEvent(type: .feed)
//    }
//    
//    var id: UUID = .init()
//    var date: Date = .init()
//    
//    var viewModel: FeedViewModel {
//        return FeedViewModel(id: self.id, date: self.date, type: self.type, primaryText: "", secondaryText: "", infoStack: [])
//    }
//}

protocol MeasuredBabyEvent: BabyEvent {
    var measurementValue: Double? { get set }
    var measurementUnit: String? { get set }
    var measurement: Measurement<Unit>? { get set }
}

extension MeasuredBabyEvent {
    var measurement: Measurement<Unit>? {
        get {
            guard let unitSymbol = measurementUnit, let value = measurementValue else { return nil }
            return Measurement(value: value, unit: Unit(symbol: unitSymbol))
        }
        set {
            self.measurementValue = newValue?.value
            self.measurementUnit = newValue?.unit.symbol
        }
    }
}

enum BabyEventType: String, Equatable, Codable, CaseIterable {
    case feed
    case diaper
    case nap
    case fuss
    case weight
    case tummyTime
    case custom
}

extension ActivitySummary: Codable { }
extension ActivitySummary {
    var dateSortedModels: [FeedViewModel] {
        var models: [FeedViewModel] = []
        
        models.append(contentsOf: self.feedings.map({ $0.viewModel }))
        models.append(contentsOf: self.diaperChanges.map({ $0.viewModel }))
        models.append(contentsOf: self.naps.map({ $0.viewModel }))
        models.append(contentsOf: self.fussies.map({ $0.viewModel }))
        models.append(contentsOf: self.weighIns.map({ $0.viewModel }))
        models.append(contentsOf: self.tummyTimes.map({ $0.viewModel }))
        models.append(contentsOf: self.customEvents.map({ $0.viewModel }))
        
        models.sort(by: { $0.date > $1.date })
        
        return models
    }
}

extension JSONDecoder {
    static var safe: JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return decoder
    }()
}

extension JSONEncoder {
    static var safe: JSONEncoder = {
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return encoder
    }()
}

extension BabyEventType {
    var path: String {
        switch self {
        case .feed:
            return "feed"
        case .diaper:
            return "diaper"
        case .nap:
            return "nap"
        case .fuss:
            return "fuss"
        case .weight:
            return "weight"
        case .tummyTime:
            return "tummy"
        case .custom:
            return "custom"
        }
    }
}

class EventManager {
    static let shared: EventManager = .init()
    
    var summary: ActivitySummary = .init()
    
    init() {
        self.fetchSummary()
    }
    
    func fetchSummary(_ completion: ((ActivitySummary?) -> Void)? = nil) {
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let summary = try JSONDecoder.safe.decode(ActivitySummary.self, from: data)
                self.summary = summary
                completion?(summary)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func duplicate<E: BabyEvent>(_ event: E, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        var newEvent = event
        newEvent.date = Date()
        newEvent.id = UUID()
        self.save(newEvent, completion: completion)
    }
    
    func duplicate(_ id: UUID, type: BabyEventType, completion: (() -> Void)? = nil) {
        switch type {
        case .feed:
            self.fetchFeedEvent(id, completion: { feed in
                var newFeedEvent = feed ?? FeedEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
        case .diaper:
            self.fetchDiaperEvent(id, completion: { feed in
                var newFeedEvent = feed ?? DiaperEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
        case .nap:
            self.fetchNapEvent(id, completion: { feed in
                var newFeedEvent = feed ?? NapEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
        case .fuss:
            self.fetchFussEvent(id, completion: { feed in
                var newFeedEvent = feed ?? FussEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
        case .weight:
            self.fetchWeightEvent(id, completion: { feed in
                var newFeedEvent = feed ?? WeightEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
            
        case .tummyTime:
            self.fetchTummyTimeEvent(id, completion: { feed in
                var newFeedEvent = feed ?? TummyTimeEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
            
        case .custom:
            self.fetchCustomEvent(id, completion: { feed in
                var newFeedEvent = feed ?? CustomEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.save(newFeedEvent) { _ in
                    completion?()
                }
            })
            
        }
    }
    
    func save<E: BabyEvent>(_ event: E, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        self.find(event.id) { (foundEvent: E?) in
            if foundEvent == nil {
                self.create(event: event, completion: completion)
            } else {
                self.update(event: event, completion: completion)
            }
        }
    }
    
    func create<E: BabyEvent>(event: E, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        var request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events/\(E.type.path)/"))
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(.failure(.unknown))
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(E.self, from: data)
                completion?(.success(event))
            } catch {
                print(error.localizedDescription)
                completion?(.failure(.unknown))
            }
        }.resume()
    }
    
    func update<E: BabyEvent>(event: E, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        var request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events/\(E.type.path)"))
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
        guard let data = data else {
            completion?(.failure(.unknown))
            return
        }
        do {
            let event = try JSONDecoder.safe.decode(E.self, from: data)
            completion?(.success(event))
        } catch {
            completion?(.failure(.unknown))
        }
        }.resume()
    }
    
    func fetch<E: BabyEvent>(_ id: UUID, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        self.find(id) { (foundEvent: E?) in
            if let foundEvent = foundEvent { completion?(.success(foundEvent)) }
            
            var path: String = ""
            if FeedEvent.new is E {
                path = "feed"
            } else if DiaperEvent.new is E {
                path = "diaper"
            } else if FussEvent.new is E {
                path = "fuss"
            } else if WeightEvent.new is E {
                path = "weight"
            } else if NapEvent.new is E {
                path = "nap"
            } else if TummyTimeEvent.new is E {
                path = "tummy"
            } else if CustomEvent.new is E {
                path = "custom"
            }

            var request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events/\(path)"))
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { (data, resonse, error) in
                guard let data = data else {
                    completion?(.failure(.unknown))
                    return
                }
                do {
                    let event = try JSONDecoder.safe.decode(E.self, from: data)
                    completion?(.success(event))
                } catch {
                    print(error.localizedDescription)
                    completion?(.failure(.unknown))
                }
            }.resume()
        }
    }
    
    func find<E: BabyEvent>(_ id: UUID, completion: ((E?) -> Void)? = nil) {
        if let feeding = self.summary.feedings.first(where: { $0.id == id }) as? E {        completion?(feeding)    }
        if let nap = self.summary.naps.first(where: { $0.id == id }) as? E {                completion?(nap)        }
        if let weight = self.summary.weighIns.first(where: { $0.id == id }) as? E {         completion?(weight)     }
        if let custom = self.summary.customEvents.first(where: { $0.id == id }) as? E {     completion?(custom)     }
        if let diaper = self.summary.diaperChanges.first(where: { $0.id == id }) as? E {    completion?(diaper)     }
        if let fuss = self.summary.fussies.first(where: { $0.id == id }) as? E {            completion?(fuss)       }
        if let tummy = self.summary.tummyTimes.first(where: { $0.id == id }) as? E {        completion?(tummy)      }
        
        completion?(nil)
    }
    
    func delete<E: BabyEvent>(_ event: E, completion: ((E?) -> Void)? = nil) {
        var request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events/\(E.type.path)"))
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
        guard let data = data else {
            completion?(nil)
            return
        }
        do {
            let event = try JSONDecoder.safe.decode(E.self, from: data)
            completion?(event)
        } catch {
            print(error.localizedDescription)
            completion?(nil)
        }
        }.resume()
    }
    func delete(_ id: UUID, type: BabyEventType, completion: (() -> Void)? = nil) {
        var request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events/\(type.path)/\(id.uuidString)"))
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            completion?()
        }.resume()
    }
    
    func fetchFeedEvent(_ id: UUID, completion: ((FeedEvent?) -> Void)? = nil) {
        if let feeding = self.summary.feedings.first(where: { $0.id == id }) {
            completion?(feeding)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("events/feed/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(FeedEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func fetch<E: BabyEvent>(id: UUID, type: BabyEventType, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        print("")
        if FeedEvent.new is E, let first = self.summary.feedings.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        } else if DiaperEvent.new is E, let first = self.summary.diaperChanges.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        } else if FussEvent.new is E, let first = self.summary.fussies.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        } else if WeightEvent.new is E, let first = self.summary.weighIns.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        } else if NapEvent.new is E, let first = self.summary.naps.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        } else if TummyTimeEvent.new is E, let first = self.summary.tummyTimes.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        } else if CustomEvent.new is E, let first = self.summary.customEvents.first(where: { $0.id == id }) as? E {
            completion?(.success(first))
            return
        }
        
        var request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/events/\(type.path)/\(id.uuidString)"))
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(.failure(.unknown))
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(E.self, from: data)
                completion?(.success(event))
            } catch {
                completion?(.failure(.unknown))
            }
        }.resume()
    }
    
    func fetchDiaperEvent(_ id: UUID, completion: ((DiaperEvent?) -> Void)? = nil) {
        if let event = self.summary.diaperChanges.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/event/diaper/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(DiaperEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func fetchNapEvent(_ id: UUID, completion: ((NapEvent?) -> Void)? = nil) {
        if let event = self.summary.naps.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/event/nap/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(NapEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func fetchFussEvent(_ id: UUID, completion: ((FussEvent?) -> Void)? = nil) {
        if let event = self.summary.fussies.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/event/fuss/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(FussEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func fetchWeightEvent(_ id: UUID, completion: ((WeightEvent?) -> Void)? = nil) {
        if let event = self.summary.weighIns.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/event/weight/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(WeightEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func fetchTummyTimeEvent(_ id: UUID, completion: ((TummyTimeEvent?) -> Void)? = nil) {
        if let event = self.summary.tummyTimes.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/event/tummyTime/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(TummyTimeEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
    
    func fetchCustomEvent(_ id: UUID, completion: ((CustomEvent?) -> Void)? = nil) {
        if let event = self.summary.customEvents.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL.BabyServerBase.appendingPathComponent("/event/custom/\(id.uuidString)"))
        URLSession.shared.dataTask(with: request) { (data, resonse, error) in
            guard let data = data else {
                completion?(nil)
                return
            }
            do {
                let event = try JSONDecoder.safe.decode(CustomEvent.self, from: data)
                completion?(event)
            } catch {
                print(error.localizedDescription)
                completion?(nil)
            }
        }.resume()
    }
}

typealias BreastSide = FeedEvent.Source.BreastSide

struct FeedEvent: MeasuredBabyEvent {
    static var type: BabyEventType { return FeedEvent.new.type }
    var type: BabyEventType = .feed
    static var new: FeedEvent {
        return FeedEvent(source: .breast(.both))
    }
    
    var measurement: Measurement<UnitVolume>? {
        return self.size
    }
    
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return self.source.title }
    var secondaryText: String { return self.size != nil ? MeasurementFormatter.weightFormatter.string(from: self.size!) : "" }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: FeedEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    
    enum Source: Equatable, Codable {
        case breast(_ side: BreastSide)
        case bottle

        enum CodingKeys: String, CodingKey {
            case source
            case breastSide
        }
        
        enum SourceType: String, Codable, CaseIterable {
            case breast
            case bottle
        }
        
        enum BreastSide: String, Equatable, Codable, CaseIterable {
            case left
            case right
            case both
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try container.decode(SourceType.self, forKey: .source)
            
            switch type {
            case .breast:
                let side = try container.decode(BreastSide.self, forKey: .breastSide)
                self = .breast(side)
            case .bottle:
                self = .bottle
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .breast(let side):
                try container.encode(SourceType.breast, forKey: .source)
                try container.encode(side, forKey: .breastSide)
            case .bottle:
                try container.encode(SourceType.bottle, forKey: .source)
            }
        }
        
        var title: String {
            switch self {
            case .bottle:
                return "Bottle feeding"
            case .breast:
                return "Breast feeding"
            }
        }
    }
    
    var source: Source
    var size: Measurement<UnitVolume>?
    var measurementUnit: String? {
        get {
            return size?.unit.symbol
        }
        set {
            guard let newSymbol = newValue, let newUnit = Unit(symbol: newSymbol) as? UnitVolume else { return }
            self.size = self.size?.converted(to: newUnit)
        }
    }
    var measurementValue: Double? {
        get {
           return size?.value
        }
        set {
            guard let newValue = newValue else {
                self.size = nil
                return
            }
            self.size?.value = newValue
        }
    }
}

struct DiaperEvent: BabyEvent {
    static var type: BabyEventType { return DiaperEvent.new.type }
    var type: BabyEventType = .diaper
    static var new: DiaperEvent {
        return DiaperEvent()
    }
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return "Fresh Diaper" }
    var secondaryText: String { return emojiStatus }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: DiaperEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    var emojiStatus: String {
        var ret: String = ""
        if pee {
            ret.append(contentsOf: "💦")
        }
        if poop {
            ret.append(contentsOf: "💩")
        }
        return ret
    }
    
    var pee: Bool = false
    var poop: Bool = false
    var measurement: Measurement<Unit>? = nil
}

struct NapEvent: MeasuredBabyEvent {
    static var type: BabyEventType { return NapEvent.new.type }
    var type: BabyEventType = .nap
    static var new: NapEvent {
        return NapEvent()
    }
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return "Nap Time" }
    var secondaryText: String { return DateComponentsFormatter.durationDisplay.string(from: duration) ?? "" }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: NapEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    
    var duration: TimeInterval = 3600
    
    var held: Bool = false
    var interruptions: Int = 0
    var measurementUnit: String? {
        get {
            return UnitDuration.minutes.symbol
        }
        set {
            // Do nothing
        }
    }
    var measurementValue: Double?
    var measurement: Measurement<UnitDuration>? {
        get {
            return Measurement(value: duration, unit: UnitDuration.seconds).converted(to: .minutes)
        }
        set {
            let seconds = newValue?.converted(to: .seconds).value ?? UnitDuration.seconds.defaultValue ?? 0
            self.duration = seconds
        }
    }
}

struct FussEvent: MeasuredBabyEvent {
    static var type: BabyEventType { return FussEvent.new.type }
    var type: BabyEventType = .fuss
    static var new: FussEvent {
        return FussEvent()
    }
    
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return "Fussy Times" }
    var secondaryText: String { return DateComponentsFormatter.durationDisplay.string(from: duration) ?? "" }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: FussEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    
    var duration: TimeInterval = 300
    var measurementUnit: String? {
        get {
            return UnitDuration.minutes.symbol
        }
        set {
            // Do nothing
        }
    }
    var measurementValue: Double? {
        get {
            return duration
        }
        set {
            duration = newValue ?? 0
        }
    }
    var measurement: Measurement<UnitDuration>? {
        get {
            return Measurement(value: duration, unit: UnitDuration.seconds).converted(to: .minutes)
        }
        set {
            let seconds = newValue?.converted(to: .seconds).value ?? UnitDuration.seconds.defaultValue ?? 0
            self.duration = seconds
        }
    }
}

struct TummyTimeEvent: MeasuredBabyEvent {
    static var type: BabyEventType { return TummyTimeEvent.new.type }
    var type: BabyEventType = .tummyTime
    static var new: TummyTimeEvent {
        return TummyTimeEvent()
    }
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return "Tummy Time" }
    var secondaryText: String { return DateComponentsFormatter.durationDisplay.string(from: duration) ?? "" }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: TummyTimeEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    
    var duration: TimeInterval = 300
    var measurementUnit: String? {
        get {
            return UnitDuration.minutes.symbol
        }
        set {
            // Do nothing
        }
    }
    var measurementValue: Double? {
        get {
            return duration
        }
        set {
            duration = newValue ?? 0
        }
    }
}

struct WeightEvent: MeasuredBabyEvent {
    static var type: BabyEventType { return WeightEvent.new.type }
    var type: BabyEventType = .weight
    static var new: WeightEvent {
        return WeightEvent(weight: Measurement.init(value: 4.20, unit: .kilograms))
    }
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return "Weight Check" }
    var secondaryText: String { return MeasurementFormatter.weightFormatter.string(from: self.weight) }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: WeightEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    
    
    var measurement: Measurement<UnitMass>? {
        get {
            return self.weight
        }
        set {
            guard let newWeight = newValue else { return }
            self.weight = newWeight
        }
    }
    
    var weight: Measurement<UnitMass>
    var measurementUnit: String? {
        get {
            return weight.unit.symbol
        }
        set {
            guard let newSymbol = newValue, let newUnit = Unit(symbol: newSymbol) as? UnitMass else { return }
            self.weight = self.weight.converted(to: newUnit)
        }
    }
    var measurementValue: Double? {
        get {
           return weight.value
        }
        set {
            guard let newValue = newValue else {
                return
            }
            self.weight.value = newValue
        }
    }
}

struct CustomEvent: BabyEvent {
    static var type: BabyEventType { return CustomEvent.new.type }
    var type: BabyEventType = .custom
    static var new: CustomEvent {
        return CustomEvent(event: "")
    }
    var id = UUID()
    var date: Date = Date()
    var icon: Data? { return nil }
    var primaryText: String { return event }
    var secondaryText: String { return "" }
    var infoStack: [String] { return [] }
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: CustomEvent.type,
            icon: self.icon,
            primaryText: self.primaryText,
            secondaryText: self.secondaryText,
            infoStack: []
        )
    }
    
    var event: String
//    var description: String
    
//    var measurement: Measurement<Unit>? = nil
}

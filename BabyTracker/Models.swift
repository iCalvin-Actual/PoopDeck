//
//  Models.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

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
    var id: UUID { get }
    var date: Date { get }
    var type: BabyEventType { get }
    var viewModel: FeedViewModel { get }
}

enum BabyEventType: String, Equatable, Codable {
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
        
        models.sort(by: { $0.date < $1.date })
        
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

class EventManager {
    static let shared: EventManager = .init()
    
    var summary: ActivitySummary = .init()
    
    init() {
        self.fetchSummary()
    }
    
    func fetchSummary(_ completion: ((ActivitySummary?) -> Void)? = nil) {
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events")!)
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
    
    func fetchFeedEvent(_ id: UUID, completion: ((FeedEvent?) -> Void)? = nil) {
        if let feeding = self.summary.feedings.first(where: { $0.id == id }) {
            completion?(feeding)
            return
        }
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/feed/\(id.uuidString)")!)
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
    
    func fetchDiaperEvent(_ id: UUID, completion: ((DiaperEvent?) -> Void)? = nil) {
        if let event = self.summary.diaperChanges.first(where: { $0.id == id }) {
            completion?(event)
            return
        }
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/diaper/\(id.uuidString)")!)
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
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/nap/\(id.uuidString)")!)
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
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/fuss/\(id.uuidString)")!)
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
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/weight/\(id.uuidString)")!)
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
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/feed/\(id.uuidString)")!)
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
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/feed/\(id.uuidString)")!)
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

struct FeedEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .feed
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: self.source.title,
            secondaryText: self.size != nil ? MeasurementFormatter.weightFormatter.string(from: self.size!) : "",
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
}

struct DiaperEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .diaper
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: "Fresh Diaper",
            secondaryText: emojiStatus,
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
}

struct NapEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .nap
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: "Nap Time",
            secondaryText: DateComponentsFormatter.durationDisplay.string(from: duration) ?? "",
            infoStack: []
        )
    }
    
    var duration: TimeInterval = 300
    
    var held: Bool = false
    var interruptions: Int = 0
    
}

struct FussEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .fuss
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: "Fussy Times",
            secondaryText: DateComponentsFormatter.durationDisplay.string(from: duration) ?? "",
            infoStack: []
        )
    }
    
    var duration: TimeInterval = 300
}

struct TummyTimeEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .tummyTime
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: "Tummy Time",
            secondaryText: DateComponentsFormatter.durationDisplay.string(from: duration) ?? "",
            infoStack: []
        )
    }
    
    var duration: TimeInterval = 300
}

struct WeightEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .weight
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: "Weight Check",
            secondaryText: MeasurementFormatter.weightFormatter.string(from: self.weight),
            infoStack: []
        )
    }
    
    var weight: Measurement<UnitMass>
    var clothed: Bool = false
}

struct CustomEvent: BabyEvent {
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .nap
    var viewModel: FeedViewModel {
        return FeedViewModel(
            id: self.id,
            date: self.date,
            type: self.type,
            icon: nil,
            primaryText: event,
            secondaryText: "",
            infoStack: []
        )
    }
    
    var event: String
}

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
    var id: UUID { get }
    var date: Date { get }
    var type: BabyEventType { get }
    var viewModel: FeedViewModel { get }
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

extension JSONEncoder {
    static var safe: JSONEncoder = {
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return encoder
    }()
}

extension URL {
    static var Base: URL {
        return URL(string: "http://192.168.7.39:8080")!
    }
}

extension BabyEventType {
    var path: String {
        switch self {
        case .feed:
            return "feed"
        case .diaper:
            return "feed"
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
    
    func duplicate(_ id: UUID, type: BabyEventType, completion: (() -> Void)? = nil) {
        switch type {
        case .feed:
            self.fetchFeedEvent(id, completion: { feed in
                var newFeedEvent = feed ?? FeedEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addFeedEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
        case .diaper:
            self.fetchDiaperEvent(id, completion: { feed in
                var newFeedEvent = feed ?? DiaperEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addDiaperEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
        case .nap:
            self.fetchNapEvent(id, completion: { feed in
                var newFeedEvent = feed ?? NapEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addNapEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
        case .fuss:
            self.fetchFussEvent(id, completion: { feed in
                var newFeedEvent = feed ?? FussEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addFussEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
        case .weight:
            self.fetchWeightEvent(id, completion: { feed in
                var newFeedEvent = feed ?? WeightEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addWeightEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
            
        case .tummyTime:
            self.fetchTummyTimeEvent(id, completion: { feed in
                var newFeedEvent = feed ?? TummyTimeEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addTummyTimeEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
            
        case .custom:
            self.fetchCustomEvent(id, completion: { feed in
                var newFeedEvent = feed ?? CustomEvent.new
                newFeedEvent.date = Date()
                newFeedEvent.id = UUID()
                self.addCustomEvent(newFeedEvent, completion: { _ in
                    completion?()
                })
            })
            
        }
    }
    
    func delete<E: BabyEvent>(_ event: E, completion: ((E?) -> Void)? = nil) {
        var request = URLRequest(url: URL.Base.appendingPathComponent("/events/\(event.type.path)"))
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
        var request = URLRequest(url: URL.Base.appendingPathComponent("/events/\(type.path)/\(id.uuidString)"))
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
    
    func fetch<E: BabyEvent>(id: UUID, type: BabyEventType, completion: ((Result<E, BabyError>) -> Void)? = nil) {
        /// Check local cache
        let request = URLRequest(url: URL(string: "http://192.168.7.39:8080/event/\(type.path)/\(id.uuidString)")!)
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
    
    func addFeedEvent(_ event: FeedEvent, completion: ((FeedEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/feed/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateFeedEvent(_ event: FeedEvent, completion: ((FeedEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/feed/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func addDiaperEvent(_ event: DiaperEvent, completion: ((DiaperEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/diaper/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateDiaperEvent(_ event: DiaperEvent, completion: ((DiaperEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/diaper/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func addNapEvent(_ event: NapEvent, completion: ((NapEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/nap/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateNapEvent(_ event: NapEvent, completion: ((NapEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/feed/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func addFussEvent(_ event: FussEvent, completion: ((FussEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/fuss/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateFussEvent(_ event: FussEvent, completion: ((FussEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/fuss/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func addWeightEvent(_ event: WeightEvent, completion: ((WeightEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/weight/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateWeightEvent(_ event: WeightEvent, completion: ((WeightEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/weight/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func addTummyTimeEvent(_ event: TummyTimeEvent, completion: ((TummyTimeEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/tummy/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateTummyTimeEvent(_ event: TummyTimeEvent, completion: ((TummyTimeEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/tummy/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func addCustomEvent(_ event: CustomEvent, completion: ((CustomEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/custom/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    
    func updateCustomEvent(_ event: CustomEvent, completion: ((CustomEvent?) -> Void)? = nil) {
        var request = URLRequest(url: URL(string: "http://192.168.7.39:8080/events/custom/")!)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder.safe.encode(event)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    static var new: FeedEvent {
        return FeedEvent(source: .breast(.both))
    }
    
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
    static var new: DiaperEvent {
        return DiaperEvent()
    }
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
    static var new: NapEvent {
        return NapEvent()
    }
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
    static var new: FussEvent {
        return FussEvent()
    }
    
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
    static var new: TummyTimeEvent {
        return TummyTimeEvent()
    }
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
    static var new: WeightEvent {
        return WeightEvent(weight: Measurement.init(value: 0, unit: .kilograms))
    }
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
    static var new: CustomEvent {
        return CustomEvent(event: "")
    }
    var id = UUID()
    var date: Date = Date()
    var type: BabyEventType = .custom
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
    var details: String = ""
}

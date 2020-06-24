//
//  IntentHandler.swift
//  IntentExtension
//
//  Created by Calvin Chestnut on 6/10/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Intents

class IntentHandler: INExtension, LastDiaperIntentHandling {
    
    private var groupDefaults: UserDefaults = UserDefaults(suiteName: "group.com.chestnut.BabyTracker") ?? .standard
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    func handle(intent: LastDiaperIntent, completion: @escaping (LastDiaperIntentResponse) -> Void) {
        guard let recentURLData = self.groupDefaults.object(forKey: "RecentURLBookmarks") as? Data else {
            /// Fatal for visibility
            fatalError()
        }
        do {
            let bookmarkMap: [Data] = try JSONDecoder().decode([Data].self, from: recentURLData)

            var retrievedURLs: [URL] = []
            bookmarkMap.forEach { (data: Data) in
                do {
                    var isStale = false
                    let url = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
                    retrievedURLs.append(url)
                } catch {
                    print("STOP")
                }
            }
            guard let doc = retrievedURLs.first.map({ BabyLog(fileURL: $0) }) else { return }
            doc.open { (success) in
                print("OPENED: \(success)")
                completion(.success(eventDate: Calendar.current.dateComponents([.hour, .minute], from: Date())))
            }
        } catch {
            print("Error decoding")
        }
        
    }
    
    func resolveDiaperState(for intent: LastDiaperIntent, with completion: @escaping (DiaperTypeResolutionResult) -> Void) {
        completion(.success(with: intent.diaperState))
    }
    
//    func resolveBabylog(for intent: LastDiaperIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
//        guard let file = intent.babylog else {
//            fatalError()
//        }
//        completion(.success(with: file))
//    }
    
    
    
}

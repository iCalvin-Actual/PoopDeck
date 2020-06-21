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

class BabyLog: UIDocument {
    
    @Published
    public var baby: Baby = .init() {
        willSet {
            guard !baby.name.isEmpty else { return }
            let oldValue = self.baby
            /// Record undoManager state changes from this top level
            undoManager.registerUndo(withTarget: self) { $0.baby = oldValue }
        }
    }
    
    /// Holds onto all events within dictionaries
    @Published
    var eventStore: BabyEventStore = .init() {
        willSet {
            let oldValue = eventStore
            /// Record undoManager state changes from this top level
            undoManager?.registerUndo(withTarget: self) { $0.eventStore = oldValue }
        }
    }
    
    // MARK: - File I/O
    override func contents(forType typeName: String) throws -> Any {
        /// Rather than encoding to Archive, should use a FileWrapper and multiple files. Eventually I may start storing media in here so need to get organized
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
            // When making changes to the BabyEvent Data Models (or the archive) make sure to add a catch here that tries casting to a new struct with a matching signature to the old events.
            // Basically migrate
            throw BabyError.unknown
        }
    }
    
    /// Have had issues with deleting items before. If they stay open in the app they become impossible to close or update. Added a force close option, but need to revisit this
    override func presentedItemDidMove(to newURL: URL) {
        /// Make sure this is tracked?
        if newURL.pathComponents.contains(".Trash") {
            /// Alert and close document
            self.close { (closed) in
                
            }
        }
        super.presentedItemDidMove(to: newURL)
    }
}

extension BabyLog: Identifiable { }
extension BabyLog: ObservableObject { }

struct BabyLog_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

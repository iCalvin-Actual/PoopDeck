//
//  DocumentView.swift
//  DocBasedBabyTracker
//
//  Created by Calvin Chestnut on 6/1/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

struct BabyLogsView: View {
    var logs: [BabyLog] {
        didSet {
            if self.selectedLog == nil { self.selectedLog = logs.first }
        }
    }
    
    @State var selectedLog: BabyLog?
    
    var body: some View {
        VStack {
            HStack {
                ForEach(logs) { log in
                    Text(log.baby.displayName)
                        .onTapGesture {
                            self.selectedLog = log
                        }
                }
            }
            self.babyLogOrEmpty()
        }.onAppear {
            if self.selectedLog == nil { self.selectedLog = self.logs.first }
        }
    }
    
    func babyLogOrEmpty() -> AnyView {
        guard let log = self.selectedLog else {
            return EmptyView().anyify()
        }
        return BabyLogView(document: log) {
            log.save(to: log.fileURL, for: .forOverwriting) { (success) in
                print("Saved")
            }
        }.anyify()
    }
}

struct BabyLogView: View {
    @Environment(\.undoManager) var undoManager
    
    @ObservedObject var document: BabyLog {
        didSet {
            document.save(to: document.fileURL, for: .forOverwriting) { saved in
                print("Handle errors")
            }
        }
    }
    var dismiss: () -> Void

    var body: some View {
        FeedView(recordManager: document.recordManager)
        .onReceive(NotificationCenter.default.publisher(for: UIDocument.stateChangedNotification, object: document), perform: self.handleStateChange)
    }
    
    func handleStateChange(_ notification: Notification) {
        switch document.documentState {
        case .editingDisabled:
            print("Disable editing")
        case .inConflict:
            print("Resolve conflict")
        case .savingError:
            print("Error saving")
        default:
            print("Do nothing?")
        }
    }
}

struct BabySelectionButton: View {
    let baby: Baby
    let action: (() -> Void) = { }
    
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            VStack {
                Circle()
                    .foregroundColor(baby.preferredColor)
                
                Text(baby.displayInitial)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        })
    }
}

struct BabyLogView_Previews: PreviewProvider {
    static var baby: Baby {
        let baby: Baby = .new
        baby.name = "Sophia"
        return baby
    }
    static var previews: some View {
        BabySelectionButton(baby: baby)
    }
}

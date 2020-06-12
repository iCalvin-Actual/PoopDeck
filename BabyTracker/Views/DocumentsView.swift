//
//  DocumentsView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Document Actions
enum DocumentAction {
    case createNew
    case show(_ log: BabyLog)
    case save(_ log: BabyLog)
    case close(_ log: BabyLog)
    case delete(_ log: BabyLog)
    case resolve(_ log: BabyLog)
}

// MARK: - Documents View
struct DocumentsView: View {
    @State var logs: [BabyLog] = []
    @State var selected: BabyLog?
    
    var onAction: ((DocumentAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack {
            BabyPickerView(
                babies: logs.map({ $0.baby }),
                onAction: onBabyAction)
    
            Divider()
            
            selectedLogView()
            
        }
        .onAppear {
            if self.selected == nil, let first = self.logs.first {
                self.selected = first
            }
        }
    }
    
    func selectedLogView() -> AnyView {
        if let selected = self.selected {
            return LogView(
                log: selected,
                onAction: self.onAction)
            .anyPlease()
        }
        return EmptyView().anyPlease()
    }
}

// MARK: - Baby Action Handler
extension DocumentsView {
    func onBabyAction(_ babyAction: BabyAction) {
        switch babyAction {
        case .show(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.show(actionDoc))
        case .select(let baby):
            guard let baby = baby else {
                self.onAction?(.createNew)
                return
            }
            self.selected = self.log(for: baby)
        case .save(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.save(actionDoc))
        case .close(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.close(actionDoc))
        case .delete(let baby):
            guard let actionDoc = self.log(for: baby) else { return }
            self.onAction?(.delete(actionDoc))
        }
    }
    
    func log(for baby: Baby) -> BabyLog? {
        return logs.first(where: { $0.baby == baby })
    }
}

// MARK: - Preview
struct BabyIconView_Preview: PreviewProvider {
    static var babyLog: BabyLog {
        let log = BabyLog(fileURL: Bundle.main.url(forResource: "MyBabyLog", withExtension: "bblg")!)
        log.baby = baby
        return log
    }
    static var baby: Baby {
        let baby = Baby()
        baby.name = "Sophia"
        baby.emoji = "👶"
        var components = DateComponents()
        components.month = 3
        components.day = 14
        components.year = 2020
        components.calendar = .current
        if let date = components.date {
            baby.birthday = date
        }
        baby.themeColor = PreferredColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        DocumentsView(logs: [babyLog])
    }
}

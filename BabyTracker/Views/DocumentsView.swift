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
    case showDocuments
    case show(_ log: BabyLog)
    case save(_ log: BabyLog)
    case close(_ log: BabyLog)
    case delete(_ log: BabyLog)
    case resolve(_ log: BabyLog)
    case updateColor(_ baby: BabyLog, newColor: ThemeColor)
    case forceClose
}

// MARK: - Documents View
struct DocumentsView: View {
    @State var logs: [BabyLog] = []
    @State var selected: BabyLog?
    
    var onAction: ((DocumentAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 4) {
            BabyPickerView(
                logs: logs,
                selected: selected ?? .dummy,
                onAction: onBabyAction)
            
            logOrNewWindowView()
        }
    }
    
    func logOrNewWindowView() -> AnyView {
        guard let selected = selected else {
            return NewWindowView(openDocument: { self.onAction?(.showDocuments) }).anyPlease()
        }
        return LogView(
            log: selected,
            onAction: onAction)
            .background(Color(.systemGroupedBackground))
            .padding(.top, 0)
            .anyPlease()
    }
}

// MARK: - Baby Action Handler
extension DocumentsView {
    func onBabyAction(_ logPickerAction: LogPickerAction) {
        switch logPickerAction {
        case .show(let log):
            self.onAction?(.show(log))
        case .select(let log):
            guard let log = log else {
                self.onAction?(.showDocuments)
                return
            }
            self.selected = log
        case .save(let log):
            self.onAction?(.save(log))
        case .close(let log):
            self.onAction?(.close(log))
        case .delete(let log):
            self.onAction?(.delete(log))
        case .forceClose:
            self.onAction?(.forceClose)
        case .updateColor(let log, newColor: let newColor):
            self.onAction?(.updateColor(log, newColor: newColor))
        }
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
        baby.themeColor = ThemeColor.prebuiltSet.randomElement()!
        return baby
    }
    static var previews: some View {
        DocumentsView(logs: [babyLog], selected: babyLog)
    }
}

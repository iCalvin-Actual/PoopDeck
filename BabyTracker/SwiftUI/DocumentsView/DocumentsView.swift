//
//  DocumentsView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Documents View
struct DocumentsView: View {
    @State var logs: [BabyLog] = []
    @State var selected: BabyLog?
    
    var onAction: ((DocumentAction) -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 4) {
            /// Shows open docs and allows new document creation or switching between docs
            BabyLogTabView(
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

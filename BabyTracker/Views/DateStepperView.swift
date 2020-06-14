//
//  DateStepperView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

// MARK: - Date Stepper
struct DateStepperView: View {
    @Binding var targetDate: ObservableDate
    var accentColor: Color?
    @State private var currentDate: Date = Date()
    @State var adjustmentComponents: DateComponents = .init(calendar: .current) {
       didSet {
           self.updateTargetDate()
       }
    }
    @State private var adjustingMonth: Bool = false
     
    private var calendar: Calendar { return .current }
    private let ticker: TickPublisher = .init()
    
    // MARK: - Views
    var body: some View {
        HStack(alignment: .center) {
            
            Button(action: {
                if self.adjustingMonth {
                    self.changeDate(DateComponents(calendar: self.calendar, month: -1))
                } else {
                    self.changeDate(DateComponents(calendar: self.calendar, day: -1))
                }
            }) {
                Image(systemName: "minus.circle")
                .raisedButtonPlease(nil, padding: 8)
            }
            .font(.system(size: 16, weight: .black))
            
            VStack(alignment: .trailing, spacing: 4) {
                
                Text(DateFormatter.shortDateDisplay.string(from: targetDate.date))
                    .fontWeight(.bold)
                    .contextMenu {
                        Button(action: {
                            self.adjustingMonth.toggle()
                        }) {
                            Image(systemName: "calendar")
                            Text(adjustingMonth ? "Adjust Day" : "Adjust Month")
                        }
                    }
                
                if dateIsModified() {
                    Button(action: {
                        self.adjustmentComponents = DateComponents()
                        self.adjustingMonth = false
                    }) {
                        Text(DateFormatter.shortDateDisplay.string(from: currentDate))
                            .font(.callout)
                            .fontWeight(.bold)
                    }
                    .accentColor(.primary)
                }
            }
            
            if dateIsModified() {
                
                Button(action: {
                    if self.adjustingMonth {
                        self.changeDate(DateComponents(calendar: self.calendar, month: 1))
                    } else {
                        self.changeDate(DateComponents(calendar: self.calendar, day: 1))
                    }
                }) {
                    Image(systemName: "plus.circle")
                    .raisedButtonPlease(nil, padding: 8)
                }
                .font(.system(size: 16, weight: .black))
                
            }
            
            Spacer()
        }
        .accentColor(accentColor)
        .font(.system(.title, design: .rounded))
        .padding(.horizontal, 4)
        .padding()
        .onReceive(ticker.currentTimePublisher) { newCurrentTime in
            self.currentDate = newCurrentTime
        }
    }
}

    // MARK: - Date Modifications
extension DateStepperView {
    func changeDate(_ components: DateComponents) {
        let newComponents = DateComponents(
            calendar: .current,
            month: (adjustmentComponents.month ?? 0) + (components.month ?? 0),
            day: (adjustmentComponents.day ?? 0) + (components.day ?? 0))
        adjustmentComponents = newComponents
    }
    func updateTargetDate() {
        targetDate = .init(self.calendar.date(byAdding: self.adjustmentComponents, to: Date()) ?? Date())
    }
    
    func dateIsModified() -> Bool {
        let dayAdjustment = adjustmentComponents.day ?? 0
        let monAdjustment = adjustmentComponents.month ?? 0
        let highestDiff = max(abs(dayAdjustment), abs(monAdjustment))
        return highestDiff != 0
    }
}

// MARK: - Previews
struct DateStepperView_Previews: PreviewProvider {
    static var previews: some View {
        DateStepperView(targetDate: .constant(.init()))
    }
}

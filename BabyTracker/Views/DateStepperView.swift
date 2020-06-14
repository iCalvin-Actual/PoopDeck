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
    @State private var currentDate: Date = Date()
    @State var adjustmentComponents: DateComponents = .init(calendar: .current) {
       didSet {
           self.updateTargetDate()
       }
   }
     
    private var calendar: Calendar { return .current }
    private let ticker: TickPublisher = .init()
    
    // MARK: - Views
    var body: some View {
        HStack {
            
            Button(action: {
                self.changeDate(DateComponents(calendar: self.calendar, day: -1))
            }) {
                Image(systemName: "arrowtriangle.left.circle.fill")
            }
            
            Text(DateFormatter.shortDateDisplay.string(from: targetDate.date))
                .fontWeight(.bold)
            
            if adjustmentComponents.day ?? 0 < 0 {
                
                Button(action: {
                    self.changeDate(DateComponents(calendar: self.calendar, day: 1))
                }) {
                    Image(systemName: "arrowtriangle.right.circle.fill")
                }
                
            }
            
            Spacer()
        }
        .font(.system(.title, design: .rounded))
        .padding(.horizontal)
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
            day: (adjustmentComponents.day ?? 0) + (components.day ?? 0))
        adjustmentComponents = newComponents
    }
    func updateTargetDate() {
        targetDate = .init(self.calendar.date(byAdding: self.adjustmentComponents, to: Date()) ?? Date())
    }
}

// MARK: - Previews
struct DateStepperView_Previews: PreviewProvider {
    static var previews: some View {
        DateStepperView(targetDate: .constant(.init()))
    }
}

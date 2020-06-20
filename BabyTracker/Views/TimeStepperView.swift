//
//  TimeStepperView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/15/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct TimeStepperView: View {
    @Binding var targetDate: ObservableDate {
        didSet {
            onValueChange?(targetDate)
        }
    }
    
    var onValueChange: ((ObservableDate) -> Void)?
    var accentColor: Color?
    @State private var currentDate: Date = Date()
    @State var adjustmentComponents: DateComponents = .init(calendar: .current) {
       didSet {
           self.updateTargetDate()
       }
    }
    
    @Binding var editing: Bool
    
     
    private var calendar: Calendar { return .current }
    private let ticker: TickPublisher = .init()
    
    var body: some View {
        HStack(alignment: .top) {
            // MARK: - Hour Column
            VStack {
                
                if editing {
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, hour: 1))
                    }) {
                        Image(systemName: "plus.circle")
                        .raisedButtonPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
                
                Text(DateFormatter.hourFormatter.string(from: targetDate.date))
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .onTapGesture(perform: {
                        withAnimation {
                            self.editing.toggle()
                        }
                    })
                
                if editing {
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, hour: -1))
                    }) {
                        Image(systemName: "minus.circle")
                        .raisedButtonPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
            }
            
            // MARK: - Colon Column
            
            VStack {
                if editing {
                    Spacer()
                }
                Text(":")
                .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                .onTapGesture(perform: {
                    withAnimation {
                        self.editing.toggle()
                    }
                })
                if editing {
                    Spacer()
                }
            }
            
            // MARK: - Minute Column
            VStack {
                
                if editing {
                    HStack {
                        Button(action: {
                            self.changeDate(DateComponents(calendar: .current, minute: 10))
                        }) {
                            Image(systemName: "plus.circle")
                            .raisedButtonPlease(nil, padding: 8)
                        }
                        
                        Button(action: {
                            self.changeDate(DateComponents(calendar: .current, minute: 1))
                        }) {
                            Image(systemName: "plus.circle")
                            .raisedButtonPlease(nil, padding: 8)
                        }
                    }
                    .font(.system(size: 16, weight: .black))
                }
                
                Text(DateFormatter.minuteFormatter.string(from: targetDate.date))
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .onTapGesture(perform: {
                        withAnimation {
                            self.editing.toggle()
                        }
                    })
                
                if editing {
                    HStack {
                        Button(action: {
                            self.changeDate(DateComponents(calendar: .current, minute: -10))
                        }) {
                            Image(systemName: "minus.circle")
                            .raisedButtonPlease(nil, padding: 8)
                        }
                        
                        Button(action: {
                            self.changeDate(DateComponents(calendar: .current, minute: -1))
                        }) {
                            Image(systemName: "minus.circle")
                            .raisedButtonPlease(nil, padding: 8)
                        }
                    }
                    .font(.system(size: 16, weight: .black))
                }
            }
            
            // MARK: - AMPM Column
            VStack {
                
                if editing {
                    Button(action: {
                        let currentHour = self.calendar.component(.hour, from: self.targetDate.date)
                        self.changeDate(DateComponents(calendar: self.calendar, hour: currentHour < 12 ? 12 : -12 ))
                    }) {
                        Image(systemName: "plus.circle")
                        .raisedButtonPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
                
                Text(DateFormatter.ampmFormatter.string(from: targetDate.date))
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .onTapGesture(perform: {
                        withAnimation {
                            self.editing.toggle()
                        }
                    })
                
                if editing {
                    Button(action: {
                        let currentHour = self.calendar.component(.hour, from: self.targetDate.date)
                        self.changeDate(DateComponents(calendar: self.calendar, hour: currentHour < 12 ? 12 : -12 ))
                    }) {
                        Image(systemName: "minus.circle")
                        .raisedButtonPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
            }
        }
        .onReceive(ticker.currentTimePublisher) { newCurrentTime in
            self.currentDate = newCurrentTime
        }
        .contextMenu {
            Button(action: {
                withAnimation {
                    self.adjustmentComponents = DateComponents()
                    self.targetDate = .init()
                }
            }) {
                Image(systemName: "clock")
                Text("Now")
            }
        }
    }
}

// MARK: - Date Modifications
extension TimeStepperView {
    func changeDate(_ components: DateComponents) {
        adjustmentComponents = components
    }
    func updateTargetDate() {
        targetDate = .init(self.calendar.date(byAdding: self.adjustmentComponents, to: targetDate.date) ?? Date())
    }
    
    func dateIsModified() -> Bool {
        let dayAdjustment = adjustmentComponents.day ?? 0
        let monAdjustment = adjustmentComponents.month ?? 0
        let highestDiff = max(abs(dayAdjustment), abs(monAdjustment))
        return highestDiff != 0
    }
}

struct TimeStepperView_Previews: PreviewProvider {
    static var previews: some View {
        TimeStepperView(targetDate: .constant(.init()), editing: .constant(false))
    }
}

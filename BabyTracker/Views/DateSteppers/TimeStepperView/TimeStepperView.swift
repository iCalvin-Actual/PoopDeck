//
//  TimeStepperView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/15/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

/// View which allows stepping between hours, minutes (by 10's or 1's), or AM/PM (by incrementing or decrementing by 12 hours)
struct TimeStepperView: View {
    /// Active editing date
    @Binding var targetDate: ObservableDate {
        didSet {
            onValueChange?(targetDate)
        }
    }
    
    /// Shouldn't be necessary with proper binding, but seems to be necessary
    var onValueChange: ((ObservableDate) -> Void)?
    
    /// Override color. I believe there should be an environment variable to override instead
    var accentColor: Color?
    
    /// The current date in time
    @State private var currentDate: Date = Date()
    /// Ticker to publish updates to the clock
    private let ticker: Ticker = .init()
    
    /// Date adjustment to apply to the target date
    @State var adjustmentComponents: DateComponents = .init(calendar: .current) {
       didSet {
           self.updateTargetDate()
       }
    }
    
    /// Hides stepper buttons
    @Binding var editing: Bool
    
    private let calendar: Calendar { return .current }
    
    var body: some View {
        HStack(alignment: .top) {
            // MARK: - Hour Column
            VStack {
                
                if editing {
                    /// Should make these a standard component and accept the action and color
                    Button(action: {
                        self.adjustmentComponents = DateComponents(calendar: self.calendar, hour: 1)
                    }) {
                        Image(systemName: "plus.circle")
                        .floatingPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
                
                Text(DateFormatter.hour.string(from: targetDate.date))
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .onTapGesture(perform: {
                        withAnimation {
                            self.editing.toggle()
                        }
                    })
                
                if editing {
                    Button(action: {
                        self.adjustmentComponents = DateComponents(calendar: self.calendar, hour: -1)
                    }) {
                        Image(systemName: "minus.circle")
                        .floatingPlease(nil, padding: 8)
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
                            self.adjustmentComponents = DateComponents(calendar: .current, minute: 10)
                        }) {
                            Image(systemName: "plus.circle")
                            .floatingPlease(nil, padding: 8)
                        }
                        
                        Button(action: {
                            self.adjustmentComponents = DateComponents(calendar: .current, minute: 1)
                        }) {
                            Image(systemName: "plus.circle")
                            .floatingPlease(nil, padding: 8)
                        }
                    }
                    .font(.system(size: 16, weight: .black))
                }
                
                Text(DateFormatter.minute.string(from: targetDate.date))
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .onTapGesture(perform: {
                        withAnimation {
                            self.editing.toggle()
                        }
                    })
                
                if editing {
                    HStack {
                        Button(action: {
                            self.adjustmentComponents = DateComponents(calendar: .current, minute: -10)
                        }) {
                            Image(systemName: "minus.circle")
                            .floatingPlease(nil, padding: 8)
                        }
                        
                        Button(action: {
                            self.adjustmentComponents = DateComponents(calendar: .current, minute: -1)
                        }) {
                            Image(systemName: "minus.circle")
                            .floatingPlease(nil, padding: 8)
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
                        self.adjustmentComponents = DateComponents(calendar: self.calendar, hour: currentHour < 12 ? 12 : -12 )
                    }) {
                        Image(systemName: "plus.circle")
                        .floatingPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
                
                Text(DateFormatter.ampm.string(from: targetDate.date))
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .onTapGesture(perform: {
                        withAnimation {
                            self.editing.toggle()
                        }
                    })
                
                if editing {
                    Button(action: {
                        let currentHour = self.calendar.component(.hour, from: self.targetDate.date)
                        self.adjustmentComponents = DateComponents(calendar: self.calendar, hour: currentHour < 12 ? 12 : -12 )
                    }) {
                        Image(systemName: "minus.circle")
                        .floatingPlease(nil, padding: 8)
                    }
                    .font(.system(size: 16, weight: .black))
                }
            }
        }
        /// Update a state component occasionally so the date adjustments (5 minutes in the future) stays updated
        .onReceive(ticker.currentTimePublisher) { newCurrentTime in
            self.currentDate = newCurrentTime
        }
        .contextMenu {
            
            /// Context button allows quick access to current time
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

struct TimeStepperView_Previews: PreviewProvider {
    static var previews: some View {
        TimeStepperView(targetDate: .constant(.init()), editing: .constant(false))
    }
}

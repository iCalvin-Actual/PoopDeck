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
    
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    
    @State private var currentDate: Date = Date() {
        didSet {
            self.updateTargetDate()
        }
    }
    @State private var components: DateComponents = .init() {
        didSet {
            self.updateTargetDate()
        }
    }
    
    private var calendar: Calendar { return .current }
    private let ticker: TickPublisher = .init()
    
    // MARK: - Views
    var body: some View {
        VStack(alignment: .leading) {
            
            /// Time Display
            HStack {
                Text(DateFormatter.shortDisplay.string(from: targetDate.date))
                
                Spacer()
                Button(action: {
                    withAnimation(.default, {
                        self.showDatePicker.toggle()
                    })
                }) {
                    Image(systemName: self.showDatePicker ? "calendar.circle" : "calendar.circle.fill")
                }
                Button(action: {
                    withAnimation(.default) {
                        self.showTimePicker.toggle()
                    }
                }) {
                    Image(systemName: self.showTimePicker ? "clock" : "clock.fill")
                }
            }
            
            if self.showDatePicker {
                dateEditorDisplay
            }
            
            if showTimePicker {
                timeEditorDisplay
            }
        }
        .padding(.horizontal)
        .padding(.horizontal)
        .padding(.bottom)
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
            day: (self.components.day ?? 0) + (components.day ?? 0),
            hour: (self.components.hour ?? 0) + (components.hour ?? 0),
            minute: (self.components.minute ?? 0) + (components.minute ?? 0))
        self.components = newComponents
    }
    
    func updateTargetDate() {
        self.targetDate = .init(self.calendar.date(byAdding: self.components, to: self.currentDate) ?? Date())
    }
}

extension DateStepperView {
    
    // MARK: - Active Time Display
    var activeTimeDisplay: some View {
        HStack {
            
            Text(DateFormatter.shortDisplay.string(from: targetDate.date))
            
            Spacer()
            
            Button(action: {
                withAnimation(.default, {
                    self.showDatePicker.toggle()
                })
            }) {
                Image(systemName: self.showDatePicker ? "calendar.circle" : "calendar.circle.fill")
            }
            
            Button(action: {
                withAnimation(.default) {
                    self.showTimePicker.toggle()
                }
            }) {
                Image(systemName: self.showTimePicker ? "clock" : "clock.fill")
            }
        }
    }
    
    // MARK: - Date Editor Display
    var dateEditorDisplay: some View {
        HStack {
            Text("Date")
            
            Spacer()
            
            Button(action: {
                self.changeDate(DateComponents(calendar: self.calendar, day: -1))
            }) {
                Image(systemName: "arrowtriangle.left.circle.fill")
            }
            
            Text(DateFormatter.shortDateDisplay.string(from: targetDate.date))
            
            Button(action: {
                self.changeDate(DateComponents(calendar: self.calendar, day: 1))
            }) {
                Image(systemName: "arrowtriangle.right.circle.fill")
            }
            
            Spacer()
        }
    }
    
    // MARK: - Time Editor Display
    var timeEditorDisplay: some View {
        HStack {
            Text("Time")
            
            Spacer()
            
            /// Hour editor
            VStack {
                Button(action: {
                    self.changeDate(DateComponents(calendar: self.calendar, hour: 1))
                }) {
                    Image(systemName: "arrowtriangle.up.circle.fill")
                }
                
                Text(DateFormatter.hourFormatter.string(from: self.targetDate.date))
                
                Button(action: {
                    self.changeDate(DateComponents(calendar: self.calendar, hour: -1))
                }) {
                    Image(systemName: "arrowtriangle.down.circle.fill")
                }
            }
            
            Text(":")
            
            VStack {
                HStack {
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, minute: 10))
                    }) {
                        Image(systemName: "arrowtriangle.up.circle.fill")
                    }
                    
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, minute: 1))
                    }) {
                        Image(systemName: "arrowtriangle.up.circle.fill")
                    }
                }
                
                Text(DateFormatter.minuteFormatter.string(from: targetDate.date))
                
                HStack {
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, minute: -10))
                    }) {
                        Image(systemName: "arrowtriangle.down.circle.fill")
                    }
                    
                    Button(action: {
                        self.changeDate(DateComponents(calendar: self.calendar, minute: -1))
                    }) {
                        Image(systemName: "arrowtriangle.down.circle.fill")
                    }
                }
            }
            
            VStack {
                Button(action: {
                    self.changeDate(DateComponents(calendar: self.calendar, hour: 12))
                }) {
                    Image(systemName: "arrowtriangle.up.circle.fill")
                }
                
                Text(DateFormatter.ampmFormatter.string(from: targetDate.date))
                
                    
                Button(action: {
                    self.changeDate(DateComponents(calendar: self.calendar, hour: -12))
                }) {
                    Image(systemName: "arrowtriangle.down.circle.fill")
                }
            }
            Spacer()
        }
    }
}

// MARK: - Formatting
extension DateStepperView {
}

// MARK: - Previews
struct DateStepperView_Previews: PreviewProvider {
    static var previews: some View {
        DateStepperView(targetDate: .constant(.init()))
    }
}

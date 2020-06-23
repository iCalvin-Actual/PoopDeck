//
//  MeasurementStepperView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/18/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct MeasurementStepperView: View {
    /// Active editing measurement
    @Binding var target: Measurement<Unit>? {
        didSet {
            onValueChange?(target)
        }
    }
    /// Initial value if current value is nil, value to reset to on clear
    var defaultValue: Measurement<Unit>
    
    /// This shouldn't be necessary proper Binding of the target, but seeme to be
    var onValueChange: ((Measurement<Unit>?) -> Void)?
    
    /// Hides stepper buttons
    @Binding var editing: Bool
    
    /// Amount to increase/decrease when tapping the stepper views.
    /// Computed var wants to return the target measurements default, but allows for an override
    private var increment: Double? {
        return overrideIncrement ?? target?.unit.modifier
    }
    var overrideIncrement: Double?
    
    // MARK: - Views
    var body: some View {
        HStack {
            if editing {
                leadingButton()
            }
            
            if target != nil {
                measurementText()
            } else {
                emptyMeasurementText()
            }
            
            if editing {
                trailingButton()
            }
        }
    }
    
    // MARK: - Texts
    private func measurementText() -> some View {
        Text(MeasurementFormatter.natural.string(from: target!))
            .font(.system(size: 18.0, weight: .heavy, design: .rounded))
            .onTapGesture(perform: {
                withAnimation {
                    self.editing.toggle()
                }
            })
            .contextMenu {
                Button(action: {
                    self.target = nil
                }) {
                    Text("Clear")
                }
            }
    }
    
    private func emptyMeasurementText() -> some View {
        Text("--")
        .font(.system(size: 18.0, weight: .heavy, design: .rounded))
        .onTapGesture(perform: {
            withAnimation {
                self.target = self.defaultValue
            }
        })
    }
    
    // MARK: - Buttons
    private func leadingButton() -> some View {
        Button(action: {
            guard let increment = self.increment, self.target?.value ?? 0 > 0 else {
                /// If in bad state or nil, reset to default
                self.target = self.defaultValue
                return
            }
            
            /// Make sure we don't go below 0
            self.target?.value = max((self.target?.value ?? 0) - increment, 0)
        }) {
            Image(systemName: "minus.circle")
            .floatingPlease(nil, padding: 8)
        }
        .font(.system(size: 16, weight: .black))
    }
    
    private func trailingButton() -> some View {
        Button(action: {
            guard let increment = self.increment else {
                /// If in bad state or nil, reset to default
                self.target = self.defaultValue
                return
            }
            
            self.target?.value = (self.target?.value ?? 0) + increment
        }) {
            Image(systemName: "plus.circle")
            .floatingPlease(nil, padding: 8)
        }
        .font(.system(size: 16, weight: .black))
    }
}

// MARK: - Previews
struct MeasurementStepperView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MeasurementStepperView(
                target: .constant(Measurement(value: 4, unit: UnitVolume.fluidOunces)), defaultValue: FeedEvent.defaultMeasurement, editing: .constant(true))
            
            MeasurementStepperView(
                target: .constant(Measurement(value: 30.0, unit: UnitDuration.minutes)), defaultValue: NapEvent.defaultMeasurement, editing: .constant(true))
            
            MeasurementStepperView(
                target: .constant(Measurement(value: 3.0, unit: UnitDuration.minutes)), defaultValue: TummyTimeEvent.defaultMeasurement, editing: .constant(true))
            
            MeasurementStepperView(
                target: .constant(Measurement(value: 10.0, unit: UnitMass.pounds)), defaultValue: WeightEvent.defaultMeasurement, editing: .constant(true))
                
            MeasurementStepperView(
                target: .constant(nil), defaultValue: WeightEvent.defaultMeasurement, editing: .constant(true))
        }
    }
}

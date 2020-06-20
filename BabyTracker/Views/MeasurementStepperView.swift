//
//  MeasurementStepperView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/18/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct MeasurementStepperView: View {
    @Binding var target: Measurement<Unit>? {
        didSet {
            onValueChange?(target)
        }
    }
    var defaultValue: Measurement<Unit>
    var onValueChange: ((Measurement<Unit>?) -> Void)?
    
    @Binding var editing: Bool
    
    var overrideIncrement: Double?
    
    var increment: Double? {
        return overrideIncrement ?? self.target?.unit.modifier
    }
    
    var body: some View {
        HStack {
            if editing {
                Button(action: {
                    guard let increment = self.increment, self.target?.value ?? 0 > 0 else {
                        self.target = self.defaultValue
                        // Bad unit?
                        return
                    }
                    self.target?.value = max((self.target?.value ?? 0) - increment, 0)
                }) {
                    Image(systemName: "minus.circle")
                    .floatingPlease(nil, padding: 8)
                }
                .font(.system(size: 16, weight: .black))
            }
            
            if target != nil {
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
            } else {
                Text("--")
                .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                .onTapGesture(perform: {
                    withAnimation {
                        self.target = self.defaultValue
                    }
                })
            }
            
            if editing {
                Button(action: {
                    guard let increment = self.increment else {
                        self.target = self.defaultValue
                        // Bad unit?
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
    }
}

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
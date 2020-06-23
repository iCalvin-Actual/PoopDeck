//
//  AgeView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct AgeView: View {
    
    enum DateView {
        case days
        case weeks
        case months
        case full
    }
    
    @State var ageStyle: DateView = .days
    var formatter: DateComponentsFormatter = .init()
    
    var birthday: Date?
    
    var body: some View {
        Button(action: {
            withAnimation {
                switch self.ageStyle {
                case .days:
                    self.ageStyle = .weeks
                case .weeks:
                    self.ageStyle = .months
                case .months:
                    self.ageStyle = .full
                case .full:
                    self.ageStyle = .days
                }
            }
        }) {
            Text(ageString)
            .font(.system(size: 16, weight: .black))
        }
    }
    
    var ageString: String {
        guard let birthday = birthday else {
            return ""
        }
        switch ageStyle {
        case .days:
            formatter.allowedUnits = [.day]
        case .weeks:
            formatter.allowedUnits = [.weekOfMonth, .day]
        case .months:
            formatter.allowedUnits = [.month, .weekOfMonth, .day]
        case .full:
            formatter.allowedUnits = [.year, .month, .day]
        }
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 2
        return formatter.string(from: birthday, to: Date()) ?? ""
    }
}

struct AgeView_Previews: PreviewProvider {
    static var previews: some View {
        AgeView(birthday: Date(timeIntervalSinceNow: -10000040))
    }
}

//
//  NewWindowView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI
import Combine

struct NewWindowView: View {
    
    var openDocument: (() -> Void)?
    
    var body: some View {
        VStack {
            Text("PoopDeck")
                .font(.system(.largeTitle, design: .rounded))
            
            Spacer()
        }
    }
}

struct NewWindowView_Previews: PreviewProvider {
    static var previews: some View {
        NewWindowView()
    }
}

//
//  NewWindowView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct NewWindowView: View {
    
    var onCreate: (() -> Void)?
    var onImport: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            Text("PoopDeck")
                .font(.system(.largeTitle, design: .rounded))
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.onCreate?()
                }) {
                    VStack {
                        Image(systemName: "plus.square.fill")
                        Text("Create new BabyLog")
                    }
                }
                
                
                Spacer()
                
                Button(action: {
                    self.onImport?()
                }) {
                    VStack {
                        Image(systemName: "plus.square.fill")
                        Text("Import")
                    }
                }
                
                Spacer()
            }
            Spacer()
        }
    }
}

struct NewBabyForm: View {
    var onApply: (() -> Void)?
    
    @State var babyName: String = ""
    @State var birthday: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $babyName)
            }
        }
    }
}

struct NewWindowView_Previews: PreviewProvider {
    static var previews: some View {
        NewBabyForm()
    }
}

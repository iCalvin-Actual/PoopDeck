//
//  CustomEventView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct CustomEventFormView: View {
    
    // MARK: - Variables
    @ObservedObject var date: ObservableDate = .init()
    
    @State var title: String = ""
    @State var info: String = ""
    @State var editing: Bool = false
    
    var onAction: ((CustomAction) -> Void)?
    
    // MARK: - Views
    var body: some View {
        HStack {
            bodyContent()
            .foregroundColor(.white)
            .padding()
            .background(CustomEvent.type.colorValue)
            .cornerRadius(22)
            .padding(.horizontal)
            
            if !editing {
                bodyContent()
                .opacity(0)
            }
            
            Spacer()
        }
    }
    
    private func bodyContent() -> some View {
        VStack {
            
            if !editing {
                headerRow()
            }
            
            buttonRow()
            
        }
    }
    
    private func headerRow() -> some View {
        HStack {
            Image(systemName: "pencil")
                .font(.title)
            
            Text("Custom Event")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
        }
    }
    
    private func formRow() -> some View {
        VStack(alignment: .leading) {
            HStack {

                Text("Event")
                    .font(.system(size: 18.0, weight: .heavy, design: .rounded))
                    .foregroundColor(BabyEventType.custom.colorValue)
            }
            
            TextField("Event", text: $title, onEditingChanged: { (editing) in
                self.editing = true
            }) {
                print("Return Tapped")
            }
            .font(.subheadline)
            .accentColor(BabyEventType.custom.colorValue)
            
            TextField("Info", text: self.$info)
                .font(.subheadline)
                .accentColor(BabyEventType.custom.colorValue)
            
            Spacer()
            
            HStack {
                
                Button(action: {
                    withAnimation {
                        self.editing = false
                    }
                }) {
                    Text("Cancel")
                    .bold()
                    .foregroundColor(BabyEventType.custom.colorValue)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
//                        self.onAction?(.create(<#T##CustomEvent#>, <#T##(String, String)#>))
                        self.editing = false
                    }
                }) {
                    Text("Save")
                    .bold()
                    .foregroundColor(BabyEventType.custom.colorValue)
                }.padding(4)
            }
        }
    }
    
    private func buttonRow() -> some View {
        HStack {
            Group {
                if editing {
                    formRow()
                } else {
                    Button(action: {
                        withAnimation {
                            self.editing = true
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .foregroundColor(.primary)
            .raisedButtonPlease()
        }
    }
}


struct NewCustomEventButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomEventFormView()
            Spacer()
        }
    }
}

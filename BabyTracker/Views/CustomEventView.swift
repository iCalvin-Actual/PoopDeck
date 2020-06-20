//
//  CustomEventView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

enum CustomAction {
    case create(_: CustomEventFormView.FormContent)
    case remove(_: UUID)
    case showDetail(_: [UUID])
    case toggleUnit(_: UUID)
    case undo
    case redo
}

struct CustomEventView: View {
    
    // MARK: - Variables
    @ObservedObject var date: ObservableDate = .init()
    
    @State var allowPresentList: Bool = false
    
    @State var existingEvent: CustomEvent?
    
    @State var title: String = ""
    @State var info: String = ""
    @State var editing: Bool = false
    
    var onAction: ((CustomAction) -> Void)?
    
    // MARK: - Views
    var body: some View {
        VStack {
            
            headerRow()
            
            formRow()
            
            buttonRow()
            
        }
        .foregroundColor(.white)
        .padding()
        .background(CustomEvent.type.colorValue)
        .cornerRadius(22)
        .padding(.horizontal)
    }
    
    private func headerRow() -> some View {
        HStack {
            Text(BabyEventType.custom.emojiValue)
            
            Text("Custom Event")
            
            Spacer()
            
            Text(DateFormatter.shortDateTime.string(from: existingEvent?.date ?? date.date))
            
            if allowPresentList {
                
                Image(systemName: "chevron.right.circle")
                
            }
        }
    }
    
    private func formRow() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Create Custom Event")
                
                TextField("Event", text: $title, onEditingChanged: { (editing) in
                    self.editing = true
                }) {
                    print("Return Tapped")
                }
                
                TextField("Info", text: self.$info)
            }
            Spacer()
        }
    }
    
    private func buttonRow() -> some View {
        HStack {
            if existingEvent != nil {
                Button(action: {
                    guard self.existingEvent != nil else { return }
//                    self.onAction?(.remove(event))
                }, label: {
                    Image(systemName: "trash")
                })
            }
            Spacer()
            Button(action: {
//                self.onAction?(.create(self.existingEvent ?? .new))
                self.editing = false
                self.title = self.existingEvent?.event ?? ""
                self.info = ""
            }, label: {
                Image(systemName: "plus")
            })
            Spacer()
            if existingEvent != nil {
                Button(action: {
//                    self.onAction?(.update(self.existingEvent ?? .new, (self.title, self.info)))
                    self.editing = false
                    self.title = self.existingEvent?.event ?? ""
                    self.info = ""
                }, label: {
                    Image(systemName: "pencil.and.outline")
                })
            }
        }
    }
}

struct CustomEventView_Previews: PreviewProvider {
    static var previews: some View {
        CustomEventView()
    }
}

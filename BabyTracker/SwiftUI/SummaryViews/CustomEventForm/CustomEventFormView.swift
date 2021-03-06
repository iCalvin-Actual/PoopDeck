//
//  CustomEventView.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/11/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Combine
import SwiftUI

struct CustomEventFormView: View {
    
    @State var content: FormContent = .init()
    @State var restoreContent: [FormContent] = [.init()]
    
    /// Allow stepping through multiple items
    @State var activeOffset: Int = 0
    
    @State var editing: Bool = false
    
    var onAction: ((CustomEventFormAction) -> Void)?
    
    @State private var confirmDelete: Bool = false
    @State private var deleteState: FormDeleteStyle = .discard
    
    private var showForm: Bool {
        return editing || content.id != nil
    }
    
    // MARK: - Views
    var body: some View {
        HStack {
            VStack {
                
                self.headerRow()
                
                self.buttonRow()
                
            }
            .foregroundColor(.white)
            .padding()
            .background(CustomEvent.type.colorValue)
            .cornerRadius(22)
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .onAppear {
            if let restore = self.restoreContent.sorted(by: { $0.date.date < $1.date.date }).last {
                self.content = restore
            }
        }
    }
    
    private func headerRow() -> some View {
        HStack(alignment: .top) {
            Color.white
                .frame(width: 18, height: 18)
                .mask(Image(BabyEventType.custom.imageName).resizable())
            
            Text(BabyEventType.custom.displayTitle)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
            
            Spacer()
            
            if restoreContent.count > 1 {
                Button(action: {
                    guard self.activeOffset < self.restoreContent.count - 1 else { return }
                    guard !self.isEdited else {
                        self.deleteState = .discard
                        self.confirmDelete = true
                        return
                    }
                    withAnimation {
                        let newOffset = self.activeOffset + 1
                        self.editing = false
                        self.activeOffset = newOffset
                        self.content = self.restoreContent.sorted(by: { $0.date.date > $1.date.date })[newOffset]
                    }
                }) {
                    Image(systemName: "arrow.left.circle")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
                .appearDisabledPlease(activeOffset >= restoreContent.count - 1)

                Button(action: {
                    guard self.activeOffset > 0 else { return }
                    guard !self.isEdited else {
                        self.deleteState = .discard
                        self.confirmDelete = true
                        return
                    }
                    withAnimation {
                        let newOffset = self.activeOffset - 1
                        self.editing = false
                        self.activeOffset = newOffset
                        self.content = self.restoreContent.sorted(by: { $0.date.date > $1.date.date })[newOffset]
                    }
                }) {
                    Image(systemName: "arrow.right.circle")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
                .appearDisabledPlease(activeOffset == 0)
            }
        }
    }
    
    private func form() -> some View {
        VStack(alignment: .leading) {
            HStack {
                TimeStepperView(
                    targetDate: $content.date,
                    onValueChange: { newValue in
                        guard newValue.date != self.restoreContent.last?.date.date ?? Date() else { return }
                        self.editing = true
                }, editing: $editing)
                
                Spacer()
            }
            .foregroundColor(BabyEventType.custom.colorValue)
            
            TextField("Event", text: $content.title, onEditingChanged: { (editing) in
                self.editing = editing
            }, onCommit: {
                self.editing = false
            })
            .font(.headline)
            .accentColor(BabyEventType.custom.colorValue)
            
            HStack {
                TextField(
                    "Info",
                    text: $content.info,
                    onEditingChanged: { (editing) in
                        self.editing = true
                    })
                    .font(.subheadline)
                    .accentColor(BabyEventType.custom.colorValue)
                
                Spacer()
                
                Button(action: {
                    self.deleteState = .delete
                    self.confirmDelete = true
                }) {
                    Image(systemName: "trash.circle")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
                .foregroundColor(BabyEventType.custom.colorValue)
                .opacity(content.id == nil ? 0 : 1)
            }
            
            if editing {
                
                Spacer()
                
                HStack {
                    
                    Button(action: {
                        guard self.isEmpty else {
                            self.deleteState = .discard
                            self.confirmDelete = true
                            return
                        }
                        withAnimation {
                            self.editing = false
                        }
                    }) {
                        Text(self.content.id == nil ? "Close" : "Restore")
                        .bold()
                        .foregroundColor(BabyEventType.custom.colorValue)
                    }
                    .appearDisabledPlease(!isEdited)
                    
                    Spacer()
                    
                    Button(action: {
                        guard self.isValid else { return }
                        withAnimation {
                            self.onAction?(.create(self.content))
                            self.editing = false
                            self.content = self.restoreContent.last ?? .init()
                        }
                    }) {
                        Text("Save")
                        .bold()
                        .foregroundColor(BabyEventType.custom.colorValue)
                    }
                    .appearDisabledPlease(!isValid)
                }
            }
        }
        .alert(isPresented: $confirmDelete) {
            Alert(
                title: Text("\(self.deleteState == .discard ? "Discard" : "Delete") \(self.content.id == nil || self.deleteState == .delete ? "Event" : "Changes")"),
                message: Text(self.deleteState == .delete ? "Are you sure you want to delete this event?" : "Continue without saving?"),
                primaryButton:
                .destructive(Text(self.deleteState == .delete ? "Delete" : "Discard"), action: {
                        withAnimation {
                            switch self.deleteState {
                            case .discard:
                                self.content = self.restoreContent.sorted(by: { $0.date.date > $1.date.date })[self.activeOffset]
                            case .delete:
                                if let id = self.content.id {
                                    self.onAction?(.remove(id))
                                }
                            }
                            self.editing = false
                        }}),
                secondaryButton:
                .cancel()
            )
        }
    }
    
    private func buttonRow() -> some View {
        HStack {
            Group {
                if showForm {
                    form()
                } else {
                    Button(action: {
                        withAnimation {
                            self.editing = true
                        }
                    }, label: {
                        Image(systemName: "plus")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                    })
                }
            }
            .foregroundColor(.primary)
        }
        .floatingPlease()
    }
}

struct CustomEventFormView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomEventFormView()
            Spacer()
        }
    }
}

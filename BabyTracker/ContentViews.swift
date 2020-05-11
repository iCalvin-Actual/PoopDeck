//
//  ContentViews.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 5/2/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import SwiftUI

struct TimeDurationView: View {
    let startDate: Date
    let duration: TimeInterval?
    var body: some View {
        VStack {
            Text(DateFormatter.timeDisplay.string(from: startDate))
            if duration ?? 0 > 0 {
                Text(DateComponentsFormatter.durationDisplay.string(from: duration ?? 0) ?? "")
            }
        }
    }
}

public struct FeedView: View {
    @State var feed: [FeedViewModel]
    public var body: some View {
        NavigationView {
            List {
                ForEach(feed) { event in
                    NavigationLink(destination: EventFormView(eventType: event.type, eventID: event.id)) {
                        FeedCard(event: event)
                            .background(Color(UIColor.systemGroupedBackground))
                            .cornerRadius(8)
                            .contextMenu {
                                Button(action: {
                                 print("Delete")
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash.fill")
                                }

                                Button(action: {
                                    // Do nothing?
                                    print(event)
                                }) {
                                    Text("Edit")
                                    Image(systemName: "pencil.and.ellipsis.rectangle")
                                }

                                Button(action: {
                                    // Do nothing?
                                    print(event)
                                }) {
                                    Text("Duplicate")
                                    Image(systemName: "doc.on.doc.fill")
                                }
                       }
                    }
                }
                .padding(.trailing, 4)
                .frame(maxWidth: 835.0)
            }
//            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Sophia Events"))
        }.navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                EventManager.shared.fetchSummary { summary in
                    guard let summary = summary else {
                        return
                    }
                    self.feed = summary.dateSortedModels
                }
        }
    }
}



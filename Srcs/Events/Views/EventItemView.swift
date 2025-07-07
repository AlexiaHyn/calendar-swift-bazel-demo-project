//
//  EventItemView.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/21.
//

import SwiftUI
import Foundation
import CommonTools
import CoreData

public struct EventItemView: View {
    private var event: EventItem?
    private var currDate: Date
    
    public init(currDate: Date, event: EventItem?) {
        self.currDate = currDate
        self.event = event
    }
    
    private func priorityView(priority: Int) -> some View {
        let priorityColors = [Color.green, Color.yellow, Color.red]
        return Circle()
            .fill(priorityColors[priority])
            .frame(width: 13, height: 13)
    }
    
    private func personView(person: String) -> some View {
        return ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 25, height: 25)
            Text(CommonFormatter.captialInitialsFormat(from: person))
                .font(.caption)
                .foregroundStyle(.white)
        }
        
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let event = event {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(event.startTime.formatted(date: .omitted, time:.shortened))
                            .font(.callout)
                            .frame(width: 60, alignment: .leading)
                        Text(CommonFormatter.durationFormat(from: event.startTime, to: event.endTime))
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .opacity(0.8)
                            .frame(width: 60, alignment: .leading)
                    }
                    
                    priorityView(priority: Int(event.priority))
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.title)
                            .font(.body)
                        if let people = event.people as? [String] {
                            HStack {
                                ForEach(people, id: \.self) { person in
                                    personView(person: person)
                                }
                            }
                        }
                        if let loc = event.location {
                            Label(loc, systemImage: "mappin.circle.fill")
                                .font(.callout)
                                .foregroundStyle(.gray)
                                .opacity(0.8)
                        }
                    }
                    .padding([.leading], 5)
                    Spacer()
                }
                .padding(5)
                
            } else {
                // empty event
                VStack(alignment: .leading) {
                    Text("No events")
                        .foregroundStyle(.gray)
                }
                .padding(5)
            }
        }
    }
}

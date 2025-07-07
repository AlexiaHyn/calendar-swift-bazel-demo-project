//
//  ContentView.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/5.
//

import SwiftUI
import CalendarEvents
import CommonTools
import CalendarCalendar
import CalendarAgenda

public struct CalendarContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var date: Date
    @State private var selectedDate: Date
    @State private var scrollOnTap: Bool = true
    @State private var scrollOnDragging: Bool = false
    @State private var dayEvents: [Date:[EventItem]] = [:]
    
    private let dateFormatter = CommonFormatter.dateFormat(style: "medium")
    
    public init() {
        self.date = Date.now
        self.selectedDate = Date.now
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button(action: {}){
                    Label("", systemImage: "line.3.horizontal")
                        .font(.title)
                        .foregroundStyle(.gray)
                }
                Spacer()
                Text("\(selectedDate, formatter: dateFormatter)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Spacer()
                EventCreateView(dayEvents: $dayEvents)
            }
            .padding(.top)
            .padding(.horizontal)
            
            CalendarView(selectedDate: $selectedDate, scrollOnTap: $scrollOnTap, scrollOnDragging: $scrollOnDragging)
            AgendaView(dayEvents: $dayEvents, selectedDate: $selectedDate, scrollOnTap: $scrollOnTap, scrollOnDragging: $scrollOnDragging)
            
            // Experiment1: implementation of AgendaView with LazyVStack and ScrollView
//            AgendaViewStack(selectedDate: $selectedDate, scrollOnTap: $scrollOnTap)
            
            // Experiment2: implementation of AgendaView with List
//            AgendaViewList(selectedDate: $selectedDate, scrollOnTap: $scrollOnTap)
            Spacer()
        }
        .onAppear {
            dayEvents = Event.loadEventsData(context: viewContext)
        }
    }
}

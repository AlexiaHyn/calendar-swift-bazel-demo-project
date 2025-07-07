//
//  EventCreateButton.swift
//  CalendarMainView
//
//  Created by Alexia Huang on 2024/11/13.
//

import SwiftUI
import CoreData

public struct EventCreateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding private var dayEvents: [Date:[EventItem]]
    
    @State private var showPopup = false
    
    @State private var title: String
    @State private var people: [String]
    @State private var person: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var location: String
    @State private var priority: EventPriority
    
    public init(dayEvents: Binding<[Date : [EventItem]]>) {
        self.showPopup = false
        self.title = "Meeting on calendar demo app"
        self.people = []
        self.person = "Amily"
        self.startTime = Date.now
        self.endTime = Date.now
        self.location = "Bilibili"
        self.priority = EventPriority.low
        
        self._dayEvents = dayEvents
    }
    
    func submit() {
        let event = Event(context: viewContext)
        event.createEvent(title: title,people: [person], startTime: startTime, endTime: endTime,location: location, priority: priority)
        
        //reload EVENTS
        dayEvents = Event.loadEventsData(context: viewContext)
        
        print("New event created.")
        showPopup = false
    }
    
    func cancel() {
        showPopup = false
    }
    
    public var body: some View {
        Button(action: {
            showPopup.toggle()
        }){
            Label("", systemImage: "plus")
                .font(.title)
                .foregroundStyle(.gray)
        }
        .sheet(isPresented: $showPopup) {
            VStack {
                HStack {
                    Button(action: cancel){
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    Text("New Event")
                        .font(.headline)
                    Spacer()
                    
                    Button(action: submit) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }.padding()
                
                 NavigationView {
                     Form {
                         Section {
                             HStack{
                                 Image(systemName: "smallcircle.filled.circle")
                                     .foregroundStyle(.gray)
                                 TextField("Title", text: $title)
                             }
                         }
                         
                         Section {
                             HStack {
                                 Image(systemName: "person.2")
                                     .foregroundStyle(.gray)
                                 Picker("People", selection: $person) {
                                     Text("Amily").tag("Amily")
                                     Text("Ben").tag("Ben")
                                     Text("Charlie").tag("Charlie")
                                 }
                                 .pickerStyle(.navigationLink)
                             }
                         }
                        
                         Section {
                             HStack {
                                 Image(systemName: "mappin.and.ellipse.circle")
                                     .foregroundStyle(.gray)
                                 TextField("Location", text: $location)
                             }
                             
                         }
                         
                         Section {
                             HStack {
                                 Image(systemName: "clock")
                                     .foregroundStyle(.gray)
                                 DatePicker(
                                     "Start Time",
                                     selection: $startTime,
                                     displayedComponents: [.date,.hourAndMinute]
                                 )
                             }
                             HStack {
                                 Image(systemName: "clock")
                                     .foregroundStyle(.gray)
                                 DatePicker(
                                     "End Time",
                                     selection: $endTime,
                                     displayedComponents: [.date,.hourAndMinute]
                                 )
                             }
                         }
                         
                         
                         Section {
                             HStack {
                                 Image(systemName: "inset.filled.circle.dashed")
                                     .foregroundStyle(.gray)
                                 Picker("Priority", selection: $priority) {
                                     Text("Low").tag(EventPriority.low)
                                     Text("Medium").tag(EventPriority.medium)
                                     Text("High").tag(EventPriority.high)
                                 }
                                 .pickerStyle(.navigationLink)
                             }
                         }

                     }.background(Color.gray.opacity(0.07))
                }
            }
            
        }
    }
}

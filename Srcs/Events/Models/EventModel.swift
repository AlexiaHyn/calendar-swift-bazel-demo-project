//
//  EventItem.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/8.
//

import Foundation
import SwiftUICore
import CoreData
import CommonTools

public class Event {
    private var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public static func loadEventsData(context: NSManagedObjectContext) -> Dictionary<Date, [EventItem]> {
        // load all events and saved into a dictionary
        var eventsDict: Dictionary<Date, [EventItem]> = [:]
        var eventsList: [EventItem] = []

        let request: NSFetchRequest = {
            let request = EventItem.fetchRequest()
            return request
        }()
        do {
            eventsList = try context.fetch(request)
        } catch {
            print("Error fetching entities: \(error)")
            eventsList = []
        }
        
        for event in eventsList {
            let currDay = CalendarProps.startOfDay(date: event.startTime)
            eventsDict[currDay, default:[]].append(event)
        }
        return eventsDict
    }
    
    public func getDateEvents(date: Date) -> [EventItem] {
        // get events on a given date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let request: NSFetchRequest = {
            let request = EventItem.fetchRequest()
            request.fetchLimit = 50
            request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", startOfDay as NSDate, endOfDay as NSDate)
            return request
        }()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching entities: \(error)")
            return []
        }
    }
    
    public func createEvent(title: String, people: [String] = [], startTime: Date, endTime: Date, location: String? = nil, priority: EventPriority) {
        let newEvent = EventItem(context: context)
        newEvent.id = UUID()
        newEvent.title = title
        newEvent.people = NSArray(array: people)
        newEvent.startTime = startTime
        newEvent.endTime = endTime
        newEvent.location = location
        newEvent.priority = Int16(priority.rawValue)
        
        do {
            try context.save()
        } catch {
            print("Error in creating the event: ", error.localizedDescription)
        }
        
    }
    
    public func deleteEvent(event: EventItem) {
        // not fully implemented
//        context.delete(event)
//        do {
//            try context.save()
//        } catch {
//            print("Error in deleting the event: ", error.localizedDescription)
//        }
    }
    
    func updateEvent(event: EventItem) {
        // not implemented
    }
    
}

public enum EventPriority: Int {
    case low = 0
    case medium = 1
    case high = 2
}

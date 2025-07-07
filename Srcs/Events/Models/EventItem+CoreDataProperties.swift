//
//  EventItem+CoreDataProperties.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/13.
//
//

import Foundation
import CoreData


extension EventItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventItem> {
        return NSFetchRequest<EventItem>(entityName: "EventItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date
    @NSManaged public var location: String?
    @NSManaged public var priority: Int16
    @NSManaged public var people: NSArray?

}

extension EventItem : Identifiable {

}

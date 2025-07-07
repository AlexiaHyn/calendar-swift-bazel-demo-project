//
//  File.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/12.
//

import Foundation
import CoreData

// Define an observable class to encapsulate all Core Data-related functionality.
public class CoreDataStack: ObservableObject {
    public static let shared = CoreDataStack()
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    public lazy var persistentContainer: NSPersistentContainer = {
        
        // Pass the data model filename to the container’s initializer.
        let container = NSPersistentContainer(name: "CalendarDataStorage")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
        
    private init() { } // Private initializer to prevent others from creating an instance
    
    public func save() {
        // Verify that the context has uncommitted changes.
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            // Attempt to save changes.
            try persistentContainer.viewContext.save()
        } catch {
            // Handle the error appropriately.
            print("Failed to save the context:", error.localizedDescription)
        }
    }
        
//    public func delete(item: EventItem) {
//        persistentContainer.viewContext.delete(item)
//        save()
//    }
}

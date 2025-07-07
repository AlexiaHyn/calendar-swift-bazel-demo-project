//
//  CalendarProjectApp.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/5.
//

import SwiftUI
import CalendarMainView
import CommonTools

@main
struct CalendarProjectApp: App {
    // Create an observable instance of the Core Data stack.
    @StateObject private var coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            CalendarMain()
                .environment(\.managedObjectContext, coreDataStack.persistentContainer.viewContext)
        }
    }
}

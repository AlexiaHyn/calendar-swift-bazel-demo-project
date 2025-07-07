//
//  AgendaView.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/21.
//

import SwiftUI
import CalendarEvents

public struct AgendaView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var dayEvents: [Date: [EventItem]]
    @Binding var selectedDate: Date
    @Binding var scrollOnTap: Bool
    @Binding var scrollOnDragging: Bool
    
    public init(dayEvents: Binding<[Date : [EventItem]]>, selectedDate: Binding<Date>, scrollOnTap: Binding<Bool>, scrollOnDragging: Binding<Bool>) {
        self._dayEvents = dayEvents
        self._selectedDate = selectedDate
        self._scrollOnTap = scrollOnTap
        self._scrollOnDragging = scrollOnDragging
    }

    public var body: some View {
        AgendaViewController(viewContext: viewContext, dayEvents: $dayEvents, selectedDate: $selectedDate, scrollOnTap: $scrollOnTap, scrollOnDragging: $scrollOnDragging)
    }
}

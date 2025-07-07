//
//  AgendaModel.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/22.
//

import Foundation
import CommonTools

public class AgendaModel {
    private var currDate = Date.now
    private let calendar = Calendar.current
    
    public init() {
    }
    
    public func dateForSection(section: Int, date: Date) -> Date {
        let baseDate = CalendarProps.startOfDay(date: date)
        return calendar.date(byAdding: .day, value: section, to: baseDate)!
    }
    
    public func sectionForDate(minDate: Date, date: Date) -> Int {
        // assume given date is within min max date range
        let baseDate = CalendarProps.startOfDay(date: minDate)
        let targetDate = CalendarProps.startOfDay(date: date)
        let components = calendar.dateComponents([.day], from: baseDate, to: targetDate)
        return components.day!
    }

}

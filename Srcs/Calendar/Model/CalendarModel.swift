//
//  CalendarModel.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/12/3.
//

import Foundation
import CommonTools

public class CalendarModel: ObservableObject {
    @Published public var curDay: Date = Date()
    @Published public var minDay: Date = Date()
    @Published public var maxDay: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
    @Published public var displayDays: Int = 4
    @Published public var curSectionStartDay: Date = Date()
    @Published public var curSectionEndDay: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
    
    public init() {
        loadDates(date: Date.now)
    }
    
    public func loadDates(date: Date) {
        curDay = CalendarProps.startOfDay(date: date)
        let startOfPrevMonth = CalendarProps.startOfPreviousMonth(for: date)
        let endOfNextMonth = CalendarProps.endOfNextMonth(for: date)
        minDay = CalendarProps.sundayBeforeStartOfMonth(for: startOfPrevMonth)
        maxDay = CalendarProps.satBeforeEndOfMonth(for: endOfNextMonth)
        displayDays = CalendarProps.numDaysBetween(from: minDay, to: maxDay)
        curSectionStartDay = CalendarProps.sundayBeforeStartOfMonth(for: date)
        curSectionEndDay = CalendarProps.satBeforeEndOfMonth(for: date)
    }
    
    public func calendarDisplayDays() -> [Date] {
        var calendarDisplayDays: [Date] = []
        for day in 0..<displayDays {
            let newDay = Calendar.current.date(byAdding: .day, value: day, to: minDay)!
            calendarDisplayDays.append(newDay)
        }
        return calendarDisplayDays
    }
    
    public func indexForDate(date: Date) -> IndexPath {
        if date < curSectionStartDay {
            let row = CalendarProps.numDaysBetween(from: minDay, to: date) - 1
            return IndexPath(row: row, section: 0)
        } else if date >= curSectionStartDay && date <= curSectionEndDay {
            let row = CalendarProps.numDaysBetween(from: curSectionStartDay, to: date) - 1
            return IndexPath(row: row, section: 1)
        } else {
            let row = CalendarProps.numDaysBetween(from: curSectionEndDay, to: date) - 2
            return IndexPath(row: row, section: 2)
        }
    }
    
    public func dateForIndex(indexPath: IndexPath) -> Date {
        let calendar = Calendar.current
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            return calendar.date(byAdding: .day, value: row, to: minDay)!
        case 1:
            return calendar.date(byAdding: .day, value: row, to: curSectionStartDay)!
        case 2:
            return calendar.date(byAdding: .day, value: row + 1, to: curSectionEndDay)!
        default:
            return calendar.date(byAdding: .day, value: row, to: curSectionStartDay)!
        }
    }
}

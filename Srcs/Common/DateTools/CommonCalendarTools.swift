//
//  CommonCalendarProps.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/22.
//

import Foundation
import SwiftUI

public class CalendarProps {
    // operate on time
    public static func startOfDay(date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    // operate on days
    public static func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    public static func isToday(date: Date) -> Bool {
        return isSameDay(date1: Date.now, date2: date)
    }
    
    public static func isYesterday(date: Date) -> Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
        return isSameDay(date1: yesterday, date2: date)
    }
    
    public static func isTomorrow(date: Date) -> Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!
        return isSameDay(date1: tomorrow, date2: date)
    }
    
    // number of days from date1 to date2 inclusive
    public static func numDaysBetween(from date1: Date, to date2: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: date1, to: date2).day! + 1
    }
    
    public static func selectedInDateRange(dateRange: [DateComponents]?, selectedDate: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        if let index = dateRange!.firstIndex(of: components) {
            return index
        }
        return nil
    }
    
    // operate on months
    public static func isMonthEven(for date: Date) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        return month % 2 == 0
    }
    
    public static func startOfMonth(for date: Date) -> Date {
        return Calendar.current.dateInterval(of: .month, for: date)!.start
    }
    
    public static func endOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let lastDay = calendar.dateInterval(of: .month, for: date)!.end
        return calendar.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    public static func startOfPreviousMonth(for date: Date) -> Date {
        let dayFromPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        return startOfMonth(for: dayFromPreviousMonth)
    }
    
    public static func endOfNextMonth(for date: Date) -> Date {
        let dayFromNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        return endOfMonth(for: dayFromNextMonth)
    }
    
    public static func numberOfDaysInMonth(for date: Date) -> Int {
        let lastDay = endOfMonth(for: date)
        return Calendar.current.component(.day, from: lastDay)
    }
    
    public static func sundayBeforeStartOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let firstDay = startOfMonth(for: date)
        let startOfMonthWeekDay = calendar.component(.weekday, from: firstDay)
        let numberFromPreviousMonth = startOfMonthWeekDay - 1
        return calendar.date(byAdding: .day, value: -numberFromPreviousMonth, to: firstDay)!
    }
    
    public static func satBeforeEndOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let lastDay = endOfMonth(for: date)
        let endOfMonthWeekDay = calendar.component(.weekday, from: lastDay)
        let numberFromLastSaturday = endOfMonthWeekDay % 7
        return calendar.date(byAdding: .day, value: -numberFromLastSaturday, to: lastDay)!
    }
   
}

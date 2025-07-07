//
//  TimeDateFormatter.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/11.
//

import Foundation

public class CommonFormatter {
    public static func dateFormat(style: String, format: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        switch style.lowercased() {
            case "none":
            // date not displayed
                formatter.dateStyle = .none
            case "short":
            // 1/16/2023
                formatter.dateStyle = .short
            case "medium":
            // Jan 16, 2023
                formatter.dateStyle = .medium
            case "long":
            // January 16, 2023
                formatter.dateStyle = .long
            case "full":
            // Monday, November 11, 2024
                formatter.dateStyle = .full
            default:
                formatter.dateStyle = .medium
        }
        if let format = format {
            formatter.dateFormat = format
        }
        return formatter
    }
    
    public static func dateDayFormat(for date: Date) -> String {
        return date.formatted(.dateTime.day())
    }
    
    public static func dateMonthFormat(for date: Date) -> String {
        return date.formatted(.dateTime.month())
    }
    
    // Format duration of time in form of xx h xx m
    public static func durationFormat(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        if let duration = formatter.string(from: startDate, to: endDate) {
            return duration
        } else {
            return ""
        }
    }
    
    // Transform and format to celcius degrees
    public static func tempFormat(temp: Double, from styleFrom: String = "") -> String {
        // default: swich to celcius format
        switch styleFrom.lowercased() {
        case "c":
            return String(format: "%.1f\u{00B0}C", temp)
        case ("f"):
            return String(format: "%.1f\u{00B0}C", (temp - 32) * 5 / 9)
        case ("k"):
            return String(format: "%.1f\u{00B0}C", temp - 273.15)
        default:
            return String(format: "%.1f\u{00B0}C", temp)
        }
    }
    
    public static func captialInitialsFormat(from text: String) -> String {
        let intials = text.split(separator: " ").compactMap{word in
            word.first?.uppercased()
        }
        return intials.joined()
    }
}

//
//  WeatherView.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/6.
//

import SwiftUI
import CommonTools

public struct WeatherView: View {
    @StateObject var weatherDataDisplay = WeatherDataLoader()
    @State var mainColor : Color = Color.gray
    private var dateFormatter: DateFormatter
    
    private var currDate: Date
    
    public init(currDate: Date) {
        self.dateFormatter = CommonFormatter.dateFormat(style: "full", format: "EEEE, MMM d")
        self.currDate = currDate
    }

    public var body: some View {
        HStack(spacing: 0){
            if CalendarProps.isToday(date: currDate) {
                Text("Today · ")
            } else if CalendarProps.isTomorrow(date: currDate) {
                Text("Tomorrow · ")
            } else if CalendarProps.isYesterday(date: currDate) {
                Text("Yesterday · ")
            }
            if let weatherDataRange = weatherDataDisplay.weatherDataRange,
               let index = CalendarProps.selectedInDateRange(dateRange: weatherDataRange, selectedDate: currDate)
            {
                if let weatherData = weatherDataDisplay.weatherData,
                   let minTemp = weatherData.weather[index].minTemp,
                   let maxTemp = weatherData.weather[index].maxTemp
                {
                    Text("\(dateFormatter.string(from: currDate)) · \(CommonFormatter.tempFormat(temp: minTemp))~\(CommonFormatter.tempFormat(temp: maxTemp))")
                        
                } else {
                    Text("\(dateFormatter.string(from: currDate))")
                        
                }
                if let weatherData = weatherDataDisplay.weatherData,
                   let weatherIcon = weatherData.weather[index].icon
                {
                    WeatherIconView(weatherIconName: weatherIcon, mainColor: $mainColor)
                }
            } else {
                Text("\(dateFormatter.string(from: currDate))")
                    
            }
            Spacer()
        }
        .onAppear {
            if CalendarProps.isToday(date: currDate) {
                self.mainColor = Color.blue
            } else {
                self.mainColor = Color.gray
            }
        }
        .padding(.leading, 7)
        .padding(.vertical, 5)
        .font(.callout)
        .foregroundStyle(mainColor)
        .frame(maxWidth:.infinity)
        .background(Color.white.overlay(mainColor.opacity(0.1)))
    }
}

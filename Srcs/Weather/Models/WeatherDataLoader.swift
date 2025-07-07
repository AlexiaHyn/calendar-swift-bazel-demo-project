//
//  WeatherData.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/11/6.
//

import Foundation
import CoreLocation
import CommonTools
import SwiftUI

// for giving the final caculated weather result
public class WeatherList: Codable {
    init(weather: [Weather]) {
        self.weather = weather
    }
    var weather: [Weather] = []
}

class Weather: Codable {
    init(dt: Double, minTemp: Double? = nil, maxTemp: Double? = nil, icon: String? = nil) {
        self.dt = dt
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.icon = icon
    }
    var dt: Double
    var minTemp: Double?
    var maxTemp: Double?
    var icon: String?
}

// for loading weather JSON data
public class WeatherMain: Decodable {
    var list: [WeatherData]?
}

class WeatherTemp: Decodable {
    var temp: Double?
}

class WeatherData: Decodable {
    var dt: Int?
    var main: WeatherTemp?
    var weather: [WeatherStatus]?
}

class WeatherStatus: Decodable {
    var main: String?
    var description: String?
    var icon: String?
}

public class WeatherDataLoader: ObservableObject {
    @Published var weatherData: WeatherList?
    @Published var weatherDataRange: [DateComponents]?
    private let cache = WeatherDataCache.shared
    
    public init() {
        loadWeatherData()
    }
    
    private func URLSetup() -> URL {
        let apiKey = "b873822e727d5a24f6ef155003a3e2a9"
        let location: CLLocation? = Permissions.shared.getLocation()
        //default: location of Shanghai
        let lat = (location != nil) ? location!.coordinate.latitude : 31.2222
        let lon = (location != nil) ? location!.coordinate.longitude : 121.4581
        let url:URL! = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric")
        return url
    }
    
    public func loadWeatherData() {
        // setup weatherDataRange
        let today = CalendarProps.startOfDay(date: Date())
        var dateRange: [DateComponents] = []
        let calendar = Calendar.current
        for dayOffset in 0..<5 {
            if let newDate = calendar.date(byAdding: .day, value: dayOffset, to: today) {
                let components = calendar.dateComponents([.year, .month, .day], from: newDate)
                dateRange.append(components)
            }
        }
        self.weatherDataRange = dateRange
        
        // read from cache
        let formatter = CommonFormatter.dateFormat(style: "short")
        let todayString = formatter.string(from: today)
        if let weatherDataCache = self.cache.object(forKey: todayString) {
            // decode JSON NSData
            do {
                let weatherDataDecoded = try JSONDecoder().decode(WeatherList.self, from: weatherDataCache)
                self.weatherData = weatherDataDecoded
                return
            } catch {
                print("Error decoding cached weather data: \(error)")
            }
        }
        
        // load weatherData
        let weatherDataManager = DataManager()
        weatherDataManager.pullData(url: URLSetup()) {(data: Data?) in
            if let data: WeatherMain = weatherDataManager.decodeJSON(data: data) {
                var weatherList: [Weather] = []
                // initialize time zone for date comparison
                let timeZone = TimeZone.current
                var calendar = Calendar.current
                calendar.timeZone = timeZone
               
                // initialize weather data collectors
                var currDate = Date.now
                var minTemp = Double.infinity
                var maxTemp = -Double.infinity
                var icon: String? = data.list?[0].weather?[0].icon
                
                if let weatherDataList = data.list {
                    for weatherData in weatherDataList {
                        let dateInfo = Date(timeIntervalSince1970: TimeInterval(weatherData.dt!))
                        if !(calendar.isDate(currDate, inSameDayAs: dateInfo)) {
                            let weather = Weather(
                                dt: currDate.timeIntervalSince1970,
                                minTemp: minTemp,
                                maxTemp: maxTemp,
                                icon: icon ?? nil
                            )
                            weatherList.append(weather)
                            
                            //reset weather data collectors
                            minTemp = Double.infinity
                            maxTemp = -Double.infinity
                            icon = nil
                            //push date for data collection one day forward
                            currDate = calendar.date(byAdding: .day, value: 1, to: currDate)!
                        }
                        
                        // collect weather icon info
                        let difference = abs(currDate.timeIntervalSince(dateInfo))
                        let timeRange: TimeInterval = 1.5 * 60 * 60
                        if difference <= timeRange {
                            if let weatherIcon = weatherData.weather?[0].icon {
                                icon = weatherIcon
                            }
                        }
                        
                        // collect weather temp info
                        if let temp = weatherData.main?.temp {
                            if temp < minTemp {
                                minTemp = temp
                            }
                            if temp > maxTemp {
                                maxTemp = temp
                            }
                        }
                    }
                }
                self.weatherData = WeatherList(weather: weatherList)
                
                // cache data
                // encode JSON NSData
                do {
                    let weatherDataEncoded = try JSONEncoder().encode(WeatherList(weather: weatherList))
                    self.cache.set(object: NSData(data: weatherDataEncoded), forKey: todayString)
                } catch {
                    print("Error encoding weather data for cache storage: \(error)")
                }
            }
        }
    }
}



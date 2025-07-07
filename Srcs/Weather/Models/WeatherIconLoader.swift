//
//  WeatherIconLoader.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/12/3.
//

import Foundation
import UIKit
import CommonTools

public class WeatherIconLoader: ObservableObject {
    @Published var weatherIconImg: UIImage?
    private let cache = WeatherDataCache.shared
    
    public init() {
    }
    
    public func loadWeatherIcons(weatherIconName: String) {
        // read from cache
        if let cacheImgData = self.cache.object(forKey: weatherIconName) {
            self.weatherIconImg = UIImage(data: cacheImgData)
            return
        }
            
        // no store in cache, load image
        let weatherDataManager = DataManager()
        let imgUrl: URL! = URL(string: "https://openweathermap.org/img/wn/\(weatherIconName)@2x.png")
        var resultImg: UIImage? = nil
     
        weatherDataManager.pullData(url: imgUrl) { (data: Data?) in
            if let data = data {
                resultImg = UIImage(data: data)
                self.weatherIconImg = resultImg
                
                // store in cache
                self.cache.set(object: NSData(data: data), forKey: weatherIconName)
            }
        }
        
        
    }
}

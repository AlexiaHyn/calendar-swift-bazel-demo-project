//
//  WeatherIconView.swift
//  calendarDemoApp
//
//  Created by Alexia Huang on 2024/12/3.
//

import SwiftUI

struct WeatherIconView: View {
    @ObservedObject var weatherIconLoader = WeatherIconLoader()
    @Binding var mainColor: Color
    private let weatherIconName: String
    
    public init(weatherIconName: String, mainColor: Binding<Color>) {
        self.weatherIconName = weatherIconName
        self._mainColor = mainColor
        weatherIconLoader.loadWeatherIcons(weatherIconName: weatherIconName)
    }
    
    var body: some View {
        if let icon = weatherIconLoader.weatherIconImg {
            Image(uiImage: icon)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .shadow(color: mainColor, radius: 2, x: 0, y: 0)
                .padding(.leading, 2)
        } else {
            ProgressView()
                .frame(width: 20, height: 20)
        }
    }
}

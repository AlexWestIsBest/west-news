//
//  ActualAlarm.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/5/23.
//

import SwiftUI
import CoreLocation
import WeatherKit
import UIKit
import CoreImage
import CoreGraphics

struct ActualAlarm: View {
    @Binding var actualAlarmModal: Bool
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var loc = LocationManager()

    @AppStorage("isAlarmSet") private var isAlarmSet: Bool = false
    
    @State private var weatherString = ""
    
    var body: some View {
        VStack {
            Button(action: {
                isAlarmSet = false
                actualAlarmModal = false
                tap.selectionChanged()
                tap.prepare()
            }) {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing, .top], 6)
            }
            
            Text("Good Morning!")
                .font(.largeTitle)
                .fontWeight(.black)
                .tracking(-1)
                .allowsTightening(true)
                .lineLimit(1)
                .padding(.bottom, 8)
            
            AsyncImage(url: URL(string: "https://cdn.star.nesdis.noaa.gov/GOES16/ABI/CONUS/GEOCOLOR/1250x750.jpg")) { image in
                image.resizable()
            } placeholder: {
                ZStack {
                    Color(.systemGray5)
                        .aspectRatio(1250.0 / 750.0, contentMode: .fit)
                    ProgressView()
                }
            }
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            
            MediaPlayer(autoPlay: true, todaysIsTrueLatestIsFalse: true)
            
            Text("It's \(getFormattedDate()). \(weatherString)")
                .padding(.bottom)
                .task {
                    if let weatherData = await getAllWeather() {
                        weatherString = formatWeatherString(weatherData: weatherData)
                    }
                }
            Spacer()
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .inset(by: 3) // Half the stroke width
                .stroke(LinearGradient(gradient: Gradient(colors: [.accentColor, .accentColor.opacity(0)]), startPoint: .top, endPoint: .bottom), lineWidth: 6)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // FUNCTIONS
    
    private func getFormattedDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE, MMMM"
        let weekdayAndMonth = dateFormatter.string(from: date)
        
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let dayOrdinal = numberFormatter.string(from: NSNumber(value: dayOfMonth)) ?? ""
        
        let dateString = "\(weekdayAndMonth) \(dayOrdinal)"
        
        return dateString
    }

    
    private func getAllWeather() async -> Weather? {
        let weatherService = WeatherService()
        let lastSavedLocation = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await weatherService.weather(for: lastSavedLocation)
            return forecast
        }.value
        
        return currentWeather
    }
    
    private func formatWeatherString(weatherData: Weather) -> String {
        // Note: Come back in a future update and create a switch/case for all available weather conditions
        // 'clear' becomes 'sunny'
        // 'rain' becomes 'rainy'
        // 'thunderstorms' becomes 'stormy'
        // 'blizzard' becomes 'Brr!-icane'
        // enum available here: https://developer.apple.com/documentation/weatherkit/weathercondition
        
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        
        // Get CurrentWeather from weatherData
        let currentCondition: String = weatherData.currentWeather.condition.description.lowercased()
        let currentTempRaw = weatherData.currentWeather.temperature
        let currentTemp = formatter.string(from: currentTempRaw).dropLast()

        // Get DayWeather from weatherData
        let todayWeather = weatherData.dailyForecast.forecast.first
        let dayCondition: String = todayWeather?.condition.description.lowercased() ?? ""
        let dayHighTempRaw = (todayWeather?.highTemperature)!
        let dayHighTemp = formatter.string(from: dayHighTempRaw).dropLast()
                
        // Return formatted weatherString
        if currentCondition == dayCondition {
            if currentTemp == dayHighTemp {
                return "It's \(currentCondition) all day and currently \(currentTemp)."
            } else {
                return "It's \(currentCondition) and \(currentTemp), reaching \(dayHighTemp) this afternoon."
            }
        } else {
            if currentTemp == dayHighTemp {
                return "It's currently \(currentCondition) and \(currentTemp), becoming \(dayCondition) this afternoon."
            } else {
                return "It's currently \(currentCondition) and \(currentTemp), becoming \(dayHighTemp) and \(dayCondition) this afternoon."
            }
        }
    }
}

struct ActualAlarm_Previews: PreviewProvider {
    static var previews: some View {
        ActualAlarm(actualAlarmModal: .constant(true))
    }
}

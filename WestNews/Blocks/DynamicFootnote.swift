//
//  DynamicFootnote.swift
//  WestNews
//
//  Created by Alex Westerlund on 7/2/23.
//

import SwiftUI

struct DynamicFootnote: View {
    @Binding var alarmTime: Date
    
    @AppStorage("nightstandMode") private var nightstandMode: Bool = true

    var body: some View {
        if nightstandMode {
            let (warning, message) = nightstandFootnoteText()
            
            Text("\(Text(warning)) \(Text(message))")
                .font(.footnote)
                .foregroundColor(Color(.systemGray3))
                .padding(.horizontal, 10)
                .padding(.bottom)
        } else {
            let (warning, message) = notNightstandFootnoteText()
            
            Text("\(Text(warning)) \(Text(message))")
                .font(.footnote)
                .foregroundColor(Color(.systemGray3))
                .padding(.horizontal, 10)
                .padding(.bottom)
        }
    }
    
    // Functions
    
    func nightstandFootnoteText() -> (warning: String, message: String) {
        var warning = ""
        var message = "Your alarm will instead play a friendly tune."
        
        if isLaterTodayWeekendAlarm() {
            warning = "There is no scheduled broadcast today."
        } else if isSaturdayAlarm() {
            warning = "Saturday does not have a scheduled broadcast."
        } else if isSundayAlarm() {
            warning = "Sunday does not have a scheduled broadcast."
        } else if timeIsBeforeHourET(hour: 6) {
            warning = "Broadcasts are recorded between 6am and 6:45am ET."
        } else if timeIsBeforeHourET(hour: 7) {
            warning = "Broadcasts are recorded between 6am and 6:45am ET."
            message = "Your alarm MAY play a friendly tune if the broadcast isn’t ready yet."
        }
        
        // Default footnote
        if warning == "" {
            warning = "Broadcasts air Monday through Friday."
            message = "When one isn't available, the alarm will play a friendly tune."
        }
        
        return (warning, message)
    }
    
    func notNightstandFootnoteText() -> (warning: String, message: String) {
        var warning = ""
        var message = "Tapping the notification will play music instead."
        
        if isLaterTodayWeekendAlarm() {
            warning = "There is no scheduled broadcast today."
        } else if isSaturdayAlarm() {
            warning = "Saturday does not have a scheduled broadcast."
        } else if isSundayAlarm() {
            warning = "Sunday does not have a scheduled broadcast."
        } else if timeIsBeforeHourET(hour: 6) {
            warning = "Broadcasts are recorded between 6am and 6:45am ET."
        } else if timeIsBeforeHourET(hour: 7) {
            warning = "Broadcasts are recorded between 6am and 6:45am ET."
            message = "Tapping the notification MAY play music instead."
        }
        
        // Default footnote
        if warning == "" {
            warning = "Your alarm will play a 30-second greeting to wake you up."
            message = "The full show plays when you tap the notification."
        }
        
        return (warning, message)
    }

    // Returns true if the alarm is before said US Eastern Time hour
    private func timeIsBeforeHourET(hour: Int) -> Bool {
        let alarmInLocalTime = alarmTime
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let alarmDateOnlyString = formatter.string(from: alarmInLocalTime)
        let alarmETDateString = "\(alarmDateOnlyString)T\(String(format: "%02d", hour)):00:00"
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        
        if let alarmET = formatter.date(from: alarmETDateString) {
            if alarmInLocalTime < alarmET {
                return true
            }
        }
        
        return false
    }
    
    // Returns true if today is Saturday/Sunday AND the alarm will go off later today.
    private func isLaterTodayWeekendAlarm() -> Bool {
        let alarmInLocalTime = alarmTime
        let calendar = Calendar.current

        let todayWeekday = calendar.component(.weekday, from: Date())
        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())
        let alarmHour = calendar.component(.hour, from: alarmInLocalTime)
        let alarmMinute = calendar.component(.minute, from: alarmInLocalTime)
        
        if todayWeekday == 7 && (alarmHour > currentHour || (alarmHour == currentHour && alarmMinute > currentMinute)) {
            return true
        }
        if todayWeekday == 1 && (alarmHour > currentHour || (alarmHour == currentHour && alarmMinute > currentMinute)) {
            return true
        }
        
        return false
    }
    
    // Returns true if the alarm will go off tomorrow, Saturday
    private func isSaturdayAlarm() -> Bool {
        let alarmInLocalTime = alarmTime
        let calendar = Calendar.current

        let todayWeekday = calendar.component(.weekday, from: Date())
        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())
        let alarmHour = calendar.component(.hour, from: alarmInLocalTime)
        let alarmMinute = calendar.component(.minute, from: alarmInLocalTime)
        
        if todayWeekday == 6 && (alarmHour < currentHour || (alarmHour == currentHour && alarmMinute < currentMinute)) {
            return true
        }
        
        return false
    }

    // Returns true if the alarm will go off tomorrow, Sunday
    private func isSundayAlarm() -> Bool {
        let alarmInLocalTime = alarmTime
        let calendar = Calendar.current

        let todayWeekday = calendar.component(.weekday, from: Date())
        let currentHour = calendar.component(.hour, from: Date())
        let currentMinute = calendar.component(.minute, from: Date())
        let alarmHour = calendar.component(.hour, from: alarmInLocalTime)
        let alarmMinute = calendar.component(.minute, from: alarmInLocalTime)
        
        if todayWeekday == 7 && (alarmHour < currentHour || (alarmHour == currentHour && alarmMinute < currentMinute)) {
            return true
        }
        
        return false
    }
}

struct DynamicFootnote_Previews: PreviewProvider {
    static var previews: some View {
        DynamicFootnote(alarmTime: .constant(Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())!))
    }
}

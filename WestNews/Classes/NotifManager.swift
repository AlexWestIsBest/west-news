//
//  NotifManager.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/8/23.
//

import SwiftUI

class NotifManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    // Somehow the secret to opening the app AND a modal within it from a notification
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
        
    // Requests permissions
    func requestPermissions(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Handles how the app receives the alarm when you tap on it
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let link = response.notification.request.content.userInfo["link"] as? String, let url = URL(string: link) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        completionHandler()
    }
    
    // Handles how the app receives the alarm when the app is already in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let link = notification.request.content.userInfo["link"] as? String, let url = URL(string: link) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        completionHandler([])
    }
    
    // Builds and submits the alarm notification to system
    func scheduleAlarmNotification(alarmTime: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["alarm"])
        
        // Corrects alarmTime's calendar date
        let currentDate = Date()
        let calendar = Calendar.current
        var alarmDate = alarmTime
        while alarmDate < currentDate {
            alarmDate = calendar.date(byAdding: .day, value: 1, to: alarmDate) ?? alarmDate
        }
        
        let content = UNMutableNotificationContent()
        let (title, body) = getTitleAndBody(alarmDate: alarmDate)
        content.title = title
        content.body = body
        content.sound = getSound(alarmDate: alarmDate)
        content.userInfo = ["link": "westnews://alarm"]
        
        let alarmDateComponents = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: alarmDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled sucessfully")
            }
        }
    }
    
    
    
    // MARK: All the notification content constructors
    
    // Returns the hidden skin tone to modify yellow emojis
    func skinTone() -> String {
        @AppStorage("skinTone") var skinTone: Int = 1
        let skinToneModifiers = ["", "\u{1F3FB}", "\u{1F3FC}", "\u{1F3FD}", "\u{1F3FE}", "\u{1F3FF}"]
        return skinToneModifiers[skinTone]
    }
    
    // Gets title and body content based on if it's the user's birthday, on a holiday, or based on the weekday (default)
    func getTitleAndBody(alarmDate: Date) -> (title: String, message: String) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: alarmDate)
        let day = calendar.component(.day, from: alarmDate)
        
        var title = ""
        var body = ""
        
        (title, body) = isOnBirthday(currentMonth: month, currentDay: day)
        if title.isEmpty || body.isEmpty {
            (title, body) = isOnHoliday(currentMonth: month, currentDay: day)
        }
        if title.isEmpty || body.isEmpty {
            let weekday = calendar.component(.weekday, from: alarmDate)
            (title, body) = isOnWeekday(weekday: weekday)
        }
        
        return (title, body)
    }
    
    // Returns title and body if alarm is on user's birthday
    func isOnBirthday(currentMonth: Int, currentDay: Int) -> (title: String, message: String) {
        @AppStorage("birthdayYear") var birthdayYear: Int = 2000
        @AppStorage("birthdayMonth") var birthdayMonth: Int = 1
        @AppStorage("birthdayDay") var birthdayDay: Int = 1
        @AppStorage("sex") var sex: String = Sex.none.rawValue

        var title = ""
        var body = ""

        if currentMonth == birthdayMonth && currentDay == birthdayDay {
            let currentYear = Calendar.current.component(.year, from: Date())
            let age = currentYear - birthdayYear
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .ordinal
            let ageOrdinal = numberFormatter.string(from: NSNumber(value: age)) ?? ""
            
            title = sex == "female" ? "\u{1F469}\(skinTone()) Happy \(ageOrdinal) birthday!" : "\u{1F468}\(skinTone()) Happy \(ageOrdinal) birthday!"
            body = "You are today's top news. Celebrate!"
        }
        
        return (title, body)
    }
    
    // Returns title and body if alarm is on holiday
    func isOnHoliday(currentMonth: Int, currentDay: Int) -> (title: String, message: String) {
        @AppStorage("sex") var sex: String = Sex.none.rawValue
        var title = ""
        var body = ""
        
        switch currentMonth {
        case 1: // January
            switch currentDay {
            case 1:
                title = "\u{0032}\u{FE0F}\u{20E3}\u{0030}\u{FE0F}\u{20E3}\u{0032}\u{FE0F}\u{20E3}\u{0033}\u{FE0F}\u{20E3} It's January!"
                body = "A new year has begun."
            case 16: // Dynamic
                title = "\u{1F468}\u{1F3FF}\u{200D}\u{1F9B1} It's Martin Luther King Jr Day!"
                body = "Celebrate America's greatest civil rights activist."
//            case 16:
//                title = sex == "female" ? "\u{1F3C3}\(skinTone())\u{200D}\u{2640}\u{FE0F} It's Blue Monday" : "\u{1F3C3}\(skinTone())\u{200D}\u{2642}\u{FE0F} It's Blue Monday"
//                body = "Keep up your New Years Resolution!"
            case 22: // Dynamic
                title = "\u{1F9E7} It's Chinese New Year!"
                body = "Today the Chinese-American community celebrate the lunar new year."
            default:
                break
            }
        case 2: // February
            switch currentDay {
            case 1:
                title = "\u{1F9E3} It's February!"
                body = "Bundle up, it's cold out there."
            case 14:
                title = "\u{1F495} It's Valentine's Day!"
                body = "Spend time with your loved one."
            case 20: // Dynamic
                title = "\u{1F1FA}\u{1F1F8} It's President's Day"
                body = "Celebrate the 45 presidents since 1792"
            default:
                break
            }
        case 3: // March
            switch currentDay {
            case 1:
                let randomNumber = Int.random(in: 1...20)
                title = randomNumber == 20 ? "\u{1F340} It's March!" : "\u{2618}\u{FE0F} It's March!"
                body = randomNumber == 20 ? "You found a four-leaf clover!" : "Spring is coming."
            case 7: // Dynamic
                title = "\u{1F3A8} It's Holi!"
                body = "Wear your most colorful clothing for the Hindu Festival of Color!"
            case 17:
                title = "\u{2618}\u{FE0F} It's St. Patrick's Day!"
                body = "Wear something green today!"
            case 20: // Dynamic
                title = "\u{1F337} It's the spring equinox!"
                body = "Today is known as the first day of spring."
            default:
                break
            }
        case 4: // MARCH
            switch currentDay {
            case 1: // Change to April Fool's joke
                title = "\u{1F326} It's April!"
                body = "April showers bring May flowers."
            case 9: // Dynamic
                title = "\u{1F423} Happy Easter!"
                body = "Celebrate the Christian holiday."
            case 21: // Dynamic
                title = "\u{1F319} It's Eid al-Fitr!"
                body = "Celebrate the end of the Muslim holy month of Ramadan."
            default:
                break
            }
        case 5: // APRIL
            switch currentDay {
            case 1:
                title = "\u{1F338} It's May!"
                body = "Flowers are blooming everywhere."
            case 5:
                title = "\u{1F1F2}\u{1F1FD} It's Cinco De Mayo!"
                body = "Embrace Mexican culture today."
            case 14: // Dynamic
                title = "\u{1F469}\(skinTone()) It's Mother's Day!"
                body = "Thank your mom for all the work she's done to raise you."
            case 29: // Dynamic
                title = "\u{1F1FA}\u{1F1F8} It's Memorial Day!"
                body = "Honor the women and men in uniform."
            default:
                break
            }
        case 6: // JUNE
            switch currentDay {
            case 1:
                title = "\u{2600}\u{FE0F} It's June!"
                body = "Summer is here."
            case 18:
                title = "\u{1F468}\(skinTone()) It's Father's Day!"
                body = "Thank your dad for all the work he's done to raise you."
            case 19: // This emoji is broken- supposed to be a white hand + black hand handshake 
                title = "\u{1FAC1}\u{1F3FC}\u{200D}\u{1FAC2}\u{1F3FF} It's Juneteenth!"
                body = "Today in 1865, the last American slaves were freed."
            case 21: // Dynamic
                title = "\u{2600}\u{FE0F} It's the summer solstice!"
                body = "Today is the longest day of the year."
            default:
                break
            }
        case 7: // JULY
            switch currentDay {
            case 1:
                title = "\u{1F386} It's July!"
                body = "Fireworks and barbecues await."
            case 4:
                title = "\u{1F1FA}\u{1F1F8} It's Independence Day!"
                body = "Today in 1776, America's 13 colonies declared independence from Britain."
            case 26:
                title = sex == "female" ? "\u{1F469}\u{200D}\u{1F9BD}\(skinTone()) Celebrate Disabilities!" : "\u{1F468}\u{200D}\u{1F9BD}\(skinTone()) Celebrate Disabilities!"
                body = "Today in 1990, the Americans with Disabilities Act was passed."
            default:
                break
            }
        case 8: // AUGUST
            switch currentDay {
            case 1:
                title = "\u{1F3D6}\u{FE0F} It's August!"
                body = "Grab that beach towel and hit the sand."
            case 12:
                title = sex == "female" ? "\u{1F469}\(skinTone())\u{200D}\u{1F680} See a shooting star!" : "\u{1F468}\(skinTone())\u{200D}\u{1F680} See a shooting star!"
                body = "Turn off your porch lights and watch the Perseid meteor shower tonight."
            default:
                break
            }
        case 9: // SEPTEMBER
            switch currentDay {
            case 1:
                title = "\u{1F34E} It's September!"
                body = "Fall is just around the corner."
            case 4: // Dynamic
                title = sex == "female" ? "\u{1F469}\(skinTone())\u{200D}\u{1F3ED} It's Labor Day!" : "\u{1F468}\(skinTone())\u{200D}\u{1F3ED} It's Labor Day!"
                body = "Spend today with your family."
            case 11:
                title = sex == "female" ? "\u{1F469}\(skinTone())\u{200D}\u{1F692} It's September 11th" : "\u{1F468}\(skinTone())\u{200D}\u{1F692} It's September 11th"
                body = "Remember the lives lost in the attack on New York City's Twin Towers."
            case 23: // Dynamic
                title = "\u{1F342} It's the fall equinox!"
                body = "Today is known as the first day of fall."
            default:
                break
            }
        case 10: // OCTOBER
            switch currentDay {
            case 1:
                title = "\u{1F383} It's October!"
                body = "Bring on the hot apple cider."
            case 9: // Dynamic
                title = "\u{26F5}\u{FE0F} It's Columbus Day!"
                body = "Today in 1492, the first European explorer set foot in the Americas."
            case 31:
                title = sex == "female" ? "\u{1F9DB}\(skinTone())\u{200D}\u{2640}\u{FE0F} It's Halloween!" : "\u{1F9DB}\(skinTone())\u{200D}\u{2642}\u{FE0F} It's Halloween!"
                body = "Wear something orange today!"
            default:
                break
            }
        case 11: // NOVEMBER
            switch currentDay {
            case 1:
                title = "\u{1F342} It's November!"
                body = "Autumn leaves and pumpkin pie please."
            case 11:
                title = "\u{1F1FA}\u{1F1F8} It's Veteran's Day!"
                body = "Thank America's veterans for their service."
            case 12:
                title = "\u{1FA94} It's Diwali!"
                body = "The Hindu festival of lights is today."
            case 23: // Dynamic
                title = "\u{1F983} It's Thanksgiving!"
                body = "Gobble up a hearty meal with your family."
            case 24: // Dynamic
                title = "\u{1F6CD}\u{FE0F} It's Black Friday!"
                body = "Buy something special for yourself!"
            case 25: // Dynamic
                title = "\u{1F3EC} It's Small Business Saturday!"
                body = "Support strong towns and buy from a small business."
            case 27: // Dynamic
                title = "\u{1F5A5}\u{FE0F} It's Cyber Monday!"
                body = "Find a deal on your favorite website."
            case 28: // Dynamic
                title = "\u{1F932}\(skinTone()) It's Giving Tuesday!"
                body = "Find a local charity and support someone in need."
            default:
                break
            }
        case 12: // DECEMBER
            switch currentDay {
            case 1:
                title = "\u{2603}\u{FE0F} It's December!"
                body = "Holiday season is upon us."
            case 7:
                title = "\u{1F1FA}\u{1F1F8} It's Pearl Harbor Day!"
                body = "Today in 1941, America's Pearl Harbor was attacked by Imperial Japan."
            case 17:
                title = sex == "female" ? "\u{1F469}\(skinTone())\u{200D}\u{2708}\u{FE0F} Celebrate flight!" : "\u{1F468}\(skinTone())\u{200D}\u{2708}\u{FE0F} Celebrate flight!"
                body = "Today in 1903, Ohio's Wright Brothers flew the first steerable plane."
            case 21: // Dynamic
                title = "\u{2600}\u{FE0F} It's the winter solstice!"
                body = "Today is the shortest day of the year."
            case 24:
                title = "\u{1F384} It's Christmas Eve!"
                body = "Gather with your family and enjoy a meal."
            case 25:
                title = sex == "female" ? "\u{1F936}\(skinTone()) Merry Christmas!" : "\u{1F385}\(skinTone()) Merry Christmas!"
                body = "Celebrate this time with your friends and family."
            case 31:
                title = sex == "female" ? "\u{1F483}\(skinTone()) It's New Year's Eve!" : "\u{1F57A}\(skinTone()) It's New Years Eve!"
                body = "Make sure you've got some goals written down."
            default:
                break
            }
        default:
            break
        }
        
        return (title, body)
    }
    
    // Returns title and body based on day of week
    func isOnWeekday(weekday: Int) -> (title: String, message: String) {
        var title = ""
        var body = ""

        switch weekday {
        case 1: // Sunday
            title = "\u{1F4FB} Good morning!"
            body = "Tap to hear some Sunday tunes."
        case 2: // Monday
            title = "\u{1F44B}\(skinTone()) Good morning!"
            body = "Tap to hear your Monday news."
        case 3: // Tuesday
            title = "\u{1F44B}\(skinTone()) Good morning!"
            body = "Tap to hear your Tuesday news."
        case 4: // Wednesday
            title = "\u{1F44B}\(skinTone()) Good morning!"
            body = "Tap to hear your Wednesday news."
        case 5: // Thursday
            title = "\u{1F44B}\(skinTone()) Good morning!"
            body = "Tap to hear your Thursday news."
        case 6: // Friday
            title = "\u{1F44B}\(skinTone()) Good morning!"
            body = "Tap to hear your Friday news."
        case 7: // Saturday
            title = "\u{1F4FB} Good morning!"
            body = "Tap to hear some Saturday tunes."
        default:
            break
        }

        return (title, body)
    }
    
    
    
    // Returns a notification sound for alarm
    func getSound(alarmDate: Date) -> UNNotificationSound {
        @AppStorage("birthdayMonth") var birthdayMonth: Int = 1
        @AppStorage("birthdayDay") var birthdayDay: Int = 1
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: alarmDate)
        let day = calendar.component(.day, from: alarmDate)
        
        let soundFile: String

        if month == birthdayMonth && day == birthdayDay {
            soundFile = "Birthday.caf"
        } else if timeIsBeforeHourET(alarmDate: alarmDate, hour: 7) {
            soundFile = "Before7am.caf"
        } else {
            let dayOfWeek = calendar.component(.weekday, from: alarmDate)
            switch dayOfWeek {
            case 1:
                soundFile = "Sunday.caf"
            case 2:
                soundFile = "Monday.caf"
            case 3:
                soundFile = "Tuesday.caf"
            case 4:
                soundFile = "Wednesday.caf"
            case 5:
                soundFile = "Thursday.caf"
            case 6:
                soundFile = "Friday.caf"
            case 7:
                soundFile = "Saturday.caf"
            default:
                soundFile = "Monday.caf"
            }
        }

        return UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFile))
    }
    
    // Returns true if alarm time is before broadcast is published
    // Copied+modified from FootnoteHelper
    func timeIsBeforeHourET(alarmDate: Date, hour: Int) -> Bool {
        let alarmInLocalTime = alarmDate
        
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
}

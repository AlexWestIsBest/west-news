//
//  AlarmBuilder.swift
//  WestNews
//
//  Created by Alex Westerlund on 7/2/23.
//

import SwiftUI

struct AlarmBuilder: View {
    @Binding var actualAlarmModal: Bool
    let notifManager = NotifManager()
    @StateObject private var loc = LocationManager()
    let tap = UISelectionFeedbackGenerator()

    @AppStorage("isAlarmSet") internal var isAlarmSet: Bool = false
    @AppStorage("nightstandMode") private var nightstandMode: Bool = true
    
    @State internal var permissionGranted: Bool = false
    @State internal var alarmTime: Date = UserDefaults.standard.object(forKey: "storedAlarm") as? Date ?? Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()
    @State internal var showAlert: Bool = false
    
    @State private var nightstandModal: Bool = false

    var body: some View {
        VStack {
            // MARK: Picker wheel
            ZStack {
                DatePicker("Alarm time", selection: Binding(get: { self.alarmTime }, set: { newValue in
                    self.alarmTime = newValue
                    self.isAlarmSet = false
                }),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                if isAlarmSet == true {
                    HStack {
                        Spacer()
                            .frame(width: 190)
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .imageScale(.medium)
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 1)
                    }
                }
            }
            
            // MARK: Alarm button
            Button(action: {
                tap.selectionChanged()
                tap.prepare()
                isAlarmSet.toggle()
                UserDefaults.standard.set(alarmTime, forKey: "storedAlarm")
                attemptToSetAlarm()
            }) {
                HStack {
                    Text(isAlarmSet ? "Alarm is Set" : "Set Alarm")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    if isAlarmSet {
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .imageScale(.medium)
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isAlarmSet ? Color(.systemGray3) : Color("AccentColorButDarker"))
                .cornerRadius(12)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Enable Notifications"),
                    message: Text("Open Settings and enable notifications for this app."),
                    primaryButton: .default(Text("Open Settings"), action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }),
                    secondaryButton: .cancel()
                )
            }
            
            // MARK: Footnote
            DynamicFootnote(alarmTime: $alarmTime)
                .fixedSize(horizontal: false, vertical: true)
        }
        .fullScreenCover(isPresented: $nightstandModal) {
            NightstandView(isAlarmSet: $isAlarmSet, alarmTime: $alarmTime, actualAlarmModal: $actualAlarmModal, nightstandModal: $nightstandModal)
        }
        .onAppear {
            checkAlarmState()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkAlarmState()
        }
    }
    
    // FUNCTIONS
    
    private func checkAlarmState() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            permissionGranted = settings.authorizationStatus == .authorized
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            isAlarmSet = requests.contains { $0.identifier == "alarm" }
        }
    }
    
    private func attemptToSetAlarm() {
        // Nightstand mode
        if isAlarmSet && nightstandMode {
            loc.requestLocationUpdate(manuallyInitiated: false) {
                nightstandModal = true
//                notifManager.scheduleAlarmNotification(alarmTime: alarmTime) // Redundancy if screen gets locked
            }
        }
        
        // Notification mode
        if isAlarmSet && !nightstandMode {
            notifManager.requestPermissions { success, error in
                if success { // Has or gets permission
                    permissionGranted = true // Refreshes set alarm button view
                    loc.requestLocationUpdate(manuallyInitiated: false) {
                        notifManager.scheduleAlarmNotification(alarmTime: alarmTime)
                    }
                } else {
                    isAlarmSet = false
                    
                    showAlert = true
                    print(error?.localizedDescription ?? "Unknown error")
                }
            }
        }
        
        // If on, turns off
        if !isAlarmSet {
            UserDefaults.standard.removeObject(forKey: "storedAlarm")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["alarm"])
        }
    }
}

struct AlarmBuilder_Previews: PreviewProvider {
    static var previews: some View {
        AlarmBuilder(actualAlarmModal: .constant(false))
    }
}

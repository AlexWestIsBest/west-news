//
//  NightstandView.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/4/23.
//

import SwiftUI
import Combine
import CoreMotion

struct NightstandView: View {
    @Binding var isAlarmSet: Bool
    @Binding var alarmTime: Date
    @Binding var actualAlarmModal: Bool
    @Binding var nightstandModal: Bool
    let tap = UISelectionFeedbackGenerator()

    @ObservedObject private var batteryStatus = BatteryStatus()

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var cancellable: AnyCancellable? = nil
    @State private var countdownString = ""
    @State private var opacity: Double = 1.0
    @State private var powerOpacity: Double = 1

    
    let motionManager = CMMotionManager()
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack {
                    Image(systemName: "lamp.table")
                        .imageScale(.small)
                    Image(systemName: "table.furniture")
                        .imageScale(.large)
                }
                
                Text("Place iPhone on nightstand")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 15)
                
                VStack(spacing: 16) {
                    Text("Screen dims automatically")
                    Text("Do not lock iPhone")
                }
                .foregroundColor(Color(.systemGray))
                Spacer()
                    .frame(height: 80)
                
                Button(action: {
                    tap.selectionChanged()
                    tap.prepare()
                    isAlarmSet = false
                    nightstandModal = false
                }) {
                    HStack {
                        Text("Alarm is Set")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "checkmark")
                            .fontWeight(.bold)
                            .imageScale(.medium)
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.26, green: 0.26, blue: 0.26))
                    .cornerRadius(12)
                }
                
                Text(countdownString)
                    .foregroundColor(Color(.systemGray))
                Spacer()
                
                VStack {
                    Text("Connect iPhone to power")
                        .padding(.bottom, 2)
                    Image(systemName: "arrow.down")
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 1, green: 1, blue: 0))
                }
                .opacity(powerOpacity)
                .onChange(of: batteryStatus.isPluggedIn) { newValue in
                    withAnimation(.easeInOut(duration: 1.5)) {
                        powerOpacity = batteryStatus.isPluggedIn ? 0 : 1
                    }
                }
                .onAppear {
                    powerOpacity = batteryStatus.isPluggedIn ? 0 : 1
                }
            }
            .padding()
            .fontWeight(.thin)
            .foregroundColor(.white)
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .opacity(opacity)
            .onReceive(timer) { _ in
                countdownString = timeRemaining(alarmTime)
                if countdownString == "Good Morning!" {
                    motionManager.stopAccelerometerUpdates()
                    UIApplication.shared.isIdleTimerDisabled = false
                    timer.upstream.connect().cancel()
                    isAlarmSet = false
                    nightstandModal = false
                    // Prevents rendering issue - allows HomePageView to load and THEN have the alarm modal pop up.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        actualAlarmModal = true
                    }
                }
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                startMonitoringDeviceMovement()
            }
            .onDisappear {
                motionManager.stopAccelerometerUpdates()
                timer.upstream.connect().cancel()
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    // FUNCTIONS
    
    private func timeRemaining(_ alarmTime: Date) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        var adjustedAlarmTime = alarmTime

        while adjustedAlarmTime < currentDate {
            // If alarm time is in the past, add 24 hours to it
            // Covers a weird bug that was saving the alarm time 1-2 days negative
            adjustedAlarmTime = calendar.date(byAdding: .day, value: 1, to: adjustedAlarmTime) ?? adjustedAlarmTime
        }

        let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: adjustedAlarmTime)

        guard let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return ""
        }
        
        if hours > 0 {
            return "Sleep for \(hours)h\(minutes)m"
        } else if minutes > 1 {
            return "Sleep for \(minutes) minutes"
        } else if minutes == 1 && seconds != 0 {
            return "Sleep for \(minutes) minute \(seconds) seconds"
        } else if minutes == 1 && seconds == 0 {
            return "Wake up in \(minutes) minute"
        } else if seconds > 0 {
            return "Wake up in \(seconds) seconds"
        } else {
            return "Good Morning!"
        }
    }
    
    private func startMonitoringDeviceMovement() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.5
            
            var prevX: Double = 0
            var prevY: Double = 0
            var prevZ: Double = 0
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { data, _ in
                guard let data = data else { return }
                
                let threshold: Double = 0.004
                                
                let deltaX = abs(prevX - data.acceleration.x)
                let deltaY = abs(prevY - data.acceleration.y)
                let deltaZ = abs(prevZ - data.acceleration.z)
//                print("X: \(deltaX), Y: \(deltaY), Z: \(deltaZ)")
                
                prevX = data.acceleration.x
                prevY = data.acceleration.y
                prevZ = data.acceleration.z
                                
                let isMoving = deltaX > threshold || deltaY > threshold || deltaZ > threshold
                
                if !isMoving {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        opacity = 0
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        opacity = 1
                    }
                }
            }
        }
    }
}

class BatteryStatus: ObservableObject {
    @Published var isPluggedIn: Bool = false
    
    init() {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        updateBatteryStatus()

        NotificationCenter.default.addObserver(self, selector: #selector(updateBatteryStatus), name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    
    @objc private func updateBatteryStatus() {
        let batteryState = UIDevice.current.batteryState
        isPluggedIn = batteryState == .charging || batteryState == .full
    }
}



struct NightstandView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDate = Calendar.current.date(byAdding: DateComponents(hour: 0, minute: 2, second: 5), to: Date()) ?? Date()
        NightstandView(isAlarmSet: .constant(true), alarmTime: .constant(sampleDate), actualAlarmModal: .constant(false), nightstandModal: .constant(true))
    }
}

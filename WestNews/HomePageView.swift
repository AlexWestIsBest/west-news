//
//  HomePageView.swift
//  WestNews
//
//  Created by Alex Westerlund on 3/30/23.
//

import SwiftUI

struct HomePageView: View {
    let notifManager = NotifManager() // Needed so the function which recieves links is available
    let tap = UISelectionFeedbackGenerator()
    
    @AppStorage("isSetupCompleted") private var isSetupCompleted: Bool = false
    
    @State private var actualAlarmModal: Bool = false
    
    @State private var hearLatestModal: Bool = false
    @State private var alarmSettingsModal: Bool = false
    @State private var myDescriptionModal: Bool = false

    var body: some View {
        if isSetupCompleted == false {
            SetupView()
        } else {
            VStack {
                // MARK: Upper Stuff
                HStack {
                    Image(systemName: "alarm")
                        .imageScale(.large)
                    // To test the Alarm
                    Button(action: {
                        tap.selectionChanged()
                        tap.prepare()
                        actualAlarmModal = true
                    }) {
                        Text("+ ")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $actualAlarmModal) {
                        ActualAlarm(actualAlarmModal: $actualAlarmModal)
                            .presentationDetents([.height(550)])
                            .presentationCornerRadius(24)
                            .interactiveDismissDisabled(true)
                    }
                    Image(systemName: "radio")
                        .imageScale(.large)
                }
                VStack {
                    Text("Set your alarm")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .tracking(-1)
                        .padding(.bottom)
                    Text("Monday through Friday, wake up with a short news radio show as your alarm.")
                }
                
                AlarmBuilder(actualAlarmModal: $actualAlarmModal)
                
                // MARK: Buttons
                // Share - Shares an app store line with "Here's that alarm app I was telling you about - LINK" via messaging apps ONLY
                // Reach me / Share Feedback - Our own in-house contact system allowing users to send one way feedback, pronunciation tips, news footage, "Hey David" videos, etc
                // Write a Review - Deep link opens the app store review page modal popup
                VStack {
                    HStack {
                        Spacer()
                        
                        Button("Hear a Broadcast") {
                            tap.selectionChanged()
                            tap.prepare()
                            hearLatestModal = true
                        }
                        .sheet(isPresented: $hearLatestModal) {
                            HearLatest(modalBoolean: $hearLatestModal)
                                .presentationDetents([.height(500)])
                                .presentationCornerRadius(18)
                        }
                        Spacer()
                        
                        Button("Alarm Settings") {
                            tap.selectionChanged()
                            tap.prepare()
                            alarmSettingsModal = true
                        }
                        .sheet(isPresented: $alarmSettingsModal) {
                            AlarmSettings(modalBoolean: $alarmSettingsModal)
                                .presentationDetents([.height(550)])
                                .presentationCornerRadius(18)
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Button("My Description") {
                            tap.selectionChanged()
                            tap.prepare()
                            myDescriptionModal = true
                        }
                        .sheet(isPresented: $myDescriptionModal) {
                            MyDescription(modalBoolean: $myDescriptionModal)
                                .presentationDetents([.height(460)])
                                .presentationCornerRadius(18)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding()
            .onAppear {
                tap.prepare()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                tap.prepare()
            }
            .onOpenURL { url in
                handleURL(url)
            }
        }
    }
    
    // FUNCTIONS
    
    private func handleURL(_ url: URL) {
        print("opening link")
        switch url.absoluteString {
        case "westnews://alarm":
            actualAlarmModal = true
        default:
            break
        }
    }
}



struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

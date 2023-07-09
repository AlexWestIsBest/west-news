//
//  AlarmSettings.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/5/23.
//

import SwiftUI

struct AlarmSettings: View {
    @Binding var modalBoolean: Bool
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("isAlarmSet") internal var isAlarmSet: Bool = false
    @AppStorage("nightstandMode") private var nightstandMode: Bool = true

    @State private var animatedWaveform: CGFloat = 0.0
    @State private var animatedBell: CGFloat = 0.0
    @State private var focusModeModal: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                tap.selectionChanged()
                tap.prepare()
                modalBoolean = false
            }) {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            HStack {
                Button(action: {
                    tap.selectionChanged()
                    tap.prepare()
                    nightstandMode = true
                }) {
                    VStack {
                        Text("Autoplay")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .tracking(-0.5)
                            .foregroundColor(Color(.label))
                            .opacity(nightstandMode ? 1 : 0.2)
                        HStack {
                            Image(systemName: "iphone")
                                .resizable()
                                .frame(width: 50, height: 100)
                                .padding(.leading, 8)
                                .fontWeight(.ultraLight)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(nightstandMode ? Color(.systemGray) : Color(.systemGray3), Color(.systemGray4))
                                .opacity(nightstandMode ? 1 : 0.6)
                            Image(systemName: "waveform", variableValue: nightstandMode ? animatedWaveform : 1)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                                .foregroundStyle(nightstandMode ? Color.accentColor : Color(.systemGray4))
                        }
                        Text("Plays full show at\nyour alarm time.")
                            .font(.footnote)
                            .foregroundColor(Color(.label))
                            .opacity(nightstandMode ? 1 : 0.2)
                        Image(systemName: nightstandMode ? "checkmark.circle.fill" : "circle")
                            .imageScale(.large)
                            .padding(.top, 1)
                            .foregroundColor(Color("AccentColorButDarker"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                Button(action: {
                    tap.selectionChanged()
                    tap.prepare()
                    nightstandMode = false
                }) {
                    VStack {
                        Text("Notify Me")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .tracking(-0.5)
                            .foregroundColor(Color(.label))
                            .opacity(nightstandMode ? 0.2 : 1)
                        HStack {
                            Image(systemName: "iphone")
                                .resizable()
                                .frame(width: 50, height: 100)
                                .padding(.leading, 8)
                                .fontWeight(.ultraLight)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(nightstandMode ? Color(.systemGray3) : Color(.systemGray), Color(.systemGray4))
                                .opacity(nightstandMode ? 0.6 : 1)
                            Image(systemName: "bell.and.waveform", variableValue: nightstandMode ? 1 : animatedBell)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                                .foregroundStyle(nightstandMode ? Color(.systemGray4) : Color.accentColor, nightstandMode ? Color(.systemGray4) : Color(.systemGray))
                        }
                        Text("Play a 30s intro. Tap\nnotification for more.")
                            .font(.footnote)
                            .foregroundColor(Color(.label))
                            .opacity(nightstandMode ? 0.2 : 1)
                        Image(systemName: nightstandMode ? "circle" : "checkmark.circle.fill")
                            .imageScale(.large)
                            .padding(.top, 1)
                            .foregroundColor(Color("AccentColorButDarker"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            .background(Color(.systemGray5))
            .cornerRadius(16)
            Spacer()
                .frame(height: 20)
            
            if nightstandMode {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(Text("**1.**").foregroundColor(Color.accentColor))  Select your alarm time")
                    Text("\(Text("**2.**").foregroundColor(Color.accentColor))  Tap \"Set Alarm\"")
                    Text("\(Text("**3.**").foregroundColor(Color.accentColor))  Place iPhone face-down on nightstand")
                }
                Text("You must keep app open in the foreground")
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray3))
                    .padding(.top, 1)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(Text("**1.**").foregroundColor(Color.accentColor))  Turn off iPhone's silent mode")
                    
                    VStack(alignment: .leading) {
                        Text("OPTIONAL: Turn on Do Not Disturb")
                        HStack {
                            Text("Note:")
                                .font(.footnote)
                            Button(action: {
                                tap.selectionChanged()
                                tap.prepare()
                                focusModeModal = true
                            }) {
                                Text("Tap me I'm important")
                                    .font(.footnote)
                            }
                            .sheet(isPresented: $focusModeModal) {
                                ScrollView {
                                    FocusModeView(focusModeModal: $focusModeModal)
                                }
                                .presentationBackground(Color(.systemGray6))
                            }
                        }
                    }
                    .padding(6)
                    .padding(.horizontal, 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .light ? .black : Color(.systemGray), lineWidth: 2)
                    )
                    .padding(.leading, 13)
                    
                    Text("\(Text("**2.**").foregroundColor(Color.accentColor))  Select your alarm time")
                    Text("\(Text("**3.**").foregroundColor(Color.accentColor))  Tap \"Set Alarm\"")

                }
                Text("You may freely close this app")
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray3))
                    .padding(.top, 1)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            animateWaveform()
            animateBell()
        }
        .onChange(of: nightstandMode) {newValue in
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["alarm"])
            isAlarmSet = false
        }
    }
    
    // FUNCTIONS
    
    private func animateWaveform() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            animatedWaveform += 0.166
            if animatedWaveform > 1.3 {
                animatedWaveform = 0.0
            }
        }
    }
    
    private func animateBell() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            animatedBell += 0.2
            if animatedBell > 1.5 {
                animatedBell = 0.0
                // Pause timer for 1.5 seconds
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    animateBell()
                }
            }
        }
    }
}



struct AlarmSettings_Previews: PreviewProvider {
    static var previews: some View {
        AlarmSettings(modalBoolean: .constant(true))
    }
}

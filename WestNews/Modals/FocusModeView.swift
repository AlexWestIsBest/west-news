//
//  FocusModeView.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/8/23.
//

import SwiftUI

struct FocusModeView: View {
    @Binding var focusModeModal: Bool
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                VStack {
                    Image("SettingsIcon")
                        .resizable()
                        .frame(width: 65, height: 65)
                    Text("Open Settings:")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .tracking(-0.5)
                }
                .padding(.top)
                .padding(.top)

                HStack {
                    Image(systemName: "moon.fill")
                        .imageScale(.small)
                        .padding(6)
                        .foregroundColor(.white)
                        .background(Color(.systemIndigo))
                        .cornerRadius(6)
                    Text("Focus \(Image(systemName: "arrow.forward")) Do Not Disturb \(Image(systemName: "arrow.forward")) Apps")
                }
                .padding(.bottom)
                .padding(.bottom)
                
                Text("1.  Select the second option")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    HStack {
                        Image(systemName: "bell.slash.fill")
                            .foregroundColor(Color(.systemGray2))
                            .frame(width: 25, height: 25)
                        Text("Silence Notifications From")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Divider()
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(.systemGreen))
                            .frame(width: 25, height: 25)
                        Text("Allow Notifications From")
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(.systemBlue))
                            .fontWeight(.bold)
                            .frame(width: 25, height: 25)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .padding(.vertical, 2)
                }
                .background(colorScheme == .light ? .white : .black)
                .cornerRadius(10)
                .padding(.bottom)
                
                Text("2.  Tap \"Add Apps\" and select Morning News")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VStack {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                        Text("Add Apps")
                            .font(.caption)
                    }
                    .foregroundColor(Color(.systemBlue))
                    
                    VStack {
                        Image("AppIcon2")
                            .resizable()
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray3), lineWidth: 0.2)
                            )
                        Text("Morning News")
                            .font(.caption)
                    }
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(12)
                .background(colorScheme == .light ? .white : .black)
                .cornerRadius(10)
                .padding(.bottom)
                
                Text("When you go to bed, un-silence iPhone by flipping the switch on the upper left side. Next, turn on Do Not Disturb mode. The changes you've made here allow your alarm to sound while keeping everything else still silent.")
                    .padding(.bottom)
                    .font(.footnote)
                
                Button(action: {
                    tap.selectionChanged()
                    tap.prepare()
                    focusModeModal = false
                }) {
                    Text("Finish")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemBlue))
                }
            }
            .padding()
        }
    }
}

struct FocusModeView_Previews: PreviewProvider {
    static var previews: some View {
        FocusModeView(focusModeModal: .constant(true))
    }
}

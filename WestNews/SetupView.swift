//
//  SetupView.swift
//  WestNews
//
//  Created by Alex Westerlund on 4/12/23.
//

import SwiftUI

struct SetupView: View {
    let tap = UISelectionFeedbackGenerator()
    @StateObject private var desc = DescriptionManager()
    @StateObject private var loc = LocationManager()

    @State private var showPage2: Bool = false
    @AppStorage("isSetupCompleted") private var isSetupCompleted: Bool = false
    
    @AppStorage("showWelcomeMessage") var showWelcomeMessage: Bool = true // Declared again here for View update purposes

    var body: some View {
        // MARK: Welcome Page
        if showPage2 == false {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "alarm")
                        .imageScale(.large)
                    Text(" + ")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                    Image(systemName: "radio")
                        .imageScale(.large)
                }
                
//                Text("Welcome to West News")
//                Text("West News Awaits")
                Text("News for Everyone")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .tracking(-1)
                    .allowsTightening(true)
                    .lineLimit(1)
                
//                Text("1,314 listeners and counting.") // API call that gets our DAU
//                Text("Everyone deserves great news.")
                Text("Wake up informed. Monday-Friday.")
                    .allowsTightening(true)
                    .lineLimit(1)
                                
                Image("Cornerstore")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical)
                    .saturation(1.05)
                
                Spacer()
                    .frame(height: 20)
                
                Button(action: {
                    tap.selectionChanged()
                    tap.prepare()
                    showPage2 = true
                    desc.showWelcomeMessage = true
                }) {
                    Image(systemName: "arrow.forward")
                        .foregroundColor(.clear)
                        .imageScale(.small)
                    Text("Get started")
                    Image(systemName: "arrow.forward")
                }
//                .font(.title3)
                .foregroundColor(.accentColor)

                Spacer()
            }
            .onAppear {
                tap.prepare()
            }
        }
        
        // MARK: Description
        else {
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        tap.selectionChanged()
                        tap.prepare()
                        desc.ethnicity = "Select ethnicity"
                        desc.skinTone = 1
                        desc.sex = "Select sex"
                        desc.day = 1
                        desc.month = 1
                        desc.year = 2000
                        desc.vote = "Select a party"
                        isSetupCompleted = true
                    }
                    .foregroundColor(showWelcomeMessage ? .clear : Color(.systemGray3))
                }
                Spacer()
                
                Image("NewspaperBench")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 20)
                
                Text("Describe yourself!")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .tracking(-1)
                    .allowsTightening(true)
                    .lineLimit(1)
                
                DescriptionBlock()
                
                HStack {
                    Button(action: {
                        tap.selectionChanged()
                        tap.prepare()
                        isSetupCompleted = true
                    }) {
                        Image(systemName: "arrow.forward")
                            .foregroundColor(.clear)
                            .imageScale(.small)
                        Text("Finish")
                        Image(systemName: "arrow.forward")
                    }
                    .foregroundColor(showWelcomeMessage ? .clear : .accentColor)
                    .padding()
                }
                Spacer()
            }
            .padding()
        }
    }
}



struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}

//
//  HearLatest.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/5/23.
//

import SwiftUI
import WeatherKit

struct HearLatest: View {
    @Binding var modalBoolean: Bool
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var attributionLink: URL? = URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")
    @State private var attributionLogo: URL? = nil

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
            Text("Latest Episode")
                .font(.largeTitle)
                .fontWeight(.black)
                .tracking(-1)
                .allowsTightening(true)
                .lineLimit(1)
                .padding(.bottom, 8)
            Text("Shows typically run \(Text("**3-6 minutes**").foregroundColor(Color.accentColor)). I'll often wrap them up with a fun fact or warm anecdote.")
                .padding(.bottom, 8)
            MediaPlayer(autoPlay: true, todaysIsTrueLatestIsFalse: false)
            
            Text("Included every show:")
                .font(.title3)
                .fontWeight(.heavy)
                .tracking(-0.5)
                .padding(.top, 10)
                .padding(.bottom, 4)
            VStack(alignment: .leading) {
                Text("\(Text("**\u{2013}**").foregroundColor(Color.accentColor)) Sports & Competition")
                Text("\(Text("**\u{2013}**").foregroundColor(Color.accentColor)) Entertainment & Culture")
                Text("\(Text("**\u{2013}**").foregroundColor(Color.accentColor)) Science & Technology")
                Text("\(Text("**\u{2013}**").foregroundColor(Color.accentColor)) Business & Markets")
                Text("\(Text("**\u{2013}**").foregroundColor(Color.accentColor)) Politics & World Affairs")
            }
            .padding(.bottom)
            .italic(true)
            
            Spacer()

            VStack {
                AsyncImage(url: attributionLogo, scale: 3) {image in
                    image
                } placeholder: {
                    Color.clear
                        .frame(width: 1, height: 1)
                }
                    .task {
                        do {
                            let attribution = try await WeatherService.shared.attribution
                            attributionLink = attribution.legalPageURL
                            attributionLogo = colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL
                        } catch {
                            print(error)
                        }
                    }
                Link("Other sources", destination: attributionLink!)
                    .font(.footnote)
            }
        }
        .padding()
    }
}

struct HearLatest_Previews: PreviewProvider {
    static var previews: some View {
        HearLatest(modalBoolean: .constant(true))
    }
}

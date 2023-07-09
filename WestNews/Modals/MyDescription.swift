//
//  MyDescription.swift
//  WestNews
//
//  Created by Alex Westerlund on 5/5/23.
//

import SwiftUI

struct MyDescription: View {
    @Binding var modalBoolean: Bool
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var desc = DescriptionManager()
    
    @AppStorage("skinTone") var skinTone: Int = 1 // Declared again here for View update purposes
    
    let femaleEmojis: [String] = ["\u{1F469}\u{1F3FB}", "\u{1F469}\u{1F3FC}", "\u{1F469}\u{1F3FD}", "\u{1F469}\u{1F3FE}", "\u{1F469}\u{1F3FF}"]
    let maleEmojis: [String] = ["\u{1F468}\u{1F3FB}", "\u{1F468}\u{1F3FC}", "\u{1F468}\u{1F3FD}", "\u{1F468}\u{1F3FE}", "\u{1F468}\u{1F3FF}"]
    
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
            
            LocationBlock()
            
            DescriptionBlock()
            
//            Text("Everyone deserves great news. We'll use this to measure the diversity of our audience.")
//            Text("Everyone deserves great news. We'll use this for audience metrics and personalization.")
//            Text("Everyone deserves great news. Descriptions help us ensure West News reaches people across the political aisle.")
            Text("Everyone deserves great news. We use descriptions to build a diverse audience.")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color(.systemGray3))
            Spacer()
                .frame(height: 16)
            
            if desc.sex != "Select sex" {
                HStack {
                    ForEach(0..<5) { index in
                        Button(action: {
                            desc.skinTone = index + 1
                        }) {
                            Text(desc.sex == "female" ? femaleEmojis[index] : maleEmojis[index])
                                .padding(8)
                                .background(skinTone == index + 1 ? Color(.systemGray5) : Color.clear)
                                .cornerRadius(12)
                        }
                    }
                }
                .font(.largeTitle)
            }
            Spacer()
        }
        .padding()
    }
}

struct MyDescription_Previews: PreviewProvider {
    static var previews: some View {
        MyDescription(modalBoolean: .constant(true))
    }
}

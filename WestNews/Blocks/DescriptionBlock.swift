//
//  DescriptionBlock.swift
//  WestNews
//
//  Created by Alex Westerlund on 4/19/23.
//

import SwiftUI

struct DescriptionBlock: View {
    let tap = UISelectionFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var desc = DescriptionManager()
    
    let vowels = "AEIOUaeiou"
    
    @State private var blur: CGFloat = 0
    @State private var birthday: Date = Date(timeIntervalSince1970: TimeInterval(946771200))
    @State private var popupCalendar: Bool = false

    let minimumDate = Calendar.current.date(from: DateComponents(year: 1907, month: 3, day: 4))!
    let maximumDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())!
    
    var formattedBirthday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter.string(from: birthday)
    }
        
    var selectedBirthday: Date {
        get {
            var components = DateComponents()
            components.year = desc.year
            components.month = desc.month
            components.day = desc.day
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
            desc.year = components.year ?? 2000
            desc.month = components.month ?? 1
            desc.day = components.day ?? 1
        }
    }

    var body: some View {
        VStack {
            ZStack {
                VStack(spacing: 4) {
                    // MARK: Row 1
                    HStack {
                        Text(vowels.contains(desc.ethnicity.first!) ? "I am an" : "I am a")
                        Picker("Ethnicity", selection: $desc.ethnicity) {
                            ForEach(Ethnicity.allCases, id: \.self) { ethnicity in
                                Text(ethnicity.rawValue).tag(ethnicity.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .fixedSize(horizontal: true, vertical: false)
                        .onChange(of: desc.ethnicity) { newEthnicity in
                            tap.selectionChanged()
                            tap.prepare()
                            setEmojiSkinTone(newEthnicity: newEthnicity)
                        }
                    }
                    
                    // MARK: Row 2
                    HStack {
                        Picker("Sex", selection: $desc.sex) {
                            ForEach(Sex.allCases.filter { $0 != .none }, id: \.self) { sex in
                                Text(sex.rawValue).tag(sex.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: desc.sex) { newSex in
                            tap.selectionChanged()
                            tap.prepare()
                        }
                        Text("born on")
                        Button(action: {
                            popupCalendar = true
                            tap.selectionChanged()
                            tap.prepare()
                        }) {
                            Text(formattedBirthday)
                                .padding(6)
                                .foregroundColor(Color(.label))
                                .background(colorScheme == .light ? Color(.systemGray5) : Color(.systemGray4))
                                .cornerRadius(6)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .sheet(isPresented: $popupCalendar) {
                            VStack {
                                DatePicker("Birthday", selection: $birthday, in: minimumDate...maximumDate, displayedComponents: .date)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .onChange(of: birthday) {newBirthday in
                                        let components = Calendar.current.dateComponents([.year, .month, .day], from: newBirthday)
                                        desc.year = components.year ?? 2000
                                        desc.month = components.month ?? 1
                                        desc.day = components.day ?? 1
                                        if calculateAge(birthday: newBirthday) < 18 {
                                            desc.age = calculateAge(birthday: newBirthday)
                                            desc.vote = "didn't vote"
                                        }
                                    }
                                Divider()
                                    .frame(width: 320)
                                Button(action: {
                                    popupCalendar = false
                                    tap.selectionChanged()
                                    tap.prepare()
                                }) {
                                    Text("Done")
                                        .fontWeight(.semibold)
                                        .frame(width: 320)
                                        .padding(.top, 6)
                                        .padding(.bottom)
                                }
                            }
                            .background(colorScheme == .light ? Color(.white) : Color(.systemGray5))
                            .cornerRadius(12)
                            .presentationDetents([.height(550)])
                            .presentationBackground(.clear)
                            .presentationBackgroundInteraction(.enabled)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Row 3
                    HStack {
                        Text(desc.vote == "didn't vote" ? "and I" : "and I voted")
                        Picker("Vote", selection: $desc.vote) {
                            ForEach(Vote.allCases, id: \.self) { vote in
                                Text(vote.rawValue).tag(vote.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .fixedSize(horizontal: true, vertical: false)
                        .disabled(calculateAge(birthday: birthday) < 18)
                        .onChange(of: desc.vote) { newVote in
                            tap.selectionChanged()
                            tap.prepare()
                        }
                    }
                    
                    // MARK: Row 4
                    HStack {
                        Text("in the last election.")
                            .padding(.top, 4)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity)
                .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemGray5))
                .blur(radius: blur)
                
                
                // MARK: Overlay
                if desc.showWelcomeMessage == true {
                    VStack {
                        Spacer()
                        Text("Solving political division starts with us finding an audience on both sides. Instead of an account, anonymously contribute your demographics.")
                            .padding(.horizontal)
                        Spacer()
                        Button(action: {
                            tap.selectionChanged()
                            tap.prepare()
                            desc.showWelcomeMessage = false
                            withAnimation {
                                blur = 0
                            }
                        }) {
                            Text("Got it")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .blur(radius: 10.0 - blur)
                    .opacity(blur / 10.0)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5))
                    )
                }
            }
            .cornerRadius(12)
            .fixedSize(horizontal: false, vertical: true)
        }
        .onAppear {
            if desc.showWelcomeMessage == true {
                withAnimation {
                    blur = 10
                }
            }
            var components = DateComponents()
            components.year = desc.year
            components.month = desc.month
            components.day = desc.day
            birthday = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    // FUNCTIONS
    
    private func setEmojiSkinTone(newEthnicity: String) {
        let ethnicity = Ethnicity(rawValue: newEthnicity)
        
        switch ethnicity {
        case .eastAsian:
            desc.skinTone = 1
        case .whiteOrCaucasian:
            desc.skinTone = 2
        case .americanIndian, .hispanicOrLatino, .middleEastern, .pacificIslander, .biracial, .multiracial:
            desc.skinTone = 3
        case .southAsian:
            desc.skinTone = 4
        case .blackOrAfricanDescent:
            desc.skinTone = 5
        default:
            desc.skinTone = 1
        }
    }

    private func calculateAge(birthday: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year ?? 0
    }
}



struct DescriptionBlock_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionBlock()
    }
}

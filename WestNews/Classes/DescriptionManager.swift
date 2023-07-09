//
//  DescriptionManager.swift
//  WestNews
//
//  Created by Alex Westerlund on 6/15/23.
//

import SwiftUI

class DescriptionManager: ObservableObject {
    @AppStorage("showWelcomeMessage") var showWelcomeMessage: Bool = true

    // Setup Page 2
    @AppStorage("ethnicity") var ethnicity: String = Ethnicity.none.rawValue
    @AppStorage("skinTone") var skinTone: Int = 1
    
    @AppStorage("birthdayAge") var age: Int = 0
    @AppStorage("birthdayYear") var year: Int = 2000
    @AppStorage("birthdayMonth") var month: Int = 1
    @AppStorage("birthdayDay") var day: Int = 1
    
    @AppStorage("sex") var sex: String = Sex.none.rawValue
    
    @AppStorage("vote") var vote: String = Vote.none.rawValue
}

enum Ethnicity: String, CaseIterable {
    case none = "Select ethnicity"
    case americanIndian = "American Indian"
    case blackOrAfricanDescent = "Black / African Descent"
    case eastAsian = "East Asian"
    case hispanicOrLatino = "Hispanic / Latino"
    case middleEastern = "Middle Eastern"
    case pacificIslander = "Pacific Islander"
    case southAsian = "South Asian"
    case whiteOrCaucasian = "White / Caucasian"
    case biracial = "Biracial"
    case multiracial = "Multiracial"
    
    var id: Ethnicity { self }
}

enum Sex: String, CaseIterable, Identifiable {
    case none = "Select sex"
    case female = "female"
    case male = "male"
    
    var id: Sex { self }
}

enum Vote: String, CaseIterable, Identifiable {
    case none = "Select a party"
    case stronglyDemocrat = "STRONGLY Democrat"
    case somewhatDemocrat = "somewhat Democrat"
    case somewhatRepublican = "somewhat Republican"
    case stronglyRepublican = "STRONGLY Republican"
    case thirdParty = "third party"
    case didntVote = "didn't vote"
    
    var id: Vote { self }
}

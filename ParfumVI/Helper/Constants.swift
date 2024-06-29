//
//  Constants.swift
//  ParfumVI
//
//  Created by 🐯 on 27/05/2024.
//

import SwiftUI



/// FUNDAMENTAL : DIMENSIONS
enum FundamentalDimensions: CGFloat {
    case corner             = 15
    case headerSpacing      = 3
    case headerTitleInset   = 10
}

/// FUNDAMENTAL : FONTS
struct FundamentalFonts {
    static let standard: String = "Rochester-Regular"
    static let rochester: String = "Rochester-Regular"
}

/// INGREDIENT : UNIT OF MEASURE
enum Unit: String, CaseIterable {
    case pipette, millilitre, tablespoon, gram, cup
    
    var caseName: String {
        switch self {
        case .pipette       : return "Drops"
        case .millilitre    : return "Millilitre"
        case .tablespoon    : return "Tablespoon"
        case .gram          : return "Grams"
        case .cup           : return "Cup"
        }
    }

    var singular: String {
        switch self {
        case .pipette       : return "drop"
        case .millilitre    : return "ml"
        case .tablespoon    : return "tbsp"
        case .gram          : return "g"
        case .cup           : return "cup"
        }
    }

    var plural: String {
        switch self {
        case .pipette       : return "drops"
        case .millilitre    : return "ml"
        case .tablespoon    : return "tbsps"
        case .gram          : return "g"
        case .cup           : return "cups"
        }
    }

    // CHECK FOR PLURAL USAGE
    func name(for amount: Double) -> String {
        return amount == 1 ? self.singular : self.plural
    }
    
    // WORKAROUND : CONVERT CORE DATA STRING VALUES BACK INTO ENUM
    static func fromString(_ string: String) -> Unit? {
        switch string {
        case "Drops"        : return .pipette
        case "Millilitre"   : return .millilitre
        case "Tablespoon"   : return .tablespoon
        case "Grams"        : return .gram
        case "Cup"          : return .cup
        default             : return nil
        }
    }
}

/// INGREDIENT : PERIOD OF TIME
enum Period: CaseIterable {
    case hour, day, week
    
    var caseName: String {
        switch self {
        case .hour  : return "Hour"
        case .day   : return "Day"
        case .week  : return "Week"
        }
    }

    var singular: String {
        switch self {
        case .hour  : return "hour"
        case .day   : return "day"
        case .week  : return "week"
        }
    }

    var plural: String {
        switch self {
        case .hour  : return "hours"
        case .day   : return "days"
        case .week  : return "weeks"
        }
    }

    // CHECK FOR PLURAL USAGE BASED ON THE PERIOD AND AMOUNT
    static func name(for amount: Double, period: Period) -> String {
        return amount == 1 ? period.singular : period.plural
    }
    
    // WORKAROUND: CONVERT CORE DATA STRING VALUES BACK INTO ENUM
    static func fromString(_ string: String) -> Period? {
        switch string {
        case "hour", "hours" : return .hour
        case "day", "days"   : return .day
        case "week", "weeks" : return .week
        default              : return nil
        }
    }
    
    // WORKAROUND: CONVERT ENUM VALUES BACK INTO STRING
    static func fromEnum(_ period: Period) -> String {
        return period.singular // Using singular form as the base string representation
    }
}


/// EXPERIMENT : CURRENT STATUS
enum Status: String, CaseIterable {
    case tbd, pass, fail
    
    // WORKAROUND : CONVERT CORE DATA STRING VALUES BACK INTO ENUM
    static func fromString(_ string: String) -> Status? {
        switch string {
        case "tbd"  : return .tbd
        case "pass" : return .pass
        case "fail" : return .fail
        default     : return nil
        }
    }
    
    // WORKAROUND : CONVERT CORE DATA STRING VALUES BACK INTO ENUM
    static func fromEnum(_ string: Status) -> String? {
        switch string {
        case .tbd   : return "tbd"
        case .pass  : return "pass"
        case .fail  : return "fail"
        }
    }
}

/// ALTERNATIVE ICONS
enum AlternativeIcons: String {
    case primary            = "AppIcon"
    
    // LIGHT
    case firstMedleyLight   = "parfumBottleIconLightI"
    case secondMedleyLight  = "parfumBottleIconLightII"
    case thirdMedleyLight   = "parfumBottleIconLightIII"
    
    // DARK
    case firstMedleyDark    = "parfumBottleIconDarkI"
    case secondMedleyDark   = "parfumBottleIconDarkII"
    case thirdMedleyDark    = "parfumBottleIconDarkIII"
}

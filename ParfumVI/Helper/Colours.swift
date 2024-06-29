//
//  Colours.swift
//  ParfumVI
//
//  Created by 🐯 on 10/06/2024.
//


import SwiftUI



/// GLOBALLY VARIABLE TO CHANGE COLOUR PALETTE WITH SINGLE REFERENCE
class ColorManager: ObservableObject {
    static let shared = ColorManager()

    @Published var currentPalette = ColourPalettes.paletteB

    private init() {}
}

/// COLOUR PALETE : VIEW TYPES
enum ViewType: String {
    
    // TEXT
    case textForeground, textBackground
    
    // TEXTFIELD
    case textFieldForeground, textFieldBackground
    
    // TEXTFIELD w/BUTTON
    case textFieldButtonForeground,
         textFieldButtonBackground,
         textFieldButtonPropperForeground,
         textFieldButtonPropperBackground
    
    // BUTTON
    case buttonForeground, buttonForegroundAlert
    
    // STEPPER
    case stepperForeground, stepperBackground
    
    // TEXT FIELD HEADER
    case textFieldHeaderForeground
    
    // TILE
    case tileText, tileDivider, tileBackground
}

/// COLOUR PALETE : LIGHT & DARK MODE STRUCTURE
struct ColourPaletteStructure {
    let light   : UIColor
    let dark    : UIColor
}

/// COLOUR PALETTE : DEFINE COLOUR CATEGORIES
struct ColourPalette {
    let backgroundStandard          : ColourPaletteStructure
    let textFieldForegroundActive   : ColourPaletteStructure
    let textFieldForegroundInactive : ColourPaletteStructure
    let textFieldBackgroundActive   : ColourPaletteStructure
    let textFieldBackgroundInactive : ColourPaletteStructure
    let textAlert                   : ColourPaletteStructure
    let buttonActiveBodyTop         : ColourPaletteStructure
    let buttonActiveBodyBase        : ColourPaletteStructure
}

/// COLOUR PALETTE : DEFINE COLOURS FOR EACH PALETTE (USEFUL FOR TESTING)
struct ColourPalettes {

    // h/t : https://nightpalette.com/s/292c5b
    static let paletteA = ColourPalette(
        backgroundStandard          : ColourPaletteStructure(light  : UIColor(red: 237/255,     green: 241/255, blue: 250/255,  alpha: 1),
                                                             dark   : UIColor(red: 32/255,      green: 7/255,   blue: 17/255,   alpha: 1)),
        
        textFieldForegroundActive   : ColourPaletteStructure(light  : UIColor(red: 18/255,      green: 18/255,  blue: 18/255,   alpha: 1),
                                                             dark   : UIColor(red: 237/255,     green: 241/255, blue: 250/255,  alpha: 1)),
        
        textFieldForegroundInactive : ColourPaletteStructure(light  : UIColor(red: 128/255,     green: 128/255, blue: 128/255,  alpha: 0.4),
                                                             dark   : UIColor(red: 256/255,     green: 256/255, blue: 256/255,  alpha: 0.3)),

        textFieldBackgroundActive   : ColourPaletteStructure(light  : UIColor(red: 256/255,     green: 256/255, blue: 256/255,  alpha: 1),
                                                             dark   : UIColor(red: 80/255,      green: 7/255,   blue: 52/255,   alpha: 1)),
 
        textFieldBackgroundInactive : ColourPaletteStructure(light  : UIColor(red: 256/255,     green: 256/255, blue: 256/255,  alpha: 1),
                                                             dark   : UIColor(red: 80/255,      green: 7/255,   blue: 52/255,   alpha: 0.4)),
        
        textAlert                   : ColourPaletteStructure(light  : UIColor(red: 233/255,     green: 69/255,  blue: 90/255,   alpha: 1),  //  PINK
                                                             dark   : UIColor(red: 255/255,     green: 11/255,  blue: 134/255,  alpha: 0.8)),
        
        buttonActiveBodyTop         : ColourPaletteStructure(light  : UIColor(red: 251/255,     green: 240/255, blue: 238/255,  alpha: 1),
                                                             dark   : UIColor(red: 226/255,     green: 125/255, blue: 175/255,  alpha: 1)),
         
        buttonActiveBodyBase        : ColourPaletteStructure(light  : UIColor(red: 249/255,     green: 228/255, blue: 223/255,  alpha: 1),
                                                             dark   : UIColor(red: 226/255,     green: 125/255, blue: 175/255,  alpha: 1)))
    
    
    // h/t : https://nightpalette.com/s/292c5b
    static let paletteB = ColourPalette(
        backgroundStandard          : ColourPaletteStructure(light  : UIColor(red: 237/255,     green: 241/255, blue: 250/255,  alpha: 1),
                                                             dark   : UIColor(red: 18/255,      green: 18/255,  blue: 18/255,   alpha: 1)),
        
        textFieldForegroundActive   : ColourPaletteStructure(light  : UIColor(red: 18/255,      green: 18/255,  blue: 18/255,   alpha: 1),
                                                             dark   : UIColor(red: 237/255,     green: 241/255, blue: 250/255,  alpha: 1)),
        
        textFieldForegroundInactive : ColourPaletteStructure(light  : UIColor(red: 128/255,     green: 128/255, blue: 128/255,  alpha: 0.4),
                                                             dark   : UIColor(red: 256/255,     green: 256/255, blue: 256/255,  alpha: 0.4)),
        
        textFieldBackgroundActive   : ColourPaletteStructure(light  : UIColor(red: 256/255,     green: 256/255, blue: 256/255,  alpha: 1),
                                                             dark   : UIColor(red: 42/255,      green: 41/255,  blue: 41/255,   alpha: 1)),
 
        textFieldBackgroundInactive : ColourPaletteStructure(light  : UIColor(red: 256/255,     green: 256/255, blue: 256/255,  alpha: 1),
                                                             dark   : UIColor(red: 86/255,      green: 71/255,  blue: 174/255,  alpha: 0.2)),
        
        textAlert                   : ColourPaletteStructure(light  : UIColor(red: 233/255,     green: 69/255,  blue: 90/255,   alpha: 1),
                                                             dark   : UIColor(red: 255/255,     green: 11/255,  blue: 134/255,  alpha: 1)),
        
        buttonActiveBodyTop         : ColourPaletteStructure(light  : UIColor(red: 251/255,     green: 240/255, blue: 238/255,  alpha: 1),
                                                             dark   : UIColor(red: 86/255,      green: 71/255,  blue: 174/255,  alpha: 1)),
         
        buttonActiveBodyBase        : ColourPaletteStructure(light  : UIColor(red: 249/255,     green: 228/255, blue: 223/255,  alpha: 1),
                                                             dark   : UIColor(red: 86/255,      green: 71/255,  blue: 174/255,  alpha: 1)))
    
    // TESTING
    //
    // YELLOW : UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1)
    // GREEN  : UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1)
    // <--
    
    
    // WORKAROUND : CONVERTING FROM UIColor to SwiftUI Color AS THERE IS NO API FOR PROGRAMATICAL COLOUR MANAGEMENT
    static func extract(light: UIColor, dark: UIColor) -> Color {
        return Color(UIColor.dynamicColor(light: light, dark: dark))
    }
}

/// FUNDAMENTAL : COLOUR PALETTE REFERENCE
struct FundamentalColours {
    static let backgroundStandard           = ColourPalettes.extract(light  : ColorManager.shared.currentPalette.backgroundStandard.light,
                                                                     dark   : ColorManager.shared.currentPalette.backgroundStandard.dark)
    
    static let textFieldForegroundActive    = ColourPalettes.extract(light  : ColorManager.shared.currentPalette.textFieldForegroundActive.light,
                                                                     dark   : ColorManager.shared.currentPalette.textFieldForegroundActive.dark)
    
    static let textFieldForegroundInactive  = ColourPalettes.extract(light  : ColorManager.shared.currentPalette.textFieldForegroundInactive.light,
                                                                     dark   : ColorManager.shared.currentPalette.textFieldForegroundInactive.dark)
    
    static let textFieldBackgroundActive    = ColourPalettes.extract(light  : ColorManager.shared.currentPalette.textFieldBackgroundActive.light,
                                                                     dark   : ColorManager.shared.currentPalette.textFieldBackgroundActive.dark)
    
    static let textFieldBackgroundInactive  = ColourPalettes.extract(light  : ColorManager.shared.currentPalette.textFieldBackgroundInactive.light,
                                                                     dark   : ColorManager.shared.currentPalette.textFieldBackgroundInactive.dark)
    
    static let textAlert                    = ColourPalettes.extract(light  : ColorManager.shared.currentPalette.textAlert.light,
                                                                     dark   : ColorManager.shared.currentPalette.textAlert.dark)
    
    // WORKAROUND : GRADIENTS COULD NOT BE PLACED INTO AN ENUM
    static let activeGradientBody = LinearGradient(gradient: Gradient(colors: [

        ColourPalettes.extract(light:ColorManager.shared.currentPalette.buttonActiveBodyTop.light,
                                dark: ColorManager.shared.currentPalette.buttonActiveBodyTop.dark),
        
        ColourPalettes.extract(light: ColorManager.shared.currentPalette.buttonActiveBodyBase.light,
                               dark: ColorManager.shared.currentPalette.buttonActiveBodyBase.dark)
    
    ]), startPoint: .top, endPoint: .bottom)
}

/// COLOUR PALETE : DETERMINE COLOUR BASED ON STATE OF VIEW
func determineColour(forView viewType: ViewType, inState state: Bool) -> Color {
    switch viewType {
        
    // TEXT
    case .textForeground                    : FundamentalColours.textFieldForegroundActive
    case .textBackground                    : FundamentalColours.textFieldBackgroundActive
                
    // TEXT FIELD
    case .textFieldForeground               : state ? FundamentalColours.textFieldForegroundActive : FundamentalColours.textFieldForegroundInactive
    case .textFieldBackground               : state ? FundamentalColours.textFieldBackgroundActive : FundamentalColours.textFieldBackgroundInactive
                
    // TEXT FIELD HEADER
    case .textFieldHeaderForeground         : FundamentalColours.textFieldForegroundActive
    
    // TEXT FIELD w/BUTTON
    case .textFieldButtonForeground         : FundamentalColours.textFieldForegroundActive
    case .textFieldButtonBackground         : FundamentalColours.textFieldBackgroundActive
    case .textFieldButtonPropperForeground  : state ? FundamentalColours.textFieldForegroundActive : .clear
    case .textFieldButtonPropperBackground  : state ? .clear : FundamentalColours.textFieldBackgroundActive
        
    // BUTTON
    case .buttonForeground                  : state ? FundamentalColours.textFieldForegroundActive : FundamentalColours.textFieldForegroundInactive
    case .buttonForegroundAlert             : FundamentalColours.textAlert
    
    // STEPPER
    case .stepperForeground                 : state ? FundamentalColours.textFieldForegroundActive : FundamentalColours.textFieldForegroundInactive
    case .stepperBackground                 : state ? FundamentalColours.textFieldBackgroundActive : FundamentalColours.textFieldBackgroundInactive
            
    // TILE
    case .tileText                          : FundamentalColours.textFieldForegroundActive
    case .tileDivider                       : FundamentalColours.textFieldForegroundActive
    case .tileBackground                    : FundamentalColours.textFieldBackgroundActive
    }
}

/// WORKAROUND : CONVERTING FROM UIColor to SwiftUI Color AS THERE IS NO API FOR PROGRAMATICAL COLOUR MANAGEMENT
// h/t : Natascha Fadeeva
// w3 : https://tanaschita.com/supporting-dark-mode-programmatically
extension UIColor {
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

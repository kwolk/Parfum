//
//  Helpers.swift
//  ParfumVI
//
//  Created by 🐯 on 27/05/2024.
//

import SwiftUI


/// MEDLEY MODEL
class MedleyFormViewModel: ObservableObject {
    @Published var name         : String = ""
    @Published var period       : Period = .day
    @Published var status       : String = ""
    @Published var update       : String = ""
    @Published var destination  : String = ""
    @Published var maturity     : Int    = 0
    @Published var conclusion   : String = ""
    @Published var ingredients  : [IngredientData] = []
    
    // INGREDIENTS
    struct IngredientData: Identifiable {
        var id      : UUID      = UUID()
        var name    : String    = ""
        var amount  : Double    = 0.0
        var unit    : Unit      = .pipette
    }
    
//    var canAddIngredient: Bool {
//        !ingredients.contains { $0.name.isEmpty || $0.amount == 0.0 } &&
//        // ENSURE NAMES ARE UNIQUE (SET ONLY CONTAINS UNIQUE ELEMENTS)
//        Set(ingredients.map { $0.name }).count == ingredients.count
//    }

    func addIngredient() {
        ingredients.append(IngredientData())
    }
    
//    func removeIngredient(withId id: UUID) {
//        ingredients.removeAll { $0.id == id }
//    }
    
    func removeIngredient(_ ingredient: IngredientData) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients.remove(at: index)
        }
    }
}

/// CONVENIENCE : TEXT LABEL
struct CustomText: View {
    var text: String
    var align: Alignment = .center
    
    var body: some View {
        Text(text)
            .padding()
            .frame(maxWidth: .infinity, alignment: align)
            .foregroundColor(determineColour(forView: .textForeground, inState: true))
            .background(determineColour(forView: .textBackground, inState: true))
            .cornerRadius(FundamentalDimensions.corner.rawValue)
            //.font(.custom(FundamentalFonts.standard, size: 17))
    }
}

/// TEXT FIELD (EDIT MODE CHANGES TEXT COLOUR WHEN DEFAULT VALUE MODIFIED)
struct CustomTextField: View {
    var label           : String
    var text            : Binding<String>
    var editMode        : Bool              = false
    var isActive        : Bool              = true
    var onFocusChange   : ((Bool) -> Void)? = nil
    var onChange        : (() -> Void)?     = nil
    var characterLimit  : Int               = 20 // CHARACTER LIMIT
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: text, onEditingChanged: { editing in
                self.onFocusChange?(editing)
            }, onCommit: {
                self.onChange?()
            })
            .padding()
            .limitedCharacterTextField(text, characterLimit: characterLimit)
            .foregroundColor(determineColour(forView: .textFieldForeground, inState: isActive))
            .background(determineColour(forView: .textFieldBackground, inState: isActive))
            .cornerRadius(FundamentalDimensions.corner.rawValue)
        }
    }
}

/// CONVENIENCE : HEADER TITLE TEXT (TEXT FIELDS)
struct CustomTextFieldHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .textCase(.uppercase)
            .padding(.horizontal, FundamentalDimensions.headerTitleInset.rawValue)
            .foregroundColor(determineColour(forView: .textFieldHeaderForeground, inState: true))
            //.font(.custom(FundamentalFonts.standard, size: 17))
    }
}

/// TEXT FIELD WITH BUTTON TO SUBMIT
struct CustomTextFieldWithButton: View {
    @Binding var text               : String        // PARSE DATA
    @State var textFieldDefaultText : String        // PLACEHOLDER TEXT
    var isActive                    : Bool          // IF DATA IN FIELD SATISFIES REQUIREMENTS
    var buttonImage                 : String        // SYMBOL FOR BUTTON
    var addAction                   : () -> Void    // PARSE FUNCTION
    var characterLimit              : Int = 20      // CHARACTER LIMIT

    // WORKAROUND: BINDING PROPERTY ALWAYS SHOWS AS OCCUPYING THE TEXT FIELD ON AN INSTANCE, SO MUST BE DETERMINED HERE
//    var isEmpty: Bool {
//        print("HHH : \(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)")
//        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }

    var body: some View {
        ZStack {
            HStack {
                TextField(textFieldDefaultText, text: $text)
                    .limitedCharacterTextField($text, characterLimit: characterLimit)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(determineColour(forView: .textFieldButtonForeground, inState: isActive))
                    //.font(.custom(FundamentalFonts.standard, size: 17))

                Rectangle()
                    .frame(width: 53, height: 54)   // WORKAROUND : JUST A COUPLE OF PIXELS LESS THAN THE BUTTON STOPS IT BEING VISIBLE WHEN INACTIVE
                    .foregroundStyle(FundamentalColours.activeGradientBody)
                    .clipShape(UnevenRoundedRectangle(bottomTrailingRadius  : 10,
                                                      topTrailingRadius     : 10, style: .continuous))

                .overlay {
                    withAnimation {
                        Button(action: addAction) {
                            Image(systemName: buttonImage)
                                .padding()
                                .foregroundColor(determineColour(forView: .textFieldButtonPropperForeground, inState: isActive))
                                .frame(width: 55, height: 55)
                                .background(determineColour(forView: .textFieldButtonPropperBackground, inState: isActive))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .padding(.trailing, 2)
                        }
                    }
                    .disabled(!isActive)
                }
            }
            .padding(.leading)
            .background(determineColour(forView: .textFieldButtonBackground, inState: isActive))
            .cornerRadius(10)
            .background {
                Capsule()
                    .foregroundStyle(.thinMaterial)
            }
        }
    }
}

/// BUTTON
struct CustomButton: View {
    var title: String
    var action: () -> Void
    var isActive: Bool

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                //.font(.custom(FundamentalFonts.standard, size: 17))
        }
        .foregroundColor(determineColour(forView: .buttonForeground, inState: isActive))
        .background(FundamentalColours.activeGradientBody)
        .cornerRadius(FundamentalDimensions.corner.rawValue)
        .disabled(!isActive)
    }
}

/// STEPPER : CUSTOM BUTTONS TO CHANGE UNIT
struct CustomStepper: View {
    var label           : String
    var min             : Int
    var max             : Int
    var initialValue    : Int?
    
    @Binding var period                 : Period
    @State private var originalPeriod   : Period
    @State var periodChanged            : Period?
    @State private var showingMeasurementPicker = false
    
    @Binding var value: Int
    @State private var isIncrementing = false

    
    init(label: String, period: Binding<Period>, min: Int, max: Int, value: Binding<Int>, initialValue: Int? = nil) {
        self.label          = label
        self._period        = period
        self.originalPeriod = period.wrappedValue
        self.min            = min
        self.max            = max
        self._value         = value
        self.initialValue   = initialValue
    }
    
    var body: some View {
        
        VStack {
            Stepper(value: $value, in: min...max) {
                let periodDetermined: String = numberConcord($value, forPeriod: period)
                
                Button("\(label) \($value.wrappedValue) \(periodDetermined)") {
                    showingMeasurementPicker.toggle()
                }
                .onAppear {
                    if let initialValue = initialValue {
                        value = initialValue
                    }
                }
                .actionSheet(isPresented: $showingMeasurementPicker) {
                    ActionSheet(title: Text("Period"), buttons: Period.allCases.map { periodChange in
                            .default(Text(periodChange.caseName)) { period = periodChange }
                    })
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 17)
            .foregroundColor(determineColour(forView: .stepperForeground, inState: $value.wrappedValue > 0))
            .background(determineColour(forView: .stepperBackground, inState: $value.wrappedValue > 0))
            .cornerRadius(FundamentalDimensions.corner.rawValue)
        }
    }
    
    /// WORKAROUND : DETERMINE UNIT NOUN FORM (SINGULAR/PLURAL) FROM NUMERICAL INPUT
    private func numberConcord(_ toDetermine: Binding<Int>, forPeriod period: Period) -> String {
        switch period {
        case .day   : return value == 1 ? Period.day.singular  : Period.day.plural
        case .hour  : return value == 1 ? Period.hour.singular : Period.hour.plural
        case .week  : return value == 1 ? Period.week.singular : Period.week.plural
        }
    }
}

// FIXME: DROP-SHADOW ?
/// TILE (STRUCTURE)
private struct Tile {
    static let size: CGFloat = UIScreen.main.bounds.width / 3
    
    // SHAPE
    static func RoundedRectangleView() -> some View {
        Rectangle()
            .fill(determineColour(forView: .tileBackground, inState: true))
            .frame(width: size, height: size)
            .cornerRadius(FundamentalDimensions.corner.rawValue)
    }
    
    // DIVIDER
    static func Divider() -> some View {
        Rectangle()
            .fill(determineColour(forView: .tileDivider, inState: true))
            .frame(height: 1)
            .frame(maxWidth: size - (size * 0.3))   // SUBTRACT 30% OF LENGTH
    }
}

/// CONVENIENCE : TITLE TO VIEWS THAT DON'T BENEFIT FROM BEING INSIDE A NAVIGATION VIEW
struct TopTitle: View {
    var text    : String
    var leading : CGFloat = 20
    var top     : CGFloat = 17
    var bottom  : CGFloat = 17
    
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, leading)
            .padding(.top, top)
            .padding(.bottom, bottom)
            //.font(.custom(FundamentalFonts.standard, size: 17))
    }
}

/// TILE : DISPLAY INFORMATION CENTRALLY OR SPLIT ABOVE DIVIDER, AS WELL AS INFO BELOW (CENTERED)
struct TileView: View {
    
    enum TileAnimate: CGFloat {
        case yes    = 0
        case no     = 0.8
        case reset  = 1.0
    }

    let base        : String
    let centered    : String
    let split       : (Int, String)
    @State var scale: TileAnimate
    
    var body: some View {
        ZStack {
            // SHAPE
            Tile.RoundedRectangleView()
            // TEXT
            VStack(alignment: .center, spacing: 5) {
                HStack(spacing: 0) {
                    if centered.isEmpty { // ANYTHING BUT STATUS TILE
                        splitInfo
                    } else {
                        centeredInfo
                    }
                }
                // DIVIDER
                Tile.Divider()
                
                // TEXT : BOTTOM CENTRE
                Text(base)
            }
        }
        .foregroundColor(determineColour(forView: .tileText, inState: true))
        //.font(.custom(FundamentalFonts.standard, size: 17)) //16
        
        // ANIMATE : EXPAND TO FULL SIZE (ON APPEAR)
        .scaleEffect(scale.rawValue)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = TileAnimate.reset
            }
        }
    }
    
    // TEXT : TOP SPLIT
    var splitInfo: some View {
        // TEXT : TOP LEFT
        HStack {
            Text("\(split.0)")
                //.font(.custom(FundamentalFonts.standard, size: 17))
                .font(.system(size: split.0 < 100 ? 45 : 30, // TRIPLE DIGITS USE SMALLER FONT SIZE TO REMAIN INSIDE SHAPE BOUNDS
                              weight: .bold))
            
            // TEXT : TOP RIGHT
            VStack(alignment: .leading) {
                Text(split.1)
                    //.font(.custom(FundamentalFonts.standard, size: 17))
            }
        }
    }
    
    // TEXT : TOP CENTERED
    var centeredInfo: some View {
        HStack(spacing: 0) {
            HStack() {
                Text(centered)
                    .font(.system(size: 45, weight: .bold))
                    //.font(.custom(FundamentalFonts.standard, size: 17))
            }
        }
    }
}

/// TILE : DISPLAY DATES (CREATED / DAYS ELAPSED)
/// INTERACTIVE : ON TAP COUNTER WILL WIND UP TO DISPLAY DAYS ELAPSED
struct DateTile: View {
    let date    : Date
    let amount  : Int
    let size    : CGFloat = UIScreen.main.bounds.width / 3
    @State private var isElapsedVisible : Bool = false
    @State private var animatedAmount   : Int = 0
    @State private var scale            : CGFloat = 0.2
    @State private var timer            : Timer?

    var body: some View {
        ZStack {
            // SHAPE
            Tile.RoundedRectangleView()
            
            // TEXT : DATE
            VStack(alignment: .center, spacing: 5) {
                ZStack {
                    HStack(spacing: 0) {
                        HStack {
                            Text(dayOfMonth(date))
                                .font(.system(size: 45, weight: .bold))
                                //.font(.custom(FundamentalFonts.standard, size: 17))
                        }
                        VStack(alignment: .leading) {
                            Text(month(date))
                                //.font(.custom(FundamentalFonts.standard, size: 17))
                            Text(year(date))
                                //.font(.custom(FundamentalFonts.standard, size: 17))
                        }
                    }
                    // SHOW/HIDE BASED ON TAP EVENT (isElapsedVisible)
                    .opacity(isElapsedVisible ? 0 : 1)
                    .offset(x: isElapsedVisible ? -size : 0)
                    .animation(.easeInOut(duration: 0.5), value: isElapsedVisible)
                    
                    // ANIMATE NUMBER (COUNT-UP)
                    HStack {
                        Text("\(animatedAmount)")
                        // TRIPLE DIGITS USE SMALLER FONT SIZE TO REMAIN INSIDE SHAPE BOUNDS
                            .font(.system(size: amount < 100 ? 45 : 30, weight: .bold))
                            //.font(.custom(FundamentalFonts.standard, size: 17))

                        VStack(alignment: .leading) {
                            Text("Days")
                                //.font(.custom(FundamentalFonts.standard, size: 17))
                        }
                    }
                    // SHOW/SHOW BASED ON TAP EVENT (isElapsedVisible)
                    .opacity(isElapsedVisible ? 1 : 0)
                    .offset(x: isElapsedVisible ? 0 : size)
                    .animation(.easeInOut(duration: 0.5), value: isElapsedVisible)
                }
                // DIVIDER
                Tile.Divider()
                
                ZStack {
                    // TEXT : BOTTOM MIDDLE ("Created")
                    Text("Created")
                        .opacity(isElapsedVisible ? 0 : 1)
                        .offset(x: isElapsedVisible ? -size : 0)
                        //.font(.custom(FundamentalFonts.standard, size: 17))
                    
                    // TEXT : BOTTOM MIDDLE ("Elapsed")
                    Text("Elapsed")
                        .opacity(isElapsedVisible ? 1 : 0)
                        .offset(x: isElapsedVisible ? 0 : size)
                        //.font(.custom(FundamentalFonts.standard, size: 17))
                }
                .animation(.interpolatingSpring(stiffness: 50, damping: 10), value: isElapsedVisible)
            }
            .font(.system(size: 16))
            .foregroundColor(determineColour(forView: .tileText, inState: true))
            .frame(width: size, height: size)
            .clipped()
        }
        // TAP TO TEMPORARILY SHOW ALTERNATE TEXT (CREATION DATE / DAYS ELAPSED)
        .onTapGesture {
            timer?.invalidate()
                withAnimation {
                    isElapsedVisible = true
                    animatedAmount = 0
                    startCountAnimation()
                }
                // DISPLAY ELAPSED DAYS FOR TWO SECONDS BEFORE REVERTING BACK TO ORIGINAL CREATION DATE
                timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                    withAnimation {
                        isElapsedVisible = false
                        animatedAmount = 0
                  }
              }
        }
        // ANIMATE : EXPAND TO FULL SIZE (ON APPEAR)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
            }
        }
    }
    
    // DAY FORMATTING (NUMBER)
    private func dayOfMonth(_ date: Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    // YEAR FORMATTING (FULL)
    private func year(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    // MONTH FORMATTING (THREE LETTER)
    private func month(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    // ANIMATION
    private func startCountAnimation() {
        animatedAmount = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let speed = self.amount > 200 ? 10 : 5   // TRIPLE DIGITS NEED TO BE BROKEN DOWN FASTER
            withAnimation(.easeInOut(duration: 0.01)) {
                if self.animatedAmount < self.amount {
                    self.animatedAmount += speed
                } else {
                    self.animatedAmount = self.amount
                    timer.invalidate()
                }
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}






/// CONVENIENCE : CHECK FOR WHITE SPACE
extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}

/// CONVENIENCE : LIMIT TEXT FIELD CHARACTERS
extension View {
    func limitedCharacterTextField(_ text: Binding<String>, characterLimit: Int) -> some View {
        return self
            .onChange(of: text.wrappedValue) { newValue in
                if newValue.count > characterLimit {
                    text.wrappedValue = String(newValue.prefix(characterLimit))
                }
            }
    }
}

// CHECK INPUT TEXT AGAINST BLACKLIST (forbiddenTerms)
func blacklistCheck(_ name: String, existing: [String], exemption: String? = nil) -> Bool {
    
    // CHECKS FIELD IS EMPTY (AVOID USER ENTERING A BLANK)
    var isFieldEmpty: Bool {
        return name.isBlank
    }
    
    // EXTRACT EXISTING ITEMS AS STRINGS & CHECKS IF THE NEW NAME MATCHES
    var isNameDuplicate: Bool {
        return existing.map { $0.description }.contains(name)
    }

    // CHECK IF THE NAME IS EXEMPT
    var isExempt: Bool {
        return name == exemption    // WHEN EDITING THE ORIGINAL NAME SHOULD BE ALLOWED (EXEMPTED)
    }
    
    // CHECK FIELD CONTAINS DATA BUT IT DOES NOT ALREADY EXIST OR IT IS EXEMPT
    var isConditionsMet: Bool {
        let fieldMustBeOccupied = !isFieldEmpty                 // THE FIELD MUST BE OCCUPIED
        let avoidDuplicates     = !isNameDuplicate || isExempt  // AVOID DUPLICATES UNLESS EXEMPT
        return fieldMustBeOccupied && avoidDuplicates
    }

    return isConditionsMet
}

/// ASSIGN DATA WITH TITLE
// @ViewBuilder ATTRIBUTE ALLOWS CLOSURE TO ACCEPT MULTIPLE CHILD VIEWS
func sectionView<T: View>(header: String, @ViewBuilder content: () -> T) -> some View {
    VStack(alignment: .leading, spacing: FundamentalDimensions.headerSpacing.rawValue) {
        CustomTextFieldHeader(text: header)
        content()
    }
    .padding(.vertical, FundamentalDimensions.headerSpacing.rawValue)
}

/// EASTER EGG : CHANGE APP ICON ON DEMAND
func changeAppIcon(to iconName: AlternativeIcons) {
    UIApplication.shared.setAlternateIconName(iconName.rawValue) { (error) in
        if let error = error {
            print("Failed request to update the app’s icon: \(error)")
        }
    }
}


# Parfum
Organise and keep track of essential oil (perfume) experiments.

#### WHY ? ####
On and off over the years I have dabbled with Mother Nature's oils, recording as I went along my workflow would always change and the experiments were in many different corners of my life.

Bringing everything into a single centralised location and with the ability to keep track of all of them turned out to be the app I never realised that I needed.


#### WORKFLOW ####
<img width="383" alt="parfumDishSoapTrialsDark" src="https://github.com/kwolk/Parfum/assets/114968/b8a35ea2-978a-4fff-9d6f-186fefaf469f">

Recorded in spreadsheet format this most recent example shows the difference between drop and something more exact like millilitres. At this point I was more concerned with being able to replicate my (successful) experiments, ensuring that they were recorded almost as if a guide on how to recreate them.

Another note of interest was the dilution of the oils as a per cent of the overall volume of liquid. I liked to be well within the accepted allowance (which is a genuine health risk, dependant on the oil), between 0.5-2%. However, I did not code any kind of check for this, although I might in the future.

Reviewing all of the defining elements from previous experiments, which came in many form, I found that the things I cared about the most were being able to quickly find what I wanted, to be able to easily reproduce the ones that worked and to be able to keep track of those that didn't in order to try again.

***

#### TextField ####
- Although a UUID accompanies each CoreData entry, at the high level I felt it unconditional to include logic that would ensure unique names for all the medleys (experiments) within the category they reside.
- Iradicating another pet peeve included logic checks for blank space submissions and a character limiter to keep the UI clean as this app was designed for a small portable iDevice.
- Conditional logic could then be put to use disabling submission buttons and alerting the user to issues on a field by field basis through colour changes.
```swift
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
```

#### TextField Button (iOS 15) ####
- Originally starting this project in iOS 15 there was not option to round individual corners, so creating a button within a TextField was not as easy, but I did manage to figure it out. This could ultimately be useful for previous iOS support, but with <a href="https://developer.apple.com/app-store/submitting/" target="_blank">Apple's 6th February 2024  announcement that from April 2024 all iOS and iPadOS apps submitted to the App Store must be built with a minimum of Xcode 15 and the iOS 17 SDK</a> I wasn't sure if it would even still be valid ?

![textFieldButtonIOS15](https://github.com/kwolk/Parfum/assets/114968/3e755ef3-fdf4-46cd-8ced-429aa8348dbd)
  
```swift
struct CustomText2: View {
    @State var text: String
    @Binding var isEditable: Bool
    var onDelete: (() -> Void)?
    @State var text2: String

    var body: some View {
        HStack {
            ZStack {
                Text(text2)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .cornerRadius(15)

                ZStack {
                    CustomRoundButton(title: "X", action: {}, isActive: true)
                    Spacer()
                    CustomRoundButton(title: "X", action: {}, isActive: true)
                        .rotationEffect(.degrees(180))
                }
            }
        }
    }
}

struct CustomRoundButton: View {
    var title: String
    var action: () -> Void
    var isActive: Bool

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: 13) {
                    Spacer()
            RoundedRectangle(cornerRadius: 15, style: .circular)
                .fill(.blue)
                .frame(width: 75, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .frame(width: 51, height: 50)
                .offset(x: 12)
                .background(.blue)

            Text(title)
            //Image(systemName: "trash")
                .foregroundColor(.white)
                .offset(x: -30)
                }
            }
        }
    }
}
```
- <a href="https://www.hackingwithswift.com/forums/swiftui/seamless-joining-between-textfield-and-button/25970/25972" target="_blank">I hacked button functionality on both ends, as if a List Member</a>

- The final version (iOS 16+) is faithful to <a href="[https://www.hackingwithswift.com/forums/swiftui/seamless-joining-between-textfield-and-button/25970/25972](https://dribbble.com/shots/10733647-Search-022)" target="_blank">Raphael Nweke’s</a> original design by only displaying the button when the logic checks are satisfied and will hide the button when not:

```swift
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
```
![Raphael Nweke  Search 022](https://github.com/kwolk/Parfum/assets/114968/e2a8d402-003f-48cc-b631-c9aa0ce11ca9)

- Setting the relationship between Medleys (experiments) and Scenting (category) to Nullify meant that a Scenting entry could only be deleted when all of its dependent Medley's had been purged. This required a simple logic check on the array associated with the CoreData entry, but it important one:

- ```swift
  // WORKAROUND : "NULLIFY" OPTION PREVENTS DELETION UNTIL ALL RELATIONS HAVE BEEN PURGED
    var isScentingPopulated: Bool {
        return scenting.medleyArray.count > 0 ? true : false
    }
  ```

-----

#### TextField Titles ####
To remain as faithful as possible to <a href="[https://www.hackingwithswift.com/forums/swiftui/seamless-joining-between-textfield-and-button/25970/25972](https://dribbble.com/shots/10733647-Search-022)" target="_blank">Raphael Nweke’s</a> original design I avoided using anything as garish as title above a text field. However, I did have to employ them in the edit View as the fields would already be populated, which could be confusing without any labelling.

For this I decided to employ a generic to pass through different views and keep my code cleaner as a result. The benefit of using the @ViewBuilder attribute being that multiple child views can be accepted:
```swift
/// ASSIGN DATA WITH TITLE
// @ViewBuilder ATTRIBUTE ALLOWS CLOSURE TO ACCEPT MULTIPLE CHILD VIEWS
func sectionView<T: View>(header: String, @ViewBuilder content: () -> T) -> some View {
    VStack(alignment: .leading, spacing: FundamentalDimensions.headerSpacing.rawValue) {
        CustomTextFieldHeader(text: header)
        content()
    }
    .padding(.vertical, FundamentalDimensions.headerSpacing.rawValue)
}
```
![parfumAmendViewDark](https://github.com/kwolk/Parfum/assets/114968/40d944db-3ad7-4030-809d-c27f0eb4226a)


-----

#### Multiline TextFields ####
Under appreciated in SwiftUI these were difficult to work with and only have a light (white) and dark (black) mode, which only just sort of fit with my apps design.

```swift
    private struct MultilineTextFieldEdit: View {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }
        
        var body: some View {
            ZStack {
                TextEditor(text: $text)
                    //.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)) //FIXME: TEXT PADDING REMOVES ROUNDED CORNERS
                    .frame(minHeight: 100)
                    .foregroundColor(determineColour(forView: .textFieldForeground, inState: true))
                    // FIXME: LIMITS OF THE VIEW APPARENT IN DARK MODE AS BACKGROUND CANNOT BE CHANGED
                    .background(determineColour(forView: .textFieldBackground, inState: true))
                    .cornerRadius(FundamentalDimensions.corner.rawValue)
            }
        }
    }
```

- They also didn’t allow for padding around the edges, which if attempted would remove the rounded corners:

```swift
.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)) //FIXME: TEXT PADDING REMOVES ROUNDED CORNERS
```

-----


#### Numerical Animation (Tile) ####
Animating the elapsed days between the creation and current date using an animation effect was a little off, perhaps it was too quick ? But, if it started from zero then the animation would take too long. I could have further complicated the logic to specify the speed, based on number of day e.g. one hundred days would trigger a two fold increase in speed, but it challenging enough to get the animation working the way I needed to in the first instance:

IMG : parfumInteractiveTileDark [gif]

- _Attempting to bounce the date data above the divider, in unison with the label below it, the counter malfunctions for some reason ?_


-----

#### Picker ####
A mission objective was to not forget about existing experiments and so defaulting to “TBD” for the Picker makes sense for the user as those Medleys (experiments) will be the ones to focus on:
![parfumStatusDark](https://github.com/kwolk/Parfum/assets/114968/8262a065-d1ea-429b-a375-8ef59d5295d6)

- _nb. new medleys will always default to this category, so first loading that data prevents the user feeling lost_


-----


#### Localisation ####
My previous app only featured text based directions (no menus) during the onboarding process and this really helped me bring it to a lot of other non-English speaking cultures. Although this app will end up being text heavy, that is from the user's own input. So I tried to avoid words, in favour of recognisable symbols where possible, e.g. in the Navigation Title Bar to cut down on translation.
```swift
    // FIXME: RE-WRITE DEMO DETAILS
    static func demo(context: NSManagedObjectContext) -> Medley {
        Medley(name         : "Orange & Fennel #1",
               created      : randomDate(),
               period       : "days",
               status       : "tbd",
               update       : "This blend was more suited to a Duck roast than washing up liquid, or perhaps a shower gel, even a personal fragrance, but not necessarily suited to a dish-soap, given the application being food.",
               destination  : "Sealed glass jar.",
               maturity     : 14,
               conclusion   : "As with the Black Pepper, I only had Nutmeg in powder form to try, and perhaps it having lost some its potency some nineteen months past it’s best (January 2020) it wasn’t going to be a fair test.",
               context      : context)
    }

```
- However, I do plan to add languages and it will be a considerable workaround for example with the "demo" entry, which requires a pre-built data entry into CoreData.


-----

#### Ranaming ####
As <a href="https://www.hackingwithswift.com/forums/swiftui/seamless-joining-between-textfield-and-button/25970/25972](https://dribbble.com/shots/10733647-Search-022)" target="_blank">Raphael Nweke’s</a> original design didn't detail an amendment UI, I preffered the subtle hint of the original name being replaced, above the TextField, with each letter pressed, only resetting to the original if the name already exists, or until changed:

IMG : renaming entry (ani)


For this I employed a check against the existing name and one against all existing entries, which would control the visibility of the submit button:

```swift
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
```

-----

#### Light/Dark Mode ####
Employing a trick from <a href="https://tanaschita.com/supporting-dark-mode-programmatically" target="_blank">Natascha Fadeeva</a> to detect the system wide theme change from Light to Dark mode I was able to create a systems sophisticated enough to be able to not only change every View, but because I use colours to communicate with the user if there is a discrepancy, these too needed to be factored into the logic.
```swift
/// WORKAROUND : CONVERTING FROM UIColor to SwiftUI Color AS THERE IS NO API FOR PROGRAMATICAL COLOUR MANAGEMENT
// h/t : Natascha Fadeeva
// w3 : https://tanaschita.com/supporting-dark-mode-programmatically
extension UIColor {
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}
```

-----

#### Plural Words (Enum) ####
There still not way to manage plurals of words like "Day", "Hour" or "Week" in Xcode I had to employ logic in the Enum to deal with this:

```swift
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
```
- _I also employed a couple of convenience functions for use when dealing with CoreData i.e. converting to and from String values_


-----
_____

#### TODO ####

- [ ] Import/Export CSV files : Exporting a single Medley in CSV/PDF format would be handy for anybody. However, it a lot more work to import, with all of the checks.
- [ ] Neumorphism : I would like to offer a Neumorphic UI with lighting that rotates as the direction of view does on the Maps app when physically rotating the iDevice.
- [ ] Purge with text : As when deleting a Repo on GitHub I may introduce a feature to purge all Medleys (experiments) by typing a random word, as it woul be a lot quicker (CoreData relationship is set to Nullify)
- [ ] Calendar : To better keep track of Medley's a Calendar date entry could be calculated from the maturity info e.g. 14 days

- [ ] Retain data for thirty seconds:
Using a Sheet to create a Medley (experiment) it is al too easy to accidentally swipe down too hard and have all data entered wiped when attempting to edit once more.
In a previous version of this app I kept the data in memory for thirty seconds, conjuring it back with an initialiser, but decided against it in the final release as a user may decide to wipe their efforts manually to start a fresh by doing this.

```swift
struct EditExperimentView: View {
    
    @ObservedObject var viewModel: CreateExperimentViewModel
    @Binding var experiment: ExperimentEntity
    
    @State private var experimentTitleEdit      : String
    @State private var experimentIngredientsEdit: [IngredientEntity]
    @State private var experimentMaturityEdit   : String
    @State private var experimentDestinationEdit: String
    @State private var experimentConclusionEdit : String
    @State private var experimentUpdateEdit     : String
    @State private var experimentPeriodEdit     : Period = .day
    @State private var experimentSituationEdit  : Situation = .tbd
    
    
    init(viewModel: CreateExperimentViewModel, experiment: Binding<ExperimentEntity>) {
        self.viewModel = viewModel
        self._experiment = experiment
        self._experimentTitleEdit       = State(initialValue: experiment.wrappedValue.title)
        self._experimentIngredientsEdit = State(initialValue: experiment.wrappedValue.ingredientsArray)
        self._experimentMaturityEdit    = State(initialValue: String(experiment.wrappedValue.maturity))
        self._experimentDestinationEdit = State(initialValue: experiment.wrappedValue.destination)
        self._experimentConclusionEdit  = State(initialValue: experiment.wrappedValue.conclusion)
        self._experimentUpdateEdit      = State(initialValue: experiment.wrappedValue.update)
        self._experimentPeriodEdit      = State(initialValue: Period(rawValue: experiment.wrappedValue.period) ?? .day)
        self._experimentSituationEdit   = State(initialValue: Situation(rawValue: experiment.wrappedValue.situation) ?? .tbd)
    }
```

- _However, that it does seem more likely that the data would be wiped by accident_


- [ ] Light/Dark icons : I would like to take advantage of some of a rumoured iOS 18 feature to switch the App icon based on the system mode setting (I already have the icons)

IMG : Icons (Light/Dark)

```swift
/// EASTER EGG : CHANGE APP ICON ON DEMAND
func changeAppIcon(to iconName: AlternativeIcons) {
    UIApplication.shared.setAlternateIconName(iconName.rawValue) { (error) in
        if let error = error {
            print("Failed request to update the app’s icon: \(error)")
        }
    }
}
```
- _I did however put in an Easter Egg whereby when a Medley (experiment) was amended, that it would change the icon_

- [ ] Tiles (ScrollView) : I am not satisfied with the way the Tiles are created in ScrollView content, they just appear, when <a href="https://www.hackingwithswift.com/forums/swiftui/staggered-animation-for-scrollview-content/27351" target="_blank">I would rather stagger their entry with an ease effect, like train coaches arriving one after another</a>, which would indicate to the user that they were scrollable (presently I work around this by using three Tiles, so they're cut off the the visible screen)
- [ ] An in/out fade effect, when overwriting, would offer a more majestic experience
- [ ] Presenting View in ScrollView : I like the centrally expanding UI effect a View will take in a ScrollView, <a href="https://www.hackingwithswift.com/forums/swiftui/scrollview-expand-views-from-centre/27350/27359" target="_blank">but I cannot reliably control this</a>

![centrallyExpandingView](https://github.com/kwolk/Parfum/assets/114968/0d0d132d-3ff4-4d25-a15a-842812295d8f)




















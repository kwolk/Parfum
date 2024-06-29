//
//  AddMedleyView.swift
//  ParfumVI
//
//  Created by 🐯 on 30/05/2024.
//

import SwiftUI



struct AddMedleyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = MedleyFormViewModel()
    @ObservedObject var scenting: Scenting
    @AppStorage("isEasterEggOneFound") private var isEasterEggOneFound: Bool = false
    @State var existingItems: [String]
    var onAddMedley: (Medley) -> Void
    
    // AVOID BLANK OR DUPLICATE SUBMISSIONS
    var isNameConditionMet: Bool {
        return blacklistCheck(viewModel.name, existing: existingItems)
    }
    
    // WORKAROUND : WITH NO DATA (OR DUPLICATES) DEFAULT TO STANDARD EXPLANATION
    var defaultHeaderText: String {
        return isNameConditionMet ? viewModel.name : "New Medley"
    }

    /// MINIMUM REQUIREMENTS FOR INGREDIENTS OPTION TO BECOME FUNCTONAL
    var isAddIngredientButtonEnabled: Bool {
        !viewModel.name.isEmpty && viewModel.ingredients.allSatisfy { !$0.name.isEmpty && $0.amount > 0 } &&
        // ENSURE NAMES ARE UNIQUE (SET ONLY CONTAINS UNIQUE ELEMENTS)
        Set(viewModel.ingredients.map { $0.name }).count == viewModel.ingredients.count
    }
    
    // WORKAROUND : ENSURE INGREDIENT NAMES DO NOT MATCH
    var isIngredientsMatch: Bool {
        let names = viewModel.ingredients.map { $0.name }
        let uniqueNames = Set(names)
        return names.count != uniqueNames.count
    }
    
    // WORKAROUND : ENSURE DESTINATION FIELD FILLED
    var isDestinationSatisfied: Bool {
        return !viewModel.destination.isEmpty
    }
    
    // WORKAROUND : ENSURE INGREDIENTS CANNOT BE RETURNED WITH A ZERO QUANTITY
    var isMaturitySatisfied: Bool {
        return viewModel.maturity > 0
    }
    
    /// MINIMUM REQUIREMENTS FOR SUBMIT BUTTON TO BECOME FUNCTONAL
    var isSubmitButtonEnabled: Bool {
        let nameChecks              = isNameConditionMet    // NOT EMPTY && UNIQUE
        let emptyExperiment         = !viewModel.destination.isEmpty
        let emptyIngredient         = viewModel.ingredients.allSatisfy { !$0.name.isEmpty && $0.amount > 0 } && !viewModel.ingredients.isEmpty
        let uniqueIngredientNames   = !isIngredientsMatch
        
        return nameChecks && emptyExperiment && emptyIngredient && isDestinationSatisfied && isMaturitySatisfied && uniqueIngredientNames
    }
    
    var body: some View {
        ZStack {
            FundamentalColours.backgroundStandard.edgesIgnoringSafeArea(.all)
            
            VStack {
                defineTitle
                
                defineMedley
                
                // INGREDIENTS
                defineIngredients
                buttonAddIngredient
                
                // DATA
                defineMaturity
                defineDestination

                // BUTTONS
                submitButton
                buttonDismiss
                
                Spacer()
            }
            .padding()
            
            .navigationTitle("Add Medley")
            .foregroundColor(FundamentalColours.textFieldForegroundActive)
        }
    }

    /// VIEW NAME
    var defineTitle: some View {
        TopTitle(text: defaultHeaderText, leading: 5)
    }
    
    /// NAME MEDLEY
    var defineMedley: some View {
        CustomTextField(label   : "Medley Name",
                        text    : $viewModel.name,
                        isActive: isNameConditionMet)
    }

    /// ADD INGREDIENTS
    var defineIngredients: some View {
        ForEach($viewModel.ingredients) { $ingredient in
            //CreateIngredientView(ingredient: $ingredient, ingredients: $viewModel.ingredients, viewModel: viewModel)
            CreateIngredientView(ingredient: $ingredient, ingredients: $viewModel.ingredients)
        }
    }
    
    /// BUTTON : ADD INGREDIENTS
    var buttonAddIngredient: some View {
        CustomButton(title      : "Add Ingredient",
                     action     : viewModel.addIngredient,
                     isActive   : isAddIngredientButtonEnabled)
    }
    
    /// MATURATION TIME FOR MEDLEY
    var defineMaturity: some View {
        CustomStepper(label     : "Maturity: ",
                      period    : $viewModel.period,
                      min       : 0,
                      max       : 366,
                      value     : $viewModel.maturity)
    }
    
    /// DESTINATION (e.g. SMALL WOODEN STICKS, CORKED BELL JAR...)
    var defineDestination: some View {
        CustomTextField(label   : "Destination",
                        text    : $viewModel.destination,
                        isActive: !$viewModel.destination.wrappedValue.isEmpty)
    }
        
    /// DISMISS VIEW
    var buttonDismiss: some View {
        CustomButton(title      : "Dismiss",
                     action     : { hideSheet() },
                     isActive   : true)
    }
    
    /// ADD MEDLEY
    var submitButton: some View {
        CustomButton(title      : "Submit",
                     action     : { addMedley() },
                     isActive   : isSubmitButtonEnabled)
    }
    
    /// DATA CONVERSION
    private func addMedley() {
        let newMedley = Medley(context: viewContext)
        newMedley.name          = viewModel.name
        newMedley.period        = Period.fromEnum(viewModel.period)
        newMedley.destination   = viewModel.destination
        newMedley.maturity      = Int16(viewModel.maturity)
        
        for ingredientData in viewModel.ingredients {
            let newIngredient       = Ingredient(context: viewContext)
            newIngredient.name      = ingredientData.name
            newIngredient.amount    = ingredientData.amount
            newIngredient.unit      = ingredientData.unit.caseName
            newMedley.addToIngredient(newIngredient)
        }
        onAddMedley(newMedley)
        hideSheet()
        if !isEasterEggOneFound { easterEggIconFirst() }    // EASTER EGG #1 : CHANGE ICON TO SHOW FIRST MEDLEY LABEL
    }
    
    /// TOGGLE SHEET VISIBILITY
    private func hideSheet() {
        presentationMode.wrappedValue.dismiss()
    }
    
    /// EASTER EGG #1 : DISPLAY FIRST ALTERNATIVE BOTTLE LABEL
    private func easterEggIconFirst() {
        changeAppIcon(to: AlternativeIcons.firstMedleyLight)
        isEasterEggOneFound = true
    }
}

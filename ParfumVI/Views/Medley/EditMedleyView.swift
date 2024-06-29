//
//  EditMedleyView.swift
//  ParfumVI
//
//  Created by 🐯 on 30/05/2024.
//

import SwiftUI


struct EditMedleyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("isEasterEggTwoFound") private var isEasterEggTwoFound: Bool = false
    @AppStorage("isEasterEggThreeFound") private var isEasterEggThreeFound: Bool = false
    
    var existingNames: [String]
    var originalName: String
    
    @ObservedObject var medley: Medley
    
    @State private var name         : String
    @State private var period       : Period
    @State private var status       : Status
    @State private var update       : String
    @State private var destination  : String
    @State private var maturity     : Int
    @State private var conclusion   : String
    @State private var ingredients  : [MedleyFormViewModel.IngredientData]
    
    @State private var isConfirmationSaveAlert: Bool = false
    @State private var isConfirmationDeleteAlert: Bool = false
    
    init(medley: Medley, existingMedley: [String], medleyName: String) {
        originalName    = medleyName
        existingNames   = existingMedley
        _medley         = ObservedObject(wrappedValue: medley)
        _name           = State(initialValue: medley.nameUnwrapped)
        _period         = State(initialValue: Period.fromString(medley.periodUnwrapped) ?? .day)
        _status         = State(initialValue: Status.fromString(medley.statusUnwrapped) ?? .tbd)
        _update         = State(initialValue: medley.updateUnwrapped)
        _destination    = State(initialValue: medley.destinationUnwrapped)
        _maturity       = State(initialValue: Int(medley.maturity))
        _conclusion     = State(initialValue: medley.conclusionUnwrapped)
        
        let ingredientData = medley.ingredientsArray.map { ingredient in
            MedleyFormViewModel.IngredientData(id: ingredient.id ?? UUID(), name: ingredient.nameUnwrapped, amount: ingredient.amount)
        }
        _ingredients = State(initialValue: ingredientData)
    }
    
    // AVOID BLANK OR DUPLICATE SUBMISSIONS
    var isNameConditionMet: Bool {
        return blacklistCheck(name, existing: existingNames, exemption: originalName)
    }
    
    // WORKAROUND : WITH NO DATA (OR DUPLICATES) DEFAULT TO STANDARD EXPLANATION
    var defaultHeaderText: String {
        return isNameConditionMet ? "Editing \(name)" : "Editing \(originalName)"
    }
    
    // WORKAROUND : ENSURE INGREDIENTS CANNOT BE RETURNED WITH A ZERO QUANTITY
    var isIngredientSatisfied: Bool {
        return ingredients.contains(where: { $0.amount < 1.0 || $0.name.isEmpty })
    }
    
    /// MINIMUM REQUIREMENTS FOR INGREDIENTS OPTION TO BECOME FUNCTONAL
    var isAddIngredientButtonEnabled: Bool {
        !name.isEmpty && ingredients.allSatisfy { !$0.name.isEmpty && $0.amount > 0 } &&
        // ENSURE NAMES ARE UNIQUE (SET ONLY CONTAINS UNIQUE ELEMENTS)
        Set(ingredients.map { $0.name }).count == ingredients.count
    }
    
    // WORKAROUND : ENSURE INGREDIENT NAMES DO NOT MATCH
    var isIngredientsMatch: Bool {
        let names = ingredients.map { $0.name }
        let uniqueNames = Set(names)
        return names.count != uniqueNames.count
    }
    
    // WORKAROUND : CHECK IF THERE ARE NOINGREDIENTS
    var isIngredientsEmpty: Bool {
        return ingredients.isEmpty
    }

    
    // WORKAROUND : ENSURE DESTINATION FIELD FILLED
    var isDestinationSatisfied: Bool {
        return !destination.isEmpty
    }
    
    // WORKAROUND : ENSURE INGREDIENTS CANNOT BE RETURNED WITH A ZERO QUANTITY
    var isMaturitySatisfied: Bool {
        return maturity > 0
    }

    // WORKAROUND : ENSURE ALL FIELDS ARE POPULATED
    var isAllConditionsMet: Bool {
        let nameChecks                  = isNameConditionMet    // NOT EMPTY && UNIQUE
        let ingredientsQuantityExist    = !isIngredientSatisfied
        let uniqueIngredientNames       = !isIngredientsMatch
        let ingredientsExist            = !isIngredientsEmpty
        
        return nameChecks && ingredientsQuantityExist && isDestinationSatisfied && isMaturitySatisfied && uniqueIngredientNames && ingredientsExist
    }
    
    
    var body: some View {
        ZStack {
            FundamentalColours.backgroundStandard.edgesIgnoringSafeArea(.all)
                        
            ScrollView {
                defineViewTitle
                
                // DATA
                sectionView(header: "MEDLEY NAME")  { renameMedley }
                sectionView(header: "INGREDIENTS")  { defineIngredients }
                sectionView(header: "DESTINATION")  { defineDestination }
                sectionView(header: "STATUS")       { defineStatus }
                sectionView(header: "MATURITY")     { defineMaturity }
                sectionView(header: "CONCLUSION")   { defineConclusion }
                sectionView(header: "UPDATE")       { defineUpdate }
                
                // BUTTONS
                buttonSave
                buttonDelete
                buttonDismiss
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { saveChanges() }
            }
        }
    }
    
    /// VIEW TITLE
    var defineViewTitle: some View {
        TopTitle(text: defaultHeaderText, leading: 5)
    }
    
    /// RENAME MEDLEY
    var renameMedley: some View {
        CustomTextField(label   : "Medley Name",
                        text    : $name,
                        editMode: true,
                        isActive: isNameConditionMet)
    }
    
    /// LIST INGREDIENTS
    var defineIngredients: some View {
        VStack {
            ForEach($ingredients) { $ingredient in
                CreateIngredientView(ingredient: $ingredient, ingredients: $ingredients)
            }
            buttonAddIngredient
        }
    }

    /// STATE OF MEDLEY (WAS IT A SUCCESS ?)
    var defineStatus: some View {
        Picker("Status", selection: $status) {
            ForEach(Status.allCases, id: \.self) { status in
                Text(status.rawValue)
                    .textCase(.uppercase)
                    .padding()
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    /// MATURATION TIME FOR MEDLEY
    var defineMaturity: some View {
        CustomStepper(label     : "Maturity: ",
                      period    : $period,
                      min       : 0,
                      max       : 366,
                      value     : $maturity)
    }

    /// DESTINATION INFO
    var defineDestination: some View {
        CustomTextField(label   : "Destination",
                        text    : $destination,
                        editMode: true,
                        isActive: !$destination.wrappedValue.isEmpty)
    }
    
    /// CONCLUDE RESULTS
    var defineConclusion: some View {
        MultilineTextFieldEdit(text: $conclusion)
    }
    
    /// ANY UPDATES FOR LONG TERM VIEW
    var defineUpdate: some View {
        MultilineTextFieldEdit(text: $update)
    }
    
    /// BUTTON : ADD INGREDIENTS
    var buttonAddIngredient: some View {
        CustomButton(title      : "Add Ingredient",
                     action     : addIngredient,
                     isActive   : isAddIngredientButtonEnabled)
    }
    
    /// BUTTON : SAVE
    var buttonSave: some View {
        CustomButton(title      : "Save",
                     action     : { isConfirmationSaveAlert.toggle() },
                     isActive   : isAllConditionsMet)
        
        // WORKAROUND MULTIPLE ALERTS NOT ALLOWED IN A SINGLE VIEW
        .alert(isPresented: $isConfirmationSaveAlert) {
            Alert(
                title           : Text("Save amendments ?"),
                message         : Text("You can always change later."),
                primaryButton   : .default(Text("please")) { saveChanges() },
                secondaryButton : .cancel(Text("nah mate"))
            )
        }
    }
    
    /// BUTTON : DISMISS
    var buttonDismiss: some View {
        CustomButton(title      : "Dismiss",
                     action     : { hideSheet() },
                     isActive   : true)
    }
    
    /// BUTTON : DELETE MEDLEY
    var buttonDelete: some View {
        CustomButton(title      : "Delete",
                     action     : { isConfirmationDeleteAlert.toggle() },
                     isActive   : true)
        .foregroundColor(determineColour(forView: .buttonForegroundAlert, inState: true))
        
        // WORKAROUND MULTIPLE ALERTS NOT ALLOWED IN A SINGLE VIEW
        .alert(isPresented: $isConfirmationDeleteAlert) {
            Alert(
                title           : Text("Delete '\(medley.nameUnwrapped)' Medley ?"),
                message         : Text("Once deleted, this cannot be undone."),
                primaryButton   : .default(Text("chuck it")) { deleteMedley() },
                secondaryButton : .cancel(Text("forget it"))
            )
        }
    }

    /// MULTILINE TEXT FIELD
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

    /// TOGGLE SHEET VISIBILITY
    private func hideSheet() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func addIngredient() {
        ingredients.append(MedleyFormViewModel.IngredientData(id: UUID(), name: "", amount: 0.0))
    }
    
    // PARSING && SAVING MEDLEY DATA
    private func saveChanges() {
        medley.name         = name
        medley.period       = Period.fromEnum(period)
        medley.status       = Status.fromEnum(status)
        medley.update       = update
        medley.destination  = destination
        medley.maturity     = Int16(maturity)
        medley.conclusion   = conclusion
        
        let existingIngredients = medley.ingredientsArray
        var updatedIngredientIds = Set<UUID>()
        
        for ingredientData in ingredients {
            if let existingIngredient       = existingIngredients.first(where: { $0.id == ingredientData.id }) {
                existingIngredient.name     = ingredientData.name
                existingIngredient.amount   = ingredientData.amount
                existingIngredient.unit     = ingredientData.unit.name(for: existingIngredient.amount)
            } else {
                let newIngredient       = Ingredient(context: viewContext)
                newIngredient.name      = ingredientData.name
                newIngredient.amount    = ingredientData.amount
                newIngredient.unit      = ingredientData.unit.caseName
                medley.addToIngredient(newIngredient)
            }
            updatedIngredientIds.insert(ingredientData.id)
        }
            
        // REMOVE INGREDIENT(S) NOT IN UPDATED LIST
        for existingIngredient in existingIngredients {
            if !updatedIngredientIds.contains(existingIngredient.idUnwrapped) {
                medley.removeFromIngredient(existingIngredient)
                viewContext.delete(existingIngredient)
            }
        }
        save()
        presentationMode.wrappedValue.dismiss()
        
        if !isEasterEggThreeFound && isEasterEggTwoFound { easterEggIconThird() }    // EASTER EGG #3 : CHANGE ICON AGAIN TO SHOW THIRD MEDLEY LABEL (OVERLAP)
        if !isEasterEggTwoFound { easterEggIconSecond() }    // EASTER EGG #2 : CHANGE ICON TO SHOW SECOND MEDLEY LABEL (OVERLAP)
    }
    
    // DELETE
    private func deleteMedley() {
        Medley.delete(medley)
        presentationMode.wrappedValue.dismiss()
    }
    
    // SAVE TO PERSISTENT MEMORY
    private func save() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    /// EASTER EGG #2 : DISPLAY SECOND ALTERNATIVE BOTTLE LABEL
    private func easterEggIconSecond() {
        changeAppIcon(to: AlternativeIcons.secondMedleyLight)
        isEasterEggTwoFound = true
    }
    
    /// EASTER EGG #3 : DISPLAY THIRD ALTERNATIVE BOTTLE LABEL
    private func easterEggIconThird() {
        changeAppIcon(to: AlternativeIcons.thirdMedleyLight)
        isEasterEggThreeFound = true
    }
}

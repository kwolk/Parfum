//
//  CreateIngredientView.swift
//  ParfumVI
//
//  Created by 🐯 on 31/05/2024.
//

import SwiftUI


struct CreateIngredientView: View {
    @Binding var ingredient: MedleyFormViewModel.IngredientData
    @Binding var ingredients: [MedleyFormViewModel.IngredientData]
    @State private var showingUnitPicker = false
    @FocusState private var isCellFocused: Bool

    var characterLimit: Int = 12 // CHARACTER LIMIT

    var isComplete: Bool {
        !ingredient.name.isEmpty && ingredient.amount > 0
    }
    
    var canAddIngredient: Bool {
        !ingredient.name.isEmpty && ingredient.amount > 0 &&
        Set(ingredients.map { $0.name }).count == ingredients.count // EACH INSTANCE OF A SET IS UNIQUE SO CHECKS CAN BE MADE
    }

    
    var body: some View {
        VStack {
            defineIngredientName

            defineIngredientAmount
                .padding(.trailing, 15)

            if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                Button(action: {
                    
                    for i in ingredients {
                        print("GG : \(ingredient.id) : \(i.id)")
                    }
                    
                    /*
                    FIXME: THE FIRST INGREDIENT CANNOT BE RELIABLY DELETED
                    IT COULD BE THAT TWO INSTANCES ARE BELIEVED TO CO-EXIST ?
                    LLDB:
                    GG : 5EC4F3FA-8722-4842-A792-986A1A356945 : 5EC4F3FA-8722-4842-A792-986A1A356945
                    GG : 5EC4F3FA-8722-4842-A792-986A1A356945 : 8DE5996A-E90D-42F0-9718-2A294D7B5F08
                    GG : 8DE5996A-E90D-42F0-9718-2A294D7B5F08 : 8DE5996A-E90D-42F0-9718-2A294D7B5F08
                    Swift/ContiguousArrayBuffer.swift:600: Fatal error: Index out of range
                    */
                    
                    ingredients.remove(at: index)
                }) {
                    Text("Remove")
                        .foregroundColor(FundamentalColours.textAlert)
                        .padding(5)
                }
                .disabled(ingredients.isEmpty)
            }
        }
        .background(determineColour(forView: .textFieldBackground, inState: canAddIngredient))
        .cornerRadius(10)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    /// INGREDIENT NAME
    var defineIngredientName: some View {
        TextField("Ingredient Name", text: $ingredient.name)
            .limitedCharacterTextField($ingredient.name, characterLimit: characterLimit)
            .padding(15)
            .foregroundColor(determineColour(forView: .textFieldForeground, inState: isCellFocused || !$ingredient.name.wrappedValue.isEmpty))
    }
    
    /// ADD/SUBTRACT AMOUNT OF UNITS (UNITS MAY ALSO BE DEFINED)
    var defineIngredientAmount: some View {
        Stepper(value: $ingredient.amount, in: 0...99) {
            let quantity: Int = Int(ingredient.amount)
            let unit: String = numberConcord(ingredient.amount, forUnit: ingredient.unit)
            
            Button("\("Amount: ") \(quantity) \(unit)") {
                showingUnitPicker.toggle()
            }
            
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
            .actionSheet(isPresented: $showingUnitPicker) {
                ActionSheet(title: Text("Units"), buttons: Unit.allCases.map { unit in
                    .default(Text(unit.caseName)) {
                        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                            ingredients[index].unit = unit
                        }
                    }
                })
            }
        }
        .foregroundColor(determineColour(forView: .textFieldForeground, inState: isCellFocused || !ingredient.amount.isZero))
    }

    private func numberConcord(_ amount: Double, forUnit unit: Unit) -> String {
        switch unit {
        case .pipette       : return amount == 1.0 ? Unit.pipette.singular      : Unit.pipette.plural
        case .millilitre    : return amount == 1.0 ? Unit.millilitre.singular   : Unit.millilitre.plural
        case .tablespoon    : return amount == 1.0 ? Unit.tablespoon.singular   : Unit.tablespoon.plural
        case .gram          : return amount == 1.0 ? Unit.gram.singular         : Unit.gram.plural
        case .cup           : return amount == 1.0 ? Unit.cup.singular          : Unit.cup.plural
        }
    }
}

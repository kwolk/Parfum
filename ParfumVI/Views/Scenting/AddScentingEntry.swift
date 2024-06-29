//
//  TestAdd.swift
//  ParfumVI
//
//  Created by 🐯 on 28/05/2024.
//

import SwiftUI


/// ADD SCENTING  ENTRY
struct AddScentingEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var newName          : String = ""
    @State var existingItems    : [String]
    let defaultText             : String
    
    var onAdd: (String) -> Void
    
    // AVOID BLANK OR DUPLICATE SUBMISSIONS
    var isNameingConditionMet: Bool {
        return blacklistCheck(newName, existing: existingItems)
    }
    
    // WORKAROUND : WITH NO DATA (OR DUPLICATES) DEFAULT TO STANDARD EXPLANATION
    var defaultHeaderText: String {
        return isNameingConditionMet ? newName : defaultText
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                FundamentalColours.backgroundStandard.edgesIgnoringSafeArea(.all)
                
                VStack {
                    title
                    addButton
                    buttonDismiss
                }
                .padding()
            }
        }
    }
    
    /// VIEW NAME
    var title: some View {
        TopTitle(text: defaultHeaderText, leading: 0)
    }
    
    /// ADD NEW CATEGORY
    var addButton: some View {
        CustomTextFieldWithButton(text                  : $newName,
                                  textFieldDefaultText  : defaultText,
                                  isActive              : isNameingConditionMet,
                                  buttonImage           : "plus") { addName(newName) }
            .padding(.vertical, 10)
    }

    /// ADD NEW ITEM
    private func addName(_ name: String) {
        onAdd(newName)
        hideSheet()
    }
    
    /// DISMISS VIEW
    var buttonDismiss: some View {
        CustomButton(title      : "Dismiss",
                     action     : { hideSheet() },
                     isActive   : true)
    }
    
    /// TOGGLE SHEET VISIBILITY
    private func hideSheet() {
        presentationMode.wrappedValue.dismiss()
    }    
}

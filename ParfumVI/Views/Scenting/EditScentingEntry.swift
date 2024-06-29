//
//  EditEntryView.swift
//  ParfumVI
//
//  Created by 🐯 on 29/05/2024.
//

import SwiftUI


/// EDIT SCENTING ENTRY
struct EditScentingEntryView: View {
    @ObservedObject var scenting: Scenting
    @Environment(\.presentationMode) var presentationMode
    @State var newName: String = ""
    @State var existingItems: [String]
    @State private var isConfirmationAlert: Bool = false
    let defaultText: String
    var onRename: (String) -> Void
    
    
    // AVOID BLANK OR DUPLICATE SUBMISSIONS
    var isNameConditionMet: Bool {
        return blacklistCheck(newName, existing: existingItems)
    }
    
    // WORKAROUND : WITH NO DATA (OR DUPLICATES) DEFAULT TO STANDARD EXPLANATION
    var defaultHeaderText: String {
        return isNameConditionMet ? newName : "Change \(defaultText)'s Name"
    }
    
    // WORKAROUND : "NULLIFY" OPTION PREVENTS DELETION UNTIL ALL RELATIONS HAVE BEEN PURGED
    var isScentingPopulated: Bool {
        return scenting.medleyArray.count > 0 ? true : false
    }

    var body: some View {
        ZStack {
            FundamentalColours.backgroundStandard.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                defineTitle
                rename
                buttonDelete
                buttonDismiss
            }
            .padding()
            
            .alert(isPresented: $isConfirmationAlert) {
                Alert(
                    title           : Text("Delete '\(defaultText)' ?"),
                    message         : Text("Once deleted, this cannot be undone."),
                    primaryButton   : .default(Text("fine")) { deleteAction() },
                    secondaryButton : .cancel(Text("nah"))
                )
            }
        }
    }
    
    /// VIEW NAME
    var defineTitle: some View {
        TopTitle(text: defaultHeaderText, leading: 0)
    }
    
    /// RENAME
    var rename: some View {
        CustomTextFieldWithButton(text                  : $newName,
                                  textFieldDefaultText  : defaultText,
                                  isActive              : isNameConditionMet,
                                  buttonImage           : "pencil") { rename(newName) }
            .padding(.vertical, 10)
    }
    
    /// ADD NEW ITEM
    private func rename(_ name: String) {
        onRename(newName)
        hideSheet()
    }
    
    /// DELETE BUTTON
    var buttonDelete: some View {
        CustomButton(title      : isScentingPopulated ? "Delete Medleys First" : "Delete",
                     action     : { isConfirmationAlert.toggle() },
                     isActive   : !isScentingPopulated)
        .padding(.vertical, 10)
        .foregroundColor(determineColour(forView: .buttonForegroundAlert, inState: true))
    }
    
    /// DISMISS BUTTON
    var buttonDismiss: some View {
        CustomButton(title      : "Dismiss",
                     action     : { hideSheet() },
                     isActive   : true)
    }
    
    /// TOGGLE SHEET VISIBILITY
    private func hideSheet() {
        presentationMode.wrappedValue.dismiss()
    }
    
    /// DELETE ACTION
    private func deleteAction() {
        Scenting.delete(scenting)
        hideSheet()
    }
    
//    /// AVOID BLANK OR DUPLICATE SUBMISSIONS
//    private func nameCheck(_ name: String, existing: [String]) -> Bool {
//        
//        // CHECKS FIELD IS EMPTY (AVOID USER ENTERING A BLANK)
//        var isFieldEmpty: Bool {
//            return name.isBlank
//        }
//        
//        // EXTRACT EXISTING ITEMS AS STRINGS & CHECKS IF THE NEW NAME MATCHES
//        var isNameDuplicate: Bool {
//            return existing.map { $0.description }.contains(name)
//        }
//        
//        // CHECK FIELD CONTAINS DATA BUT IT DOES NOT ALREADY EXIST
//        var isConditionsMet: Bool {
//            let fieldMustBeOccupied = !isFieldEmpty     // THE FIELD MUST BE OCCUPIED
//            let avoidDuplicates     = !isNameDuplicate  // AVOID DUPLICATES
//            return fieldMustBeOccupied && avoidDuplicates
//        }
//
//        return isConditionsMet
//    }
    
    /// CONVENIENCE : CONVERT DATA TO STRINGS (IT'S EITHER THAT OR A CUMBERSOME GENERIC)
    private func extractScentingNames(from scenting: FetchedResults<Scenting>) -> [String] {
        return scenting.map { $0.name ?? "Unknown" }
    }
}

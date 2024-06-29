//
//  ScentingDetailView.swift
//  ParfumVI
//
//  Created by 🐯 on 26/05/2024.
//

import SwiftUI
import CoreData


struct ScentingDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var scenting: Scenting
        
    @State var existingScenting             : FetchedResults<Scenting>
    @State private var isAddingMedley       : Bool = false
    @State private var isEditingScenting    : Bool = false
    @State private var newMedley            : String = ""
        
    @FetchRequest(fetchRequest: Medley.fetchMedleys(), animation: .default)
    private var medleys: FetchedResults<Medley>
    @State private var selectedMedley: Medley?
    @State private var selectedStatus: Status = .tbd
    
    // FILTER MEDLEYS BASED ON STATUS
    private var filteredMedleys: [Medley] {
        return collatedMedleys[selectedStatus] ?? []
    }
    
    // MAP SCENTED MEDLEYES BY STATUS
    private var collatedMedleys: [Status: [Medley]] {
        
        // GROUP MEDLEYS BY STATUS
        let groupedMedleys = Dictionary(grouping: scenting.medleyArray) { $0.statusEnum }
        
        // ORGANISE INTO A DICTIONARY
        var result: [Status: [Medley]] = [:]
        for status in Status.allCases {
            result[status] = groupedMedleys[status] ?? []
        }
        return result
    }

    
    var body: some View {
        ZStack {
            FundamentalColours.backgroundStandard.edgesIgnoringSafeArea(.all)
            
            VStack {
                if !scenting.medleyArray.isEmpty {  // NO NEED TO SHOW PICKER UNTIL MEDLEY'S EXIST
                    // FIXME: UI WILL NOT UPDATE TO REFLECT SAVED CHANGES (MEDLEY)
                    // SELECT MEDLEY'S BY STATUS
                    Picker("Select Status", selection: $selectedStatus) {
                        ForEach(Status.allCases, id: \.self) { status in
                            Text(status.rawValue.uppercased()).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }

                // LISTED MEDLEY
                medleyList
            }
            
            // FADE BACKGROUND AS IT IS A DISTRACTION
            if isAddingMedley || isEditingScenting {
                withAnimation {
                    Color.white.opacity(0.8).ignoresSafeArea(.all)
                }
            }
        }
        .sheet(isPresented: $isEditingScenting) { sheetScentingRename }
        .sheet(isPresented: $isAddingMedley)    { sheetMedleyAdd }
        .toolbar {
            /// RENAME CURRENT SCENTING CATEGORY
            ToolbarItem(placement   : .navigationBarTrailing) {
                Button(action       : { isEditingScenting.toggle() })
                { Image(systemName  : "pencil") }
            }
            /// CREATE NEW MEDLEY
            ToolbarItem(placement   : .navigationBarTrailing) {
                Button(action       : { isAddingMedley.toggle() })
                { Image(systemName  : "plus") }
            }
        }
        // WORKAROUND : TITLE REMAINS ON TOP UNLESS HIDDEN (B/G FADE)
        .navigationTitle(withAnimation { isEditingScenting || isAddingMedley ? "" : scenting.nameUnwrapped } )        
    }
    
    /// LIST SPECIFIC MEDLEYS FROM SCENTING CATEGORIES
    var medleyList: some View {
        ScrollView {
            ForEach(filteredMedleys, id: \.self) { medley in
                NavigationLink(destination: MedleyDetailView(medley: medley, scenting: scenting)) {
                    CustomText(text: medley.nameUnwrapped)
                }
            }
            .padding()
        }
    }
    
    /// EDIT CURRENT SCENTING NAME
    var sheetScentingRename: some View {
        EditScentingEntryView(scenting      : scenting,
                              existingItems : extractScentingNames(from: existingScenting),
                              defaultText   : scenting.nameUnwrapped,
                              onRename      : renameScenting)
            .presentationDetents([.medium])
    }
    
    /// CORE DATA : RENAME SCENTING CATEGORY
    private func renameScenting(withName newName: String) {
        scenting.name = newName
        save()
    }
    
    /// CREATE NEW MEDLEY
    var sheetMedleyAdd: some View {
        AddMedleyView(scenting: scenting, existingItems: extractMedleyNames(from: scenting.medleyArray), onAddMedley: addMedley)
    }
    
    /// CORE DATA : ADD MEDLEY
    private func addMedley(_ newData: Medley) {
        let newMedley           = Medley(context: viewContext)
        newMedley.name          = newData.name
        newMedley.period        = newData.period
        newMedley.status        = newData.status
        newMedley.destination   = newData.destination
        newMedley.maturity      = newData.maturity
        newMedley.conclusion    = newData.conclusion
        newMedley.ingredient    = newData.ingredient
        
        newMedley.status        = Status.fromEnum(.tbd)     // DEFAULT TO TBD AS IT IS A NEW EXPERIMENT
        newMedley.created       = Date()                    // DEFAULT TO PRESENT DATE
        newMedley.scenting      = scenting                  // CURRENT CATEGORY
                
        save()
    }
    
    /// CONVENIENCE : SAVE TO PERSISTENT MEMORY (CORE DATA)
    private func save() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    /// CONVENIENCE : CONVERT DATA TO STRINGS (IT'S EITHER THAT OR A CUMBERSOME GENERIC)
    private func extractScentingNames(from scenting: FetchedResults<Scenting>) -> [String] {
        return scenting.map { $0.name ?? "Unknown" }
    }
    
    /// CONVENIENCE : CONVERT DATA TO STRINGS (IT'S EITHER THAT OR A CUMBERSOME GENERIC)
    private func extractMedleyNames(from scenting: [Medley]) -> [String] {
        return scenting.map { $0.name ?? "Unknown" }
    }
}

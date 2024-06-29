//
//  ScentingMainView.swift
//  ParfumVI
//
//  Created by 🐯 on 27/05/2024.
//

import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: Scenting.fetch(), animation: .default)
    private var scenting: FetchedResults<Scenting>
    
    @State private var isAddingScenting : Bool = false
    @State private var newName          : String = ""
    
    @AppStorage("isDemoUsed") private var isDemoUsed: Bool = false

    
    var body: some View {
        NavigationView {
            ZStack {
                FundamentalColours.backgroundStandard.ignoresSafeArea(.all)
                
                scentingList
                
                // FADE BACKGROUND AS IT IS A DISTRACTION
                if isAddingScenting {
                    withAnimation {
                        Color.white.opacity(0.8).ignoresSafeArea(.all)
                    }
                }
            }
            .sheet(isPresented: $isAddingScenting) { sheetScentingAdd }
            .toolbar {
                /// CREATE NEW SCENTING ENTRY
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingScenting.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
                if !isDemoUsed {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isDemoUsed = true
                            // I WILL ASSUME THAT "SHAMPOO" HAS NOT BEEN USED AS A SCENTING CATEGORY
                            // IF IT HAS IT MATTERS NOT, CORE DATA CAN HANDLE IT
                            // BUT I USUALLY DON'T ALLOW FOR IT
                            let scentTest       = Scenting.demo(context: viewContext)
                            let medleyTest      = Medley.demo(context: viewContext)
                            let ingredientI     = Ingredient.demoI(context: viewContext)
                            let ingredientII    = Ingredient.demoII(context: viewContext)
                            let ingredientIII   = Ingredient.demoIII(context: viewContext)
                            medleyTest.addToIngredient(ingredientI)
                            medleyTest.addToIngredient(ingredientII)
                            medleyTest.addToIngredient(ingredientIII)
                            scentTest.addToMedley(medleyTest)
                            save()
                        }) {
                            Text("demo")
                                .foregroundStyle(FundamentalColours.textAlert)
                        }
                    }
                }
            }
            // WORKAROUND : TITLE REMAINS ON TOP UNLESS HIDDEN (B/G FADE)
            .navigationTitle(withAnimation { isAddingScenting ? "" : "Scenting" } )
        }
    }
        
    /// LIST SCENTING NAMES
    var scentingList: some View {
        ScrollView {
            ForEach(scenting.sorted { $0.nameUnwrapped < $1.nameUnwrapped }, id: \.self) { scent in // ORGANISE ALPHABETICALLY
                NavigationLink(destination: ScentingDetailView(scenting: scent, existingScenting: scenting)) {
                    CustomText(text: scent.nameUnwrapped)
                }
            }
            .padding()
        }
    }
    
    /// CREATE NEW SCENTING CATEGORY
    var sheetScentingAdd: some View {
        AddScentingEntryView(existingItems  : extractScentingNames(from: scenting),
                             defaultText    : "New Scenting Entry...",
                             onAdd          : addScenting)
            .presentationDetents([.medium])
    }
    
    /// CORE DATA : ADD SCENTING CATEGORY
    private func addScenting(name: String) {
        withAnimation {
            let newScent = Scenting(context: viewContext)
            newScent.name = name
            save()
        }
    }
    
    /// CORE DATA : DELETE SCENTING CATEGORY
    private func deleteScenting(offsets: IndexSet) {
        withAnimation {
            offsets.map { scenting[$0] }.forEach(viewContext.delete)
            save()
        }
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
}

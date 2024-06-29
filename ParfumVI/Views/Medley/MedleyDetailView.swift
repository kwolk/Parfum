//
//  MedleyDetailView.swift
//  ParfumVI
//
//  Created by 🐯 on 26/05/2024.
//

import SwiftUI

struct MedleyDetailView: View {
    @ObservedObject var medley          : Medley
    @ObservedObject var scenting        : Scenting
    @State private var isAddingMedley   : Bool = false
    @State private var isEditing        : Bool = false
    @State private var isEditingMedley  : Bool = false
    
    
    // FIXME: VIEW SLIDING IN FROM TOP TRAILING ON-LOAD
    var body: some View {
        ZStack {
            FundamentalColours.backgroundStandard.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    // INGREDIENTS
                    sectionView(header: "Ingredients : \(medley.ingredientsArray.count)") {
                        ingredientCarousel
                    }
                    
                    // DESTINATION
                    sectionView(header: "Destination") {
                        CustomText(text: medley.destinationUnwrapped, align: .leading)
                    }
                    
                    // CONCLUSION (ONLY DISPLAY IF NOT EMPTY)
                    if medley.conclusionUnwrapped.isEmpty {
                        Divider()
                            .padding()
                    } else {
                        sectionView(header: "Conclusion : \(medley.statusUnwrapped)") {
                            MultilineTextFieldDisplay(text: medley.conclusionUnwrapped)
                        }
                    }
                    
                    // UPDATE (HIDE IF BLANK)
                    if !medley.updateUnwrapped.isEmpty {
                        sectionView(header: "Update") {
                            MultilineTextFieldDisplay(text: medley.updateUnwrapped)
                        }
                    }
                    // TILED DATA (MATURITY / STATUS / DATE AND ELAPSED TIME)
                    tileGrid
                }
                .padding(.horizontal, 17)
                .scrollIndicators(.hidden)
            }
            .padding(0)
        }
        .sheet(isPresented: $isEditingMedley) { editMedley }
        .navigationTitle(medley.nameUnwrapped)
        .toolbar {
            /// EDIT CURRENT MEDLEY
            ToolbarItem(placement   : .navigationBarTrailing) {
                Button(action       : { isEditingMedley.toggle() })
                { Image(systemName  : "pencil") }
            }
        }
    }

    var ingredientCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(medley.ingredientsArray, id: \.self) { ingredient in
                    TileView(base: ingredient.nameUnwrapped,
                             centered: "",
                             split: (Int(ingredient.amount), ingredient.unitUnwrapped),
                             scale: .no)
                }
            }
        }
    }
    
    var tileMaturity: some View {
        TileView(base: "Maturity",
                 centered: "",
                 split: (Int(medley.maturity), "\(Period.name(for: Double(medley.maturity), period: medley.periodConverted))"),
                 scale: .yes)
    }
    
    var tileStatus: some View {
        TileView(base: "Status",
                 centered: medley.statusUnwrapped,
                 split: (0, ""),
                 scale: .yes)
    }
    
    var tileDate: some View {
        DateTile(date  : medley.createdUnwrapped,
                 amount: Int(differenceInDays(from: medley.createdUnwrapped, to: Date()) ?? 0))
                 //unit  : FundamentalText.formDays.rawValue)
    }
    
    /// CONTAINS : MATURITY / STATUS / DATE AND ELAPSED TIME
    var tileGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            tileMaturity
            //if Status.fromString(medley.statusUnwrapped) != .tbd { tileStatus }   // DISPLAY IF CONCLUSION FIELD IS HIDDEN
            tileDate
        }
    }
    
    var editMedley: some View {
        EditMedleyView(medley: medley, existingMedley: extractMedleyNames(from: scenting.medleyArray), medleyName: medley.nameUnwrapped)
    }
    
    /// MULTILINE TEXT : DISPLAY
    private struct MultilineTextFieldDisplay: View {
        var text: String

        var body: some View {
            // SCROLL VIEWS MAINTAINS SIZE OF VIEW SO ALL FIELDS ARE VISIBLE ON SCREEN
            ScrollView {
                Text(text)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(determineColour(forView: .textFieldForeground, inState: true))
                    .background(determineColour(forView: .textFieldBackground, inState: true))
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .cornerRadius(FundamentalDimensions.corner.rawValue)
        }
    }
    
    /// TILE : ELAPSED DAYS FROM MEDLEY'S DATE OF CREATION
    func differenceInDays(from startDate: Date, to endDate: Date) -> Int? {
        let calendar    = Calendar.current
        let components  = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day
    }

    /// CONVENIENCE : CONVERT DATA TO STRINGS (IT'S EITHER THAT OR A CUMBERSOME GENERIC)
    private func extractMedleyNames(from scenting: [Medley]) -> [String] {
        return scenting.map { $0.name ?? "Unknown" }
    }
}

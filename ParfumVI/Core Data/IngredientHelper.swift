//
//  IngredientHelper.swift
//  ParfumVI
//
//  Created by 🐯 on 29/05/2024.
//

import SwiftUI
import CoreData


extension Ingredient {
    
    convenience init(name: String, amount: Double, unit: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id     = UUID()
        self.name   = name
        self.amount = amount
        self.unit   = unit
    }
    
    // ONLY NEED TO READ
    public var idUnwrapped: UUID {
        id ?? UUID()
    }
    
    var nameUnwrapped: String {
        get { name ?? "Ingredient Name Missing" }
        set { name = newValue }
    }
    
    var amountToInt: Int {
        get { Int(amount) }
        set { amount = Double(newValue) }
    }

    var unitUnwrapped: String {
        get { unit ?? "Unknown Unit of Measure" }
        set { unit = newValue }
    }
    
    // CONVERT TO ENUM (GET)
    var unitConverted: Unit {
        Unit.fromString(unitUnwrapped) ?? .pipette
    }
    
    // CONVERT TO ENUM (GET/SET)
    var unitInOut: Unit {
        get { Unit.fromString(unitUnwrapped) ?? .pipette }
        set { unit = unitConverted.rawValue }
    }
    
    
    
    // ADD CODE INTO THE LIFECYCLE OF THE MANAGED OBJECT, ON CREATION
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(),   forKey: IngredientProperties.id)
        setPrimitiveValue("",       forKey: IngredientProperties.name)
        setPrimitiveValue(0.0,      forKey: IngredientProperties.amount)
        setPrimitiveValue("",       forKey: IngredientProperties.unit)
    }
    
    static func delete(_ item: Ingredient) {
        if let context = item.managedObjectContext {
            context.delete(item)
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    static func demoI(context: NSManagedObjectContext) -> Ingredient {
        Ingredient(name     : "Fennel",
                   amount   : 2,
                   unit     : "drops",
                   context  : context)
    }
    static func demoII(context: NSManagedObjectContext) -> Ingredient {
        Ingredient(name     : "Orange",
                   amount   : 3,
                   unit     : "drops",
                   context  : context)
    }
    static func demoIII(context: NSManagedObjectContext) -> Ingredient {
        Ingredient(name     : "Nutmeg",
                   amount   : 1,
                   unit     : "g",
                   context  : context)
    }
}

struct IngredientProperties {
    static let id       = "id"
    static let name     = "name"
    static let amount   = "amount"
    static let unit     = "unit"
}



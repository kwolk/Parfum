//
//  MedleyHelper.swift
//  ParfumVI
//
//  Created by 🐯 on 26/05/2024.
//

import SwiftUI
import CoreData


extension Medley {
    
    convenience init(name: String, created: Date, period: String, status: String, update: String, destination: String, maturity: Int16, conclusion: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id             = UUID()
        self.name           = name
        self.created        = created
        self.period         = period
        self.status         = status
        self.update         = update
        self.destination    = destination
        self.maturity       = maturity
        self.conclusion     = conclusion
    }
    
    var nameUnwrapped: String {
        get { name ?? "Medley Name Missing" }
        set { name = newValue }
    }
    
    var createdUnwrapped: Date {
        get { created ?? Date() }
        set { created = newValue }
    }
    
    var periodUnwrapped: String {
        get { period ?? "Period Name Missing" }
        set { period = newValue }
    }
    
    // CONVERT TO ENUM (GET)
    var periodConverted: Period {
        Period.fromString(periodUnwrapped) ?? .day
    }
    
    // CONVERT TO ENUM (GET/SET)
    var periodInOut: Period {
        get { Period.fromString(periodUnwrapped) ?? .day }
        set { period = periodConverted.caseName }
    }
    
    var statusUnwrapped: String {
        get { status ?? "Status Name Missing" }
        set { status = newValue }
    }
    
    var statusEnum: Status {
        get { Status.fromString(statusUnwrapped) ?? .tbd }
        set { status = Status.fromEnum(newValue) }
    }
    
    var updateUnwrapped: String {
        get { update ?? "Update Name Missing" }
        set { update = newValue }
    }
    
    // CONVERT TO ENUM (GET/SET)
    var maturityInOut: Int {
        get { Int(maturity) }
        set { maturity = Int16(newValue) }  // CORE DATA IS VERY SPECIFIC WITH VALUES, WHERE AS SWIFT USES INFERENCE
    }
    
    var conclusionUnwrapped: String {
        get { conclusion ?? "Conclusion Name Missing" }
        set { conclusion = newValue }
    }
    
    var destinationUnwrapped: String {
        get { destination ?? "Destination Name Missing" }
        set { destination = newValue }
    }
        
    var ingredientsArray: [Ingredient] {
        get {
            let set = ingredient as? Set<Ingredient> ?? []
            return set.sorted {
                $0.name ?? "" < $1.name ?? ""
            }
        }
        set { ingredient = NSSet(array: newValue) }
    }
    
    // ADD CODE INTO THE LIFECYCLE OF THE MANAGED OBJECT, ON CREATION
    public override func awakeFromInsert() {
        setPrimitiveValue(UUID(),   forKey: MedleyProperties.id)
        setPrimitiveValue("",       forKey: MedleyProperties.name)
        setPrimitiveValue(Date(),   forKey: MedleyProperties.created)
        setPrimitiveValue("",       forKey: MedleyProperties.period)
        setPrimitiveValue("",       forKey: MedleyProperties.status)
        setPrimitiveValue("",       forKey: MedleyProperties.update)
        setPrimitiveValue("",       forKey: MedleyProperties.destination)
        setPrimitiveValue(0,        forKey: MedleyProperties.maturity)
        setPrimitiveValue("",       forKey: MedleyProperties.conclusion)
    }
    
    static func delete(_ item: Medley) {
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
        
    static func fetch(for scenting: Scenting) -> NSFetchRequest<Medley> {
        let request             = NSFetchRequest<Medley>(entityName: "Medley")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Medley.name, ascending: true)]
        request.predicate       = NSPredicate(format: "parentItem == %@", scenting)
        return request
    }
        
    static func fetchMedleys() -> NSFetchRequest<Medley> {
        let request             = NSFetchRequest<Medley>(entityName: "Medley")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Scenting.name, ascending: false)]
        request.predicate       = NSPredicate(format: "TRUEPREDICATE")
        return request
    }

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
    
    // RANDOM DATE CREATION (TESTING)
    private static func randomDate() -> Date {
        let calendar        = Calendar.current
        var components      = DateComponents()
        components.year     = 2023
        components.month    = 7
        components.day      = Int.random(in: 1...31)
        return calendar.date(from: components)!
    }
}

struct MedleyProperties {
    static let id           = "id"
    static let name         = "name"
    static let created      = "created"
    static let period       = "period"
    static let status       = "status"
    static let update       = "update"
    static let destination  = "destination"
    static let maturity     = "maturity"
    static let conclusion   = "conclusion"
}



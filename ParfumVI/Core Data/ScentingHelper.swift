//
//  ScentingHelper.swift
//  ParfumVI
//
//  Created by 🐯 on 26/05/2024.
//

import CoreData


extension Scenting {
    
    convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
    }
    
    var nameUnwrapped: String {
        get { name ?? "Name Missing" }
        set { name = newValue }
    }
    
    var medleyArray: [Medley] {
        let set = medley as? Set<Medley> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }
    
    // ADD CODE INTO THE LIFECYCLE OF THE MANAGED OBJECT, ON CREATION
    public override func awakeFromInsert() {
        setPrimitiveValue("", forKey: ScentingProperties.name)
    }
    
    static func delete(_ scenting: Scenting) {
        if let context = scenting.managedObjectContext {
            context.delete(scenting)
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
        
    static func fetch() -> NSFetchRequest<Scenting> {
        let request             = NSFetchRequest<Scenting>(entityName: "Scenting")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Scenting.name, ascending: false)]
        request.predicate       = NSPredicate(format: "TRUEPREDICATE")
        return request
    }
    
    static func demo(context: NSManagedObjectContext) -> Scenting {
        Scenting(name: "Dish Soap", context: context)
    }
}


struct ScentingProperties {
    static let name = "name"
}




// TODO: CONFORM TO PROTOCOLS TO PASS DATA THROUGH GENERIC

//extension Scenting: Identifiable {
//    // Assuming 'name' is the primary identifying attribute
//    public var id: NSManagedObjectID {
//        return objectID
//    }
//}

//extension Scenting: Comparable {
//    public static func < (lhs: Scenting, rhs: Scenting) -> Bool {
//        return lhs.nameUnwrapped < rhs.nameUnwrapped
//    }
//}

//extension Scenting: CustomStringConvertible {
//    public var description: String {
//        return nameUnwrapped
//    }
//}

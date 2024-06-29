//
//  Persistence.swift
//  ParfumVI
//
//  Created by 🐯 on 26/05/2024.
//
//
// DELETE RULES
//
// NULLIFY : EMPLOYEE WILL REMAIN IN THE SYSTEM, BUT WILL HAVE THE DEPARTMENT REMOVED FROM THEIR ENTRY
// CASCADE : ALL EMPLOYEES TIED TO DEPARTMENT WILL BE REMOVED FROM THE SYSTEM
// DENY : THE DEPARTMENT CANNOT BE DELETED UNTIL ALL DEPENDENCIES HAVE BEEN REMOVED e.g. EMPLOYEES


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()


    // SWIFTUI PREVIEW (WHICH I DON'T USE)
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)  // NEWLY CREATED (EMPTY)
        let viewContext = result.container.viewContext
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // NO DATA FOR USE WORKING WITH CORE DATA STACK
    static var empty: PersistenceController {
        PersistenceController(inMemory: true)
    }

    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ParfumModel")
        if inMemory {
            // CREATES PERSISTEN CONTROLLER THAT IS NOT STORED IN MEMORY
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    
    func save2(_: NSManagedObjectContext) {
        let viewContext = container.viewContext
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func save() {
        let viewContext = container.viewContext
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

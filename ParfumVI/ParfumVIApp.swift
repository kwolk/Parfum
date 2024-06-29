//
//  ParfumVIApp.swift
//  ParfumVI
//
//  Created by 🐯 on 26/05/2024.
//
//
// MY FIRST MVVM (h/t : Karin Prater)
// THIS MODEL SHOULD NEGATE THE NEED FOR OBJECTS (SCENTING (CATEGORIES) AND MEDLEY (EXPERIMENTS))
// INTERFACING WITH CORE DATA FIA FETCH REQUESTS AND OBSERVABLE PROPERTY WRAPPERS
// NICE AND SLICK.
//
//

import SwiftUI

@main
struct DemoParfumIApp: App {
    let persistenceController = PersistenceController.shared

    @Environment(\.scenePhase) var scenePhase   // MONITOR SCENE
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(FundamentalColours.textFieldForegroundActive)    // TOOLBAR ACCENT COLOUR
                .statusBar(hidden: true)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        // CALL WHEN SCENE CHANGES (e.g. TO SAVE DATA)
        .onChange(of: scenePhase) {
            
            print("PHASE : \($0)")
            
            switch $0 {
            case .background : persistenceController.save()
            default : break
            }
        }
    }
}

//
//@main
//struct MyApp: App {
//    let persistenceController = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            T1_MedleyView(medley: persistenceController.container.viewContext)
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//        }
//    }
//}
//






// FIXME: SETTINGS : IMPORT / EXPORT CSV ?
// FIXME: SETTINGS : SHAKE : NEUMORPHISM (LIGHTING ROTATES i.e. MAPS)
// FIXME: SETTINGS : PURGE ALL MEDLEYS (CONFIRM BY TYPING IN RANDOM WORD AND ALERT DIALOGUE)
// FIXME: ADD CALENDAR EVENT / REMINDER FROM MATURITY DATA e.g. 2 WEEK TIME
// FIXME: RETAIN TEMP MEDLEY DATA ON ADD FOR 30sec
// FIXME: ALTERNATIVE ICONS +DARK MODE (ICONS EXIST)

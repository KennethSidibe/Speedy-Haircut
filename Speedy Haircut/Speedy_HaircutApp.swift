//
//  Speedy_HaircutApp.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import Firebase


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}


@main
struct Speedy_HaircutApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

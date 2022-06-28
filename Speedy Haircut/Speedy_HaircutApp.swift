//
//  Speedy_HaircutApp.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import Firebase


@main
struct Speedy_HaircutApp: App {
    
//    This pass the UIKit Delegate to our app EXTREMELY NECESSARY
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            
            let authBrain = AuthenticationBrain()
            
            ContentView()
                .environmentObject(authBrain)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}

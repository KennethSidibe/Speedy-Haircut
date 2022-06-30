//
//  loginBrain.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import Foundation
import Firebase

class AuthenticationBrain: ObservableObject {
    
    let auth = Auth.auth()
    
//    Reponsible to check if the user is already signed in or no
    @Published var signIn = false
    var isSignin:Bool {
        return auth.currentUser != nil
    }
    
    func signUp(username:String, password:String) {
        
        auth.createUser(withEmail: username, password: password) { [weak self] (result, error) in
            
//            Avoid memory leak
            guard let self = self else { return }
            
            guard result != nil, error == nil else {
                print("SignUp Error, \(error)")
                return
            }
            

            DispatchQueue.main.async {
                
            // Sign Up Successful
                print("user sign in successfully")
                self.signIn = true
            }
            
            
        }
        
    }
    
    func signOut() {
        
        do {
            try auth.signOut()
            self.signIn = false
        } catch {
            print("Failed to signout, \(error)")
        }
        
    }
    
    func signIn(username:String, password:String) {
        
        print("signing in with \n username \(username) \n password \(password)")
        
        auth.signIn(withEmail: username, password: password) { [weak self] result, error in
            
            guard let self = self else { return }
            
            guard result != nil, error == nil else {
                print("Login Error, \(error)")
                return
            }
            

            DispatchQueue.main.async {
                
                // Sign In Successful
                
                print("user sign in successfully")
                self.signIn = true
            }
            
        }
        
    }
    
}

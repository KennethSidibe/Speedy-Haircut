//
//  loginBrain.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import Foundation
import Firebase

class AuthenticationBrain: ObservableObject {
    
    //MARK: - Properties
    private let auth = Auth.auth()
//    Reponsible to check if the user is already signed in or no
    @Published private var signIn = false
    var isSignin:Bool {
        return auth.currentUser != nil
    }
    
    //MARK: - GET Methods
    func getSignedUserUid() -> String? {
        return auth.currentUser?.uid
    }
    
    func isSignedIn() -> Bool {
        return self.signIn
    }
    
    //MARK: - Set methods
    func setIsSignedIn(_ newValue:Bool) {
        self.signIn = newValue
    }
    
    //MARK: - Authentication methods
    func signUp(username:String, password:String, firstName: String, lastName: String, completionHandler: @escaping () -> ()) {
        
        auth.createUser(withEmail: username, password: password) { [weak self] (result, authError) in
            
            let db = Firestore.firestore()
            
//            Avoid memory leak
            guard let self = self else { return }
            
            guard result != nil, authError == nil else {
                print("SignUp Error, \(authError)")
                return
            }
            
            //MARK: - Create user in db
            
            let newUser = [
                "firstName": firstName,
                "lastName": lastName,
                "lineNumber": 0
            ] as! [String: Any]
            
            let newUserUid = result!.user.uid
            
            db.collection(K.userCollectionName).document(newUserUid).setData(newUser) { dbError in
                
                guard dbError == nil else {
                    print("Error while writing new user data to db, \(dbError)")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    // Sign Up Successful
                    print("user sign up successfully signin true")
                    
                    self.signIn = true
                    
                    print("user sign up successfully signIn : \(self.signIn)")
                    
                    completionHandler()
                    
                }
                
            }
            
        }
        
    }
    
    func signIn(username:String, password:String) {
        
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
    
    func signOut() {
        
        do {
            try auth.signOut()
            self.signIn = false
        } catch {
            print("Failed to signout, \(error)")
        }
        
    }
    
}

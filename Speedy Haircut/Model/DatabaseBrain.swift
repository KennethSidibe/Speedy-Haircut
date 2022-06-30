//
//  DatabaseBrain.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-29.
//

import Foundation
import Firebase

class DatabaseBrain: ObservableObject {
    
    ///MARK: - Properties
    
    @Published var user = User()
    
//    Reference to the db
    let db = Firestore.firestore().collection(K.userCollectionName).document("KennethS")
    
    @Published var isDataAvailable = false

    
    //MARK: - GET Data
    
    func getData( completionHandler: @escaping (User?) -> () ) {
        
        let currentUser = User()
        
        db.getDocument { snapshot, error in
            
            if let document = snapshot?.data()  {
                
                currentUser.id = document["id"] as? String
                currentUser.firstName = document["firstName"] as? String
                currentUser.lastName = document["lastName"] as? String
                currentUser.lineNumber = document["lineNumber"] as? Int
                currentUser.photo = "pic.jpg"
                
                completionHandler(currentUser)
                
            } else {
                
                print("Error while getting doc data, \(String(describing: error))")
                
                completionHandler(nil)
            }
            
        }
        
    }
    
}

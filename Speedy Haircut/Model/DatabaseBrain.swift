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
    var userUid:String = ""
    
//    Reference to the db
    let db = Firestore.firestore().collection(K.userCollectionName)
    
    @Published var isDataAvailable = false

    
    //MARK: - GET Data
    
    func getData( completionHandler: @escaping (User?) -> () ) {
        
        let currentUser = User()
        let docReference = db.document(userUid)
        
        docReference.getDocument { snapshot, error in
            
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

//
//  DatabaseBrain.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-29.
//

import Foundation
import Firebase

class DatabaseBrain: ObservableObject {
    
    //MARK: - Properties
    
    @Published var user = User()
    var userUid:String = ""
    var sortBrain = QuickSort()
    
//    Reference to the db
    let db = Firestore.firestore()
    
    @Published var isDataAvailable = false
    
    //MARK: - GET Data
    
    func getUserData(with uId:String, completionHandler: @escaping (User?) -> () ) {
        
        let currentUser = User()
        let docReference = db.collection(K.userCollectionName).document(uId)
        
        docReference.getDocument { snapshot, error in
            
            if let document = snapshot?.data()  {
                
                currentUser.id = docReference.documentID
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
    
    func addToQueue(completionHandler: @escaping (Int) -> ()) {
            
        let docReference = db.collection(K.globalCollectionName).document(K.queueDataIdName)
        
        docReference.getDocument { snapshot, error in
            
            if let document = snapshot?.data()  {
                
                self.user.lineNumber = document["peopleInLine"] as! Int + 1
                
                let newQueueNumber = ["lineNumber" : self.user.lineNumber]
                
                self.updateQueueData {
                    
                    self.updateUserData(with: self.user.id!, data: newQueueNumber as [String : Any]) {
                        
                        completionHandler(self.user.lineNumber!)
                        
                    }
                }
                
            } else {
                
                print("Error while getting doc data, \(String(describing: error))")
                
                
            }
            
        }
        
    }
    
    func updateUserData(with userId:String, data:[String:Any], completionHandler: @escaping () -> ()) {
        
        let docReference = db.collection(K.userCollectionName).document(user.id!)
        
        docReference.updateData(data) { updateError in
            
            guard updateError == nil else {
                print("Error while updating userData, \(String(describing: updateError))")
                return
            }
            
            completionHandler()
        }
        
    }
    
    func updateQueueData(completionHandler: @escaping () -> ()) {
        
        let docReference = db.collection(K.globalCollectionName).document(K.queueDataIdName)
        
        let updateLineDoc = ["peopleInLine" : self.user.lineNumber]
        
        docReference.updateData(updateLineDoc) { updateError in
            
            guard updateError == nil else {
                print("Error while updating userData, \(String(describing: updateError))")
                return
            }
            
            completionHandler()
        }
        
    }
    
    func fetchQueueList(completionHandler: @escaping([User]) -> ()) {
        
        let dbReference = db.collection(K.userCollectionName)
        
        dbReference.getDocuments() { snapshot, error in
            
            if let snapshot = snapshot {
                
                var userList = [User]()
                
                for document in snapshot.documents {
                    
                    var user = User()
                    
                    user.id = document.documentID
                    user.firstName = document["firstName"] as? String
                    user.lastName = document["lastName"] as? String
                    user.lineNumber = document["lineNumber"] as? Int
                    user.photo = "pic.jpg"
                    
                    userList.append(user)
                    
                }
                
                self.sortBrain.sortQuick(array: &userList)
                
                completionHandler(userList)
                
            }
            
        }
        
    }
    
    func fetchReservationList(completionHandler: @escaping([Reservation]) -> ()) {
        
        let dbReference = db.collection(K.reservationCollectionName)
        
        dbReference.getDocuments() { snapshot, error in
            
            if let snapshot = snapshot {
                
                var reservationList = [Reservation]()
                
                for document in snapshot.documents {
                    
                    let reservation = Reservation()
                    
                    reservation.id = document.documentID
                    reservation.clientName = document["clientName"] as? String
                    
                    guard let dateFetch = document["date"] as? TimeInterval else {
                        print("Error while parsing firestore date field to Timestamp")
                        return
                    }
                    
                    reservation.date = Date(timeIntervalSince1970: dateFetch)
                    
                    reservationList.append(reservation)
                    
                }
                
                completionHandler(reservationList)
                
            } else {
                print("Could not fetch reservations documents, \(String(describing: error))")
                return
            }
            
        }
        
    }
    
    func bookReservation(client:String) {
        
        
        
    }
    
    func CalculateAvailableSlot(){
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
}

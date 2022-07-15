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
    
    @MainActor
    func fetchQueueList() async -> ([QueueUser], [Date]) {
        
        let dbReference = db.collection(K.QueueCollectionName)
        
        do {
            let snapshot = try await dbReference.getDocuments()
            
            var queueList = [QueueUser]()
            var queueDates = [Date]()
            
            for document in snapshot.documents {
                
                let timestamp = document["timeEnteredQueue"] as? Timestamp
                
                let date = timestamp?.dateValue()
                let id = document.documentID
                let name = document["name"] as? String
                let lineNumber = document["lineNumber"] as? Int
                
                let queueUser = QueueUser(id: id, name: name, lineNumber: lineNumber, timeEnteredQueue: date)
                
                print(timestamp)
                
                queueList.append(queueUser)
                queueDates.append(queueUser.timeEnteredQueue ?? Date())
                
            }
            
            self.sortBrain.sortQuick(array: &queueList)
            
            return (queueList, queueDates)
            
        } catch {
            print("Error while retrieveing queueList from db, \(error)")
            return ([], [])
        }
        
    }
    
    @MainActor
    func fetchReservationList() async -> ([Reservation], [Date]) {
        
        let dbReference = db.collection(K.reservationCollectionName)
        
        do {
            
            let snapshot = try await dbReference.getDocuments()
            
            var reservationList = [Reservation]()
            var reservationDate = [Date]()
            
            for document in snapshot.documents {
                
                let reservation = Reservation()
                
                reservation.id = document.documentID
                reservation.clientName = document["clientName"] as? String
                
                guard let dateFetch = document["date"] as? Timestamp else {
                    print("Error while parsing firestore date field to Timestamp")
                    return ([], [])
                }
                
                reservation.date = dateFetch.dateValue()
                
                reservationList.append(reservation)
                reservationDate.append(reservation.date ?? Date())
                
            }
            
            self.sortBrain.sortQuick(array: &reservationList)
            
            return (reservationList, reservationDate)
            
        } catch {
            print("Could not fetch reservations documents, \(String(describing: error))")
            return ([], [])
        }
        
    }
    
    func bookReservation(client:String) {
        
        
    }
    
    @MainActor
    func CalculateAvailableSlot() async  {
        
        let queueList = await fetchQueueList()
        let reservations = await fetchReservationList()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        guard queueList != ([], []), reservations != ([], []) else {
            print("Error while retrieveing queueList and reservationsList")
            return
        }
        
        
        
    }
    
    func getDateInterval() -> ClosedRange<Date> {
        
        let today = Date()
        let yearInSeconds = TimeInterval(86400*365)
        
        let dateInterval = DateInterval(start: today, duration: yearInSeconds)
        
        let range:ClosedRange<Date> = dateInterval.start...dateInterval.end
        
        return range
        
    }
    
    func isDateAvailable(date:Date, queueDates:[Date], reservationDates:[Date]) -> Bool {
        
        
        
        
        return true
        
    }
    
    
}


extension Date: Strideable {
    
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
    
    func isBetween(start:Date, end:Date) -> Bool {
        
        guard start < end else {
            print("startDate is superior to end date")
            return false
        }
        
        let range = start...end
        
        return range.contains(self)
        
    }
}

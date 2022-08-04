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
    @Published var t = 0
    @Published private var user = User()
    private var userUid:String = ""
    private var sortBrain = QuickSort()
    @Published private var reservations:([Reservation], [Date])?
    @Published private var queueList:([QueueUser], [Date])?
    @Published private var isBookingDataUpdated:Bool = false
//    Reference to the db
    private let db = Firestore.firestore()
    @Published private var isUserDataFetched = false
    
    
    //MARK: - GET methods
    func getUserData(with uId:String) async -> User? {
        
        let currentUser = User()
        let docReference = db.collection(K.userCollectionName).document(uId)
        
        do {
            
            let snapshot = try await docReference.getDocument()
            
            if let document = snapshot.data()  {
                
                currentUser.id = docReference.documentID
                currentUser.firstName = document["firstName"] as? String
                currentUser.lastName = document["lastName"] as? String
                currentUser.lineNumber = document["lineNumber"] as? Int
                currentUser.photo = "pic.jpg"
                
                return currentUser
                
            }
            
        } catch {
            print("Error while getting doc data, \(String(describing: error))")
            return nil
        }
        
        return nil
        
    }
    
    func fetchBookingData(completionHandler: @escaping ( ( ([Reservation], [Date]),
                                                           ([QueueUser], [Date]) ) ) -> ()) {
        
            var reservations:([Reservation], [Date]) = ([Reservation](), [Date]() )
            var queueList:([QueueUser], [Date]) = ( [QueueUser](), [Date]() )
            
            fetchReservations { fetchedReservations in
                
                reservations = fetchedReservations
                
                self.fetchQueueList { fetchedQueuelist in
                    
                    queueList = fetchedQueuelist
                    
                    self.reservations = reservations
                    self.queueList = queueList
                    self.isBookingDataUpdated = true
                    
                    completionHandler( (reservations, queueList) )
                    
                    
                }
            }
            
    }
    
    func fetchReservations(completionHandler: @escaping ( ([Reservation], [Date]) ) -> () ) {
        
        let reservationsDocReference = db.collection(K.reservationCollectionName)
        
        var reservationsDate:[Date] = [Date]()
        var reservations:[Reservation] = [Reservation]()
        
//        Fetch reservations data
        let reservationsSnapshot = reservationsDocReference.addSnapshotListener { snapshot, error in
            
            reservationsDate = []
            reservations = []
            
            guard error == nil else {
                print("Error while loading reservation data, \(String(describing: error))")
                return
            }
            
            if let docs = snapshot?.documents {
                
                for doc in docs {
                    
                    let clientName = doc["clientName"] as! String
                    let date = doc["date"] as! Timestamp
                    let reservationId = doc.documentID
                    
                    let newReservation = Reservation(id: reservationId,
                                                     clientName: clientName,
                                                     date: date.dateValue())
                    
                    reservationsDate.append(date.dateValue())
                    reservations.append(newReservation)
                    
                }
                
                completionHandler( (reservations, reservationsDate) )
                
            }
            
        }
        
    }
    
    func fetchQueueList(completionHandler: @escaping (([QueueUser], [Date])) -> ()) {
        
        //        Fetch queueData
        let queueDocReference = db.collection(K.QueueCollectionName)
        
        var queueDates:[Date] = [Date]()
        var queueList:[QueueUser] = [QueueUser]()
        
        let queueSnapshot = queueDocReference.addSnapshotListener { snapshpot, error in
            
            queueList = []
            queueDates = []
            
            guard error == nil else {
                print("Error while loading reservation data, \(String(describing: error))")
                return
            }
            
            if let documents = snapshpot?.documents {
                
                for document in documents {
                    
                    let timestamp = document["timeEnteredQueue"] as? Timestamp
                    
                    let date = timestamp?.dateValue()
                    let id = document.documentID
                    let name = document["name"] as? String
                    let lineNumber = document["lineNumber"] as? Int
                    
                    let queueUser = QueueUser(id: id, name: name, lineNumber: lineNumber, timeEnteredQueue: date)
                    
                    queueList.append(queueUser)
                    queueDates.append(queueUser.timeEnteredQueue ?? Date())
                    
                }
                
                completionHandler( (queueList, queueDates) )
                
            }
        }
        
    }
    
    //MARK: - SET methods
    func setDatabaseBrain() async {
        
        let reservations = await fetchReservationList()
        let queueList = await fetchQueueList()
        
        self.reservations = reservations
        self.queueList = queueList
        
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
                
                let reservationId = document.documentID
                let clientName = document["clientName"] as? String
                
                guard let dateFetch = document["date"] as? Timestamp else {
                    print("Error while parsing firestore date field to Timestamp")
                    return ([], [])
                }
                
                let reservation = Reservation(
                    id: reservationId,
                    clientName: clientName ?? "client",
                    date: dateFetch.dateValue())
                
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
    
    func bookReservation(client:String, date:Date, completionHandler: @escaping () -> ()) {
        
        let dbReference = db.collection(K.reservationCollectionName)
        
        let newReservation = [
            "clientName": client,
            "date": date
        ] as! [ String:Any ]
        
        let reservationId = UUID().uuidString
        
        dbReference.document(reservationId).setData(newReservation) { error in
            
            guard error == nil else {
                print("Error while creating reservations, \(String(describing: error))")
                return
            }
            
            completionHandler()
            
        }
        
    }
}

//MARK: - Get methods
extension DatabaseBrain {
    
    func getReservations() -> ([Reservation], [Date])? {
        return reservations
    }
    
    func getQueueList() -> ([QueueUser], [Date])?{
        return queueList
    }
    
    func getUser() -> User {
        return self.user
    }
    
    func getUserLineNumber() -> Int? {
        return self.user.lineNumber
    }
    
    func getUserFirstName() -> String? {
        return self.user.firstName
    }
    
    func getUserUid() -> String? {
        return self.user.id
    }
    
    func isUserDataAvailable() -> Bool {
        return self.isUserDataFetched
    }
    
    func hasDataUpdated() -> Bool {
        return self.isBookingDataUpdated
    }
    
    func getReservationsDate() -> [Date]? {
        return self.reservations?.1
    }
    
    func getReservations() -> [Reservation]? {
        return self.reservations?.0
    }
    
    func getQueueList() -> [QueueUser]? {
        return self.queueList?.0
    }
    
    func getQueueListDates() -> [Date]? {
        return self.queueList?.1
    }

}

//MARK: - Set methods
extension DatabaseBrain {
    
    func setUser(user:User) {
        self.user = user
    }
    
    func setUserUid(userUid:String) {
        self.user.id = userUid
    }
    
    func setIsBookingDataAvailable(_ newValue: Bool) {
        self.isBookingDataUpdated = newValue
    }
    func bookingDataHasBeenUpdated() {
        self.isBookingDataUpdated = false
    }
    func setisUserDataFetched(_ newValue:Bool) {
        self.isUserDataFetched = newValue
    }
    func userDataHasBeenFetched() {
        self.isUserDataFetched = true
    }
    
    
}

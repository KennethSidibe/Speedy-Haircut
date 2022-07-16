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
    
    func bookReservation(client:String, date:Date) {
        
        let dbReference = db.collection(K.reservationCollectionName)
        
        let newReservation = [
            "clientName": client,
            "date": date
        ] as! [ String:Any ]
        
        let reservationId = UUID().uuidString
        
        dbReference.document(reservationId).setData(newReservation) { error in
            
            guard error == nil else {
                print("Error while creating reservations, \(error)")
                return
            }
            
        }
        
    }
    
    @MainActor
    func CalculateAvailableSlot() async  {
        
        let queueList = await fetchQueueList().1
        let reservations = await fetchReservationList().1
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        var localTimeZoneName:String { return TimeZone.current.abbreviation() ?? "UTC-4" }
        formatter.timeZone = TimeZone(identifier: localTimeZoneName)
        
        guard queueList != [], reservations != [] else {
            print("Error while retrieveing queueList and reservationsList")
            return
        }
        
        let date = formatter.date(from: "18-07-2022 10:00") ?? Date()
        
        getTimeReservable(date: date, queueTimeList: queueList)
        
    }
    
    func getDateInterval() -> ClosedRange<Date> {
        
        let today = Date()
        let yearInSeconds = TimeInterval(86400*365)
        
        let dateInterval = DateInterval(start: today, duration: yearInSeconds)
        
        let range:ClosedRange<Date> = dateInterval.start...dateInterval.end
        
        return range
        
    }
    
    func getTimeReservable(date: Date, queueTimeList:[Date]) {
        
        var increment = 5
        var minuteSlot:[Int] = {
            
            var array = [Int]()
            array.append(0)
            var lastElement = array[0]
            for _ in 0...10 {
                
                let numberToAdd = lastElement + increment
                
                if numberToAdd >= 60 {
                    break
                }
                
                array.append(numberToAdd)
                lastElement = numberToAdd
                
                
                
            }
            
            return array
            
        }()
        let hourSlot = 1...23
        
        var queueTimeSlot:([Int], [Int]) = {
            
            var hourArray = [Int]()
            var minuteArray = [Int]()
            
            queueTimeList.forEach { date in
                let hour = Calendar.current.component(.hour, from: date)
                let minutes = Calendar.current.component(.minute, from: date)
                hourArray.append(hour)
                minuteArray.append(minutes)
            }
            
            return (hourArray, minuteArray)
            
        }()
        
    }
    
    func isDateAvailable(date:Date, queueDates:[Date], reservationDates:[Date]) -> Bool {
        
        return true
        
    }
    
    func hasDayReachedMaximumReservations(date:Date, reservationsDate:[Date]) -> Bool {
        
        var count = 0
        
        for iterateDay in reservationsDate {
            
            if date.isSameDay(date1: date, date2: iterateDay) {
                
                count += 1
                
                if count >= 10 {
                    return true
                }
            }
            
        }
        
        return false
        
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
    
    func isSameDay(date1:Date, date2:Date) -> Bool {
        
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
            if diff.day == 0 {
                return true
            } else {
                return false
            }
        
    }
    
}

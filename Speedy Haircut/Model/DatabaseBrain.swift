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
        
        getTimeReservable(date: date, queueTimeList: queueList, reservationsDate: reservations)
        
    }
    
    func getDateInterval() -> ClosedRange<Date> {
        
        let today = Date()
        let yearInSeconds = TimeInterval(86400*365)
        
        let dateInterval = DateInterval(start: today, duration: yearInSeconds)
        
        let range:ClosedRange<Date> = dateInterval.start...dateInterval.end
        
        return range
        
    }
    
    func getTimeReservable(date: Date, queueTimeList:[Date], reservationsDate:[Date]) -> [ReservableTimeSlot] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
//        This variable is important because on even/odd days the store has different opening hour
        let WeekDayOfDate = Calendar.current.component(.weekday, from: date)
        
//        We set the opening hour in respect to the day that the user picked to reserve
        let openingHour =  WeekDayOfDate % 2 == 0 ? K.evenDayOpeningHour : K.oddDayOpeningHour
        
        let latestTime = queueTimeList.max()
        
        var reservableTimeSlot:[ReservableTimeSlot] = createReservationTimeSlot(lastTimeToReserve: latestTime, dateToReserve: date)
        
        
        var queueTimeSlot:[String] = {
            
            var timeArray = [String]()
            
            queueTimeList.forEach { date in
                
                let time = dateFormatter.string(from: date)
                
                timeArray.append(time)
                
            }
            
            return timeArray
            
        }()
        
//        If there is 0 any reservation for the date
        if !(isThereReservationOnDate(date: date, reservationsDate: reservationsDate)) {
            
            return reservableTimeSlot
            
        }
        else {
            
//            for date in reservationsDate {
            
//                  TODO
            
//            }
            
            return []
            
        }
        
    }
    
//    Check if a reservation already exist for the date provided
    func isThereReservationOnDate(date: Date, reservationsDate:[Date]) -> Bool {
        
        for iterateDay in reservationsDate {
            
            if date.isSameDay(date1: date, date2: iterateDay) {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    func createReservationTimeSlot(lastTimeToReserve:Date?, dateToReserve:Date) -> [ReservableTimeSlot] {
        
//        This variable is important because on even/odd days the store has different opening hour
        let WeekDayOfDate = Calendar.current.component(.weekday, from: dateToReserve)
                
//        We set the opening hour in respect to the day that the user picked to reserve
        let openingHour =  WeekDayOfDate % 2 == 0 ? K.evenDayOpeningHour : K.oddDayOpeningHour
        
        let hourSlot:[Int] = {
            
//            We set the first hour reservable by looking at the latest hour a person has entered the queue
            let firstHourReservable:Int
            if let lastTimeToReserve = lastTimeToReserve {
                firstHourReservable = Calendar.current.component(.hour, from: lastTimeToReserve)
            }
            else {
                firstHourReservable = openingHour
                
            }
            
            var array = [Int]()
            for i in firstHourReservable...K.closingHour {
                array.append(i)
            }
            return array
            
        }()
        
//        The minute of the firstHour to be reservable regarding the queue
        let lastestTimeMinuteComponent:Int
        
        if let lastTimeToReserve = lastTimeToReserve {
            lastestTimeMinuteComponent = Calendar.current.component(.minute, from: lastTimeToReserve)
        } else {
            lastestTimeMinuteComponent = 0
        }
        
        var reservationsTimeSlot:[ReservableTimeSlot] = [ReservableTimeSlot]()
        
//        We create the firstHoursSlot since it can be either at the opening of the store or the time after the last person has been added to the queue
        let firstHourMinutesSlot = createMinuteSlot(minuteToStart: lastestTimeMinuteComponent.roundToFiveDecimal())
        let firstReservationTimeSlot = ReservableTimeSlot(hour: hourSlot[0], minutes: firstHourMinutesSlot)
        reservationsTimeSlot.append(firstReservationTimeSlot)
        
        
        var i = 1
        
//        We create all the remaining hour to be removed/kept regarding the ongoing date reservation
        while i < hourSlot.count {
            
            let minutesSlot = createMinuteSlot(minuteToStart: 0)
            
            let currentHourReservationSlot = ReservableTimeSlot(hour: hourSlot[i], minutes: minutesSlot)
            
            reservationsTimeSlot.append(currentHourReservationSlot)
            
            i+=1
            
        }
        
        return reservationsTimeSlot
        
    }
    
    
//    This function creates an array representing the minutes slot it is an series of 5 ex [0, 5, 10, 15, ..., 60]
//    This will always return an incremented sequence of 5 that does not go above 55, 55 included
    func createMinuteSlot(minuteToStart:Int) -> [Int] {
        
        let increment = 5
        var array = [Int]()
        array.append(minuteToStart)
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
        
    }
    
//    Check if there was more reservation than the constant set in the files, ex 10 for now
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



//MARK: - Date Extension
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


//MARK: - Int Extension
extension Int {
    
//    Will return the closest five five multiplicant of a number, eg: 7 -> 10, 9 -> 10, 2 -> 5, 22 -> 25
    func roundToFiveDecimal() -> Int {
        
        let numberToAdd = 5 - (self % 5)
        
        return self + numberToAdd
        
    }
    
}

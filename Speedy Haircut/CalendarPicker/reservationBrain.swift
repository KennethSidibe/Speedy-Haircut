//
//  reservationBrain.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-19.
//

import Foundation

struct reservationBrain {
    
    private let queueList:[Date]
    private let reservations:[Date]
    private var pickedDate:Date?
    private var pickedTime:Date?
    private var dateFormatter:DateFormatter
    private var calendar:Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        
        return calendar
    }
    private var availableTimeSlot:[Int:[Int]]
    
    //MARK: - Get View Data
    func getPickedDate() -> Date {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return pickedDate ?? Date()
    }
    
    func getPickedDateString() -> String {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.string(from: self.pickedDate ?? Date())
    }
    
    func getPickedTime() -> Date {
        dateFormatter.dateFormat = "HH:mm"
        
        let hour = calendar.component(.hour, from: pickedTime ?? Date())
        let minutes = calendar.component(.minute, from: pickedTime ?? Date())
        
        let timeString = String(hour)+":"+String(minutes)
        
        return dateFormatter.date(from: timeString)!
    }
    
    func getPickedTimeString() -> String {
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: self.pickedTime ?? Date())
    }
    func getAvailableTimeSlot() -> [Int:[Int]] {
        return availableTimeSlot
    }
    
    //MARK: - Calculate Reservation Time Methods
    func CalculateAvailableSlot(dateSelected:Date, queueList:[Date], reservations:[Date]) -> [Int:[Int]] {
        
//        let queueList = await fetchQueueList().1
//        let reservations = await fetchReservationList().1
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        var localTimeZoneName:String { return TimeZone.current.abbreviation() ?? "UTC-4" }
        formatter.timeZone = TimeZone(identifier: localTimeZoneName)
        
        guard queueList != [], reservations != [] else {
            print("Error while retrieveing queueList and reservationsList")
            return [:]
        }
        
        let timeSlot = getTimeReservable(dateSelected: dateSelected, queueTimeList: queueList, reservationsDate: reservations)
        
        return timeSlot
        
    }
    
    func getTimeReservable(dateSelected: Date, queueTimeList:[Date], reservationsDate:[Date]) -> [Int : [Int]] {
        
        var latestTime = queueTimeList.max()
        
        if latestTime != nil {
            
            if !(dateSelected.isSameDay(date1: latestTime!, date2: dateSelected)) {
                latestTime = nil
            }
            
        }
        
//        A list that contains all the hours available to book if there is no reservation
        var availableTimeSlot:[ReservableTimeSlot] = createReservationTimeSlot(lastTimeToReserve: latestTime, dateToReserve: dateSelected)
        
//        If there is 0 reservation for the date
        if !(isThereReservationOnDate(date: dateSelected, reservationsDate: reservationsDate)) {
            
            let availableTimeSlotDict = Dictionary(
                uniqueKeysWithValues: availableTimeSlot.map(
                    { timeSlot in
                        (timeSlot.hour, timeSlot.minutes)
                    }
                )
            )
            
            return availableTimeSlotDict
            
        }
        else {
            
//            We remove the bookedSlot
            availableTimeSlot = removeBookedSlot(bookedDate: reservationsDate, dateSelected: dateSelected, availableTimes: availableTimeSlot)
            
            let availableTimeSlotDict = Dictionary(
                uniqueKeysWithValues: availableTimeSlot.map(
                    { timeSlot in
                        (timeSlot.hour, timeSlot.minutes)
                    }
                )
            )
            
            return availableTimeSlotDict
            
        }
        
    }
    
    func printAvailableTimeSlotArray(array:[ReservableTimeSlot]) {
        
        for timeSlot in array {
            
            timeSlot.printf()
            
        }
        
    }
    
    func removeBookedSlot(bookedDate:[Date],
                             dateSelected:Date,
                             availableTimes:[ReservableTimeSlot]) -> [ReservableTimeSlot] {
        
        var availableTimeSlot = availableTimes
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        let hoursFullyBooked = getUnavailableHours(bookedDate: bookedDate)
        
        availableTimeSlot = removeFullyBookedHours(
            availableTimeSlot: availableTimeSlot,
            hoursFullyBooked: hoursFullyBooked)
        
        
        availableTimeSlot = removeMinutesSlotBooked(
            dateSelected: dateSelected,
            bookedDate: bookedDate,
            availableTime: availableTimeSlot)
        
        return availableTimeSlot
        
    }
    
    func getUnavailableHours(bookedDate:[Date]) -> [Int] {
        
        var hoursToRemove = [Int]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        let hoursCount:[Int:Int] = {
            var dict = [Int:Int]()
            
            for date in bookedDate {
                
                let hour = Calendar.current.component(.hour, from: date)
                
                // if the hour is not present in the dictionnary
                if dict[hour] == nil {
                    dict[hour] = 1
                }
                else {
                    dict[hour]! += 1
                }
                
            }
            
            return dict
            
        }()
        
//        We add the hours that has reached the maximum of reservation per hour
        hoursCount.forEach { (key: Int, value: Int) in
            if value >= K.maxReservationPerHour {
                hoursToRemove.append(key)
            }
        }
        
        return hoursToRemove
        
    }
    
    func removeMinutesSlotBooked(dateSelected:Date, bookedDate:[Date], availableTime:[ReservableTimeSlot]) -> [ReservableTimeSlot] {
        
        var availableTimeSlot = availableTime
        
        for date in bookedDate {
            
            let isSameDateAsDatePicked = date.isSameDay(date1: date, date2: dateSelected)
            
            guard isSameDateAsDatePicked else {
                continue
            }
            
            let reservationHour = Calendar.current.component(.hour, from: date)
            let reservationMinute = Calendar.current.component(.minute, from: date).roundToFiveDecimal()
            
            for (index, reservationTimeSlot) in availableTimeSlot.enumerated() {
                
                // If there is a an hour in the bookedDates that is similar to one in the reservationTimeSlot (available)
                if reservationTimeSlot.hour == reservationHour {
                
                    //  If we find two similar minutes slots in both array, we remove it from the available minutes slot
                    
                    if let indexOfMinutesSlotToRemove = reservationTimeSlot.minutes.firstIndex(of: reservationMinute) {
                        
                        availableTimeSlot[index].minutes.remove(at: indexOfMinutesSlotToRemove)
                        
                    }
                
                }
                
            }
            
        }
        
        return availableTimeSlot
        
    }
    
    func removeFullyBookedHours(availableTimeSlot: [ReservableTimeSlot], hoursFullyBooked:[Int]) -> [ReservableTimeSlot] {
        
//        Creating a copy of it to be able to remove element from array
        var availableTime = availableTimeSlot
        
        for (index, timeSlot) in availableTime.enumerated() {
            
            let timeSlotHour = timeSlot.hour
            
            if hoursFullyBooked.contains(timeSlotHour) {
                
                availableTime.remove(at: index)
                
            }
            
        }
        
        return availableTime
        
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
        var isFirstHourReservable:Bool = true
                
//        We set the opening hour in respect to the day that the user picked to reserve
        let openingHour =  WeekDayOfDate % 2 == 0 ? K.evenDayOpeningHour : K.oddDayOpeningHour
        
        let hourSlot:[Int] = {
            
//            We set the first hour reservable by looking at the latest hour a person has entered the queue
            let firstHourReservable:Int
            
//            If there is someone in the queue
            if let lastTimeToReserve = lastTimeToReserve {
                
                let lastTimeMinute = Calendar.current.component(.minute, from: lastTimeToReserve)
                
                print("last minute entered queue : \(lastTimeMinute)")
                
//                if the offset added to the minute of the last person in the queue will pass outside of the hour range ie: the minuteOffset is over 60 minute, we set the first reservable hour to the next hour
                if lastTimeMinute >= (60 - K.queueMinutesOffset) {
                    
                    firstHourReservable = Calendar.current.component(.hour, from: lastTimeToReserve) + 1
                    
                    isFirstHourReservable = false
                    
//                    if it's not the case we set it
                } else {
                    firstHourReservable = Calendar.current.component(.hour, from: lastTimeToReserve)
                }
            }
//            If there is no one in the queue for all the day, we can let the user reserve a time for the opening hour
            else {
                firstHourReservable = openingHour
            }
            
            var hours = [Int]()
            for i in firstHourReservable..<K.closingHour {
                hours.append(i)
            }
            return hours
            
        }()
        
//        The minute of the firstHour to be reservable regarding the queue
        let lastestTimeMinuteComponent:Int
        
//        if there is someone in the queue, and the firstHour is reservable
        if lastTimeToReserve != nil && isFirstHourReservable {
            
//            We set the reservable minute to be the last minute
            lastestTimeMinuteComponent = Calendar.current.component(.minute, from: lastTimeToReserve!).roundToFiveDecimal()
            
        } else {
            lastestTimeMinuteComponent = 0
        }
        
        var reservationsTimeSlot:[ReservableTimeSlot] = [ReservableTimeSlot]()
        
//        We create the firstHoursSlot since it can be either at the opening of the store or the time after the last person has been added to the queue
        let firstHourMinutesSlot = createMinuteSlot(minuteToStart: lastestTimeMinuteComponent.roundToFiveDecimal() + K.queueMinutesOffset)
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
    
    //MARK: - Limit Reservations Methods
    
//    Check if there are more reservations than the maximum allowed, ex 10 for now
    func hasDayReachedMaximumReservations(date:Date, bookedDate:[Date]) -> Bool {
        
        var count = 0
        
        for iterateDay in bookedDate {
            
            if date.isSameDay(date1: date, date2: iterateDay) {
                
                count += 1
                
                if count >= K.maxReservationPerDay {
                    return true
                }
            }
            
        }
        
        return false
        
    }
    
    //    Check if there are more reservations than the maximum allowed
    func hasHourReachedMaximumReservations(date: Date, bookedDate:[Date]) -> Bool {
     
        var count = 0
        
        for iterateDay in bookedDate {
            
            if date.isSameHour(date1: date, date2: iterateDay) {
                
                count += 1
                
                if count >= K.maxReservationPerHour {
                    return true
                }
            }
            
        }
        
        return false
        
    }
    
}

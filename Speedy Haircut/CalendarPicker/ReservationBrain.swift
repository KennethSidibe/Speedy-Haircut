//
//  reservationBrain.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-19.
//

import Foundation

class ReservationBrain: ObservableObject {
    
    //MARK: - Properties
    private var queueDates:[Date]?
    private var reservations:[Date]?
    @Published private var pickedDate:Date?
    @Published private var pickedDateString:String?
    @Published private var pickedTimeString:String?
    @Published private var pickedTime:Date?
    private var dateFormatter:DateFormatter = DateFormatter()
    private var calendar:Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        
        return calendar
    }
    private var availableTimeSlot:[Int: [Int] ]?
    private var unavailableDates: [Date]?
    
    //MARK: - Initializer
    init() {
        self.queueDates = nil
        self.reservations = nil
    }
    
    //MARK: - Get Methods
    func getPickedDate() -> Date {
        return pickedDate ?? Date()
    }
    
    func getPickedDateString() -> String {
        
        let dateString = getOnlyDateFromDate(date: Date())
        
        return self.pickedDateString ?? dateString
    }
    
    func getDateNoTime(date:Date) -> Date {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let dateString = dateFormatter.string(from: date)
        return dateFormatter.date(from: dateString)!
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
        let timeString = dateFormatter.string(from: Date())
        
        return self.pickedTimeString ?? timeString
    }
    
    func getAvailableTimeSlot() -> [Int:[Int]]? {
        return availableTimeSlot
    }
    
    func getHoursSlotFlipBrain() -> [String] {
        
        guard availableTimeSlot != nil else {
            print("available time slot is nil")
            let openingHour:Int = {
                let today = calendar.component(.day, from: Date())
                return today % 2 == 0 ? K.evenDayOpeningHour : K.oddDayOpeningHour
            }()
            return createHourSlot(hourToStart: openingHour)
        }
        
        return availableTimeSlot!.keys.sorted().map { key in
//            Convert the keys to string
            return String(key)
        }
        
    }
    
    func getFirstMinutesSlot() -> [String] {
        
        guard availableTimeSlot != nil else {
            print("available time slot is nil")
            
            return createMinuteSlot(minuteToStart: 0).map { value in
                return String(value)
            }
        }
        
        let firstKey = availableTimeSlot!.keys.sorted().first!
        let firstMinutesSlot:[String] = (availableTimeSlot![firstKey]!.sorted().map({ minutes in
            
            if minutes == 0 {
                return "00"
            } else if minutes == 5 {
                return "05"
            }
            else {
                return String(minutes)
            }
            
        }))
        return firstMinutesSlot
    }
    
    func getUnavailableDates() -> [Date]? {
        return unavailableDates
    }
    
    func getOnlyDateFromDate(date:Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        let dayString:String = {
            if day < 10 {
                return "0"+String(day)
            }
            else {
                return String(day)
            }
        }()
        let month = Calendar.current.component(.month, from: date)
        let monthString:String = {
            if month < 10 {
                return "0"+String(month)
            }
            else {
                return String(month)
            }
        }()
        let year = Calendar.current.component(.year, from: date)
        
        let completeDate:String = dayString+"-"+monthString+"-"+String(year)
        
        return completeDate
    }
    
    func getOnlyTimeFromDate(date:Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        
        let minutesString:String = {
            if minutes < 10 {
                return "0" + String(minutes)
            }
            return String(minutes)
        }()
        
        let completeTime:String = String(hour)+":"+minutesString
        
        return completeTime
    }
    
    func getFirstReservableDate() -> Date {
        
        self.dateFormatter.dateFormat = "dd-MM-yyyy"
        
        guard unavailableDates != nil else {
            print("Cannot return first reservable date, unavailable dates is nil")
            
            setAvailableTimSlotForDate(date: Date())
            self.pickedDateString = getOnlyDateFromDate(date: Date())
            
            self.pickedDate = Date()
            
            return Date()
        }
        
        let today = Date()
        let nextYear = Calendar.current.date(byAdding: .year,
                                             value: 1,
                                             to: today)!
        
        let dayDurationInSeconds: TimeInterval = 60*60*24
        
        for date in stride(from: today, to: nextYear, by: dayDurationInSeconds) {
            
            let dateNoTime:Date = getDateNoTime(date: date)
            
            if !(unavailableDates!.contains(dateNoTime)) {
                
                setAvailableTimSlotForDate(date: dateNoTime)
                
                self.pickedDateString = getOnlyDateFromDate(date: dateNoTime)
                self.pickedDate = dateNoTime
                
                return dateNoTime
            }
        }
        setAvailableTimSlotForDate(date: Date())
        self.pickedDateString = getOnlyDateFromDate(date: Date())
        self.pickedDate = Date()
        return Date()
    }
    
    func getFirstReservableTimeSlot() -> Date {
        
        dateFormatter.dateFormat = "HH:mm"
        
        guard availableTimeSlot != nil else {
            print("Cannot return first reservable time slot, available time slot is nil")
            
            let time = String(K.evenDayOpeningHour) + ":00"
            
            
            return dateFormatter.date(from: time)!
        }
        
        let hour:Int = {
            let keys = availableTimeSlot!.keys.sorted()
            return keys.first!
        }()
        
        let now:Date = {
            dateFormatter.dateFormat = "HH:mm"
            
            let dateString = dateFormatter.string(from: Date())
            let dateNoTime = dateFormatter.date(from: dateString)!
            
            return dateNoTime
        }()
        
        let minutes:String = {
            let minuteTemp = availableTimeSlot![hour]!.first!
            
            if minuteTemp == 0 {
                return "00"
            }
            else if minuteTemp == 5 {
                return "05"
            }
            
            return String(minuteTemp)
        }()
        
        
        let timeString = String(hour) + ":" + minutes
        
        let firstReservableTimeSlot = dateFormatter.date(from: timeString) ?? now
        
        self.pickedTimeString = timeString
        
        return firstReservableTimeSlot
        
    }
    
    func getBookingDate(date pickedDate:Date, time pickedTime:Date) -> Date {
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let dateString = getOnlyDateFromDate(date: pickedDate)
        let timeString = getOnlyTimeFromDate(date: pickedTime)
        
        let reservDateString = dateString + " " + timeString
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        let reservDate = dateFormatter.date(from: reservDateString)
        
        return reservDate!
        
    }
    
    func generateRandomDates() -> [Date] {
        var dates:[Date] = [Date]()
        let randomNumber = Int.random(in: 0...10)
        
        for _ in 0...randomNumber {
            
            let date = generateRandomDay()
            
            dates.append(date)
        }
        
        return dates
    }
    
    func generateRandomQueueList() -> [Date] {
        
        let firstQueueDate = generateRandomDay(withTime: true)
        let randomHourAddition = Int.random(in: 0...3)
        let randomMinuteAddition = Int.random(in: 0...40)
        
        let randomHourAddition2 = Int.random(in: 0...3)
        let randomMinuteAddition2 = Int.random(in: 0...40)
        
        var secondQueueDate = Calendar.current.date(byAdding: .hour, value: randomHourAddition, to: firstQueueDate)!
        secondQueueDate = Calendar.current.date(byAdding: .minute, value: randomMinuteAddition, to: firstQueueDate)!
        
        var thirdQueueDateAddition = Calendar.current.date(byAdding: .hour, value: randomHourAddition2, to: secondQueueDate)!
        thirdQueueDateAddition = Calendar.current.date(byAdding: .minute, value: randomMinuteAddition2, to: secondQueueDate)!
        
        let queueDates = [firstQueueDate, secondQueueDate, thirdQueueDateAddition]
        
        return queueDates
    }
    
    func generateRandomDay(withTime:Bool = false) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if withTime {
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        }
        
        let randomDay = Int.random(in: 1...31)
        let randomMonth = Int.random(in: 1...12)
        let randomYear = Int.random(in: 1800...2100)
        
        var dateString = String(randomDay)+"-"+String(randomMonth)+"-"+String(randomYear)
        if withTime {
            let randomHour = Int.random(in: 6...19)
            let randomMinute = Int.random(in: 5...50)
            
            let timeString = String(randomHour)+":"+String(randomMinute)
            
            dateString = String(randomDay)+"-"+String(randomMonth)+"-"+String(randomYear) + " " + timeString
        }
        
        let date = dateFormatter.date(from: dateString)
        
        return date ?? Date()
        
    }
    
    //MARK: - Set Methods
    func setBrain(reservations:[Date], queueDates:[Date], datePicked:Date?) {
        self.reservations = reservations
        self.queueDates = queueDates
        self.setUnavailableDates()
        let availableTimeSlot = getTimeReservable(
            dateSelected: datePicked ?? Date(),
            queueTimeList: queueDates,
            reservationsDate: reservations)
        
        self.availableTimeSlot = availableTimeSlot
    }
    
    func setAvailableTimSlotForDate(date:Date) {
        availableTimeSlot = getTimeReservable(dateSelected: date,
                                              queueTimeList: queueDates,
                                              reservationsDate: reservations)
    }
    
    func setPickedDate(pickedDate:Date) {
        self.pickedDate = pickedDate
    }
    
    func setPickedTime(pickedTime:Date) {
        self.pickedTime = pickedTime
    }
    
    func setFirstAvailableTimeSlot() {
        self.pickedTime = pickedTime
    }
    
    func setUnavailableDates()  {
        
        dateFormatter.dateFormat = "dd-MM-yyy"
        
        if let reservations = reservations {
            
            var unavailableDays = [Date]()
            
            for date in reservations {
                
                let dateNoTime = getDateNoTime(date: date)
                
                let isDateNotReservable = hasDayReachedMaximumReservations(date: date,
                                                                           bookedDate: reservations, unavailableDays: unavailableDays)
                
                if isDateNotReservable {
                    
                    if unavailableDays.contains(dateNoTime) {
                        continue
                    }
                    else {
                        unavailableDays.append(dateNoTime)
                    }
                }
            }
            
            unavailableDates = unavailableDays
        }
    }
    
    func setAvailableTimeSlot() {
        if pickedDate != nil &&
            queueDates !=  nil &&
            reservations != nil {
            
            let availableTimeSlot = getTimeReservable(dateSelected: pickedDate!, queueTimeList: queueDates!, reservationsDate: reservations!)
            
            self.availableTimeSlot = availableTimeSlot
        }
    }
    
    func setQueueDates(queueDates:[Date]) {
        self.queueDates = queueDates
    }
    
    func setReservations(reservations:[Date]) {
        self.reservations = reservations
    }
    
    //MARK: - Calculate Reservation Time Methods
    func getTimeReservable(dateSelected: Date,
                           queueTimeList:[Date]?,
                           reservationsDate:[Date]?) -> [Int : [Int]] {
        
//        We get the latest person in the queue
        var latestTime = queueTimeList?.max()
        
//        If there is someone in the queue, we verify that the time he has entered the queue is the same day as the date selected. If not we invalidate the latestTime variable
        if latestTime != nil {
            
            if !(dateSelected.isSameDay(date1: latestTime!, date2: dateSelected)) {
                latestTime = nil
            }
            
        }
        
//        A list that contains all the hours available to book if there are no reservations
        var availableTimeSlot:[ReservableTimeSlot] = createReservationTimeSlot(lastTimeToReserve: latestTime, dateToReserve: dateSelected)
        
        guard reservationsDate != nil else {
            
            let availableTimeSlotDict = Dictionary(
                uniqueKeysWithValues: availableTimeSlot.map(
                    { timeSlot in
                        (timeSlot.hour, timeSlot.minutes)
                    }
                )
            )
            
            return availableTimeSlotDict
            
        }
        
//        If there is 0 reservation for the date
        if !(isThereReservationOnDate(date: dateSelected, reservationsDate: reservationsDate!)) {
            
//            That means all the normal available time slot are open, we return that
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
            
//            We remove the bookedSlot, from the available time slot
            availableTimeSlot = removeBookedSlot(bookedDate: reservationsDate!,
                                                 dateSelected: dateSelected,
                                                 availableTimes: availableTimeSlot)
            
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
    
    private func printAvailableTimeSlotArray(array:[ReservableTimeSlot]) {
        
        for timeSlot in array {
            
            timeSlot.printf()
            
        }
        
    }
    
    private func removeBookedSlot(bookedDate:[Date],
                             dateSelected:Date,
                             availableTimes:[ReservableTimeSlot]) -> [ReservableTimeSlot] {
        
//        A copy of the available time slot to modify the array
        var availableTimeSlot = availableTimes
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
//        we get all the hours that are not reservable
        let hoursFullyBooked = getUnavailableHours(pickedDate: dateSelected, bookedDate: bookedDate)
        
//        We remove those hours from the available time slot
        availableTimeSlot = removeFullyBookedHours(
            availableTimeSlot: availableTimeSlot,
            hoursFullyBooked: hoursFullyBooked)
        
//        We remove the available minutes slot from the hour remaining
        availableTimeSlot = removeMinutesSlotBooked(
            dateSelected: dateSelected,
            bookedDate: bookedDate,
            availableTime: availableTimeSlot)
        
        return availableTimeSlot
        
    }
    
    private func getUnavailableHours(pickedDate:Date, bookedDate:[Date]) -> [Int] {
        
        var hoursToRemove = [Int]()
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
//        This variable contains the hours that gets repeated for the date selected in all the reservations
        let hoursCount:[Int:Int] = {
            var dict = [Int:Int]()
            
            for date in bookedDate {
                
//                We check if it is the same day as the date selected otherwise we don't count it
                if date.isSameDay(date1: date, date2: pickedDate) {
                    
                    let hour = Calendar.current.component(.hour, from: date)
                    
                    // if the hour is not present in the dictionnary
                    if dict[hour] == nil {
                        dict[hour] = 1
                    }
                    else {
                        dict[hour]! += 1
                    }
                }
                
            }
            
            return dict
        }()
        
//        We remove the hours that has reached the maximum of reservation per hour
        hoursCount.forEach { (key: Int, value: Int) in
            if value >= K.maxReservationPerHour {
                hoursToRemove.append(key)
            }
        }
        
//        We return the hours to remove
        return hoursToRemove
        
    }
    
    private func removeMinutesSlotBooked(dateSelected:Date,
                                 bookedDate:[Date],
                                 availableTime:[ReservableTimeSlot]) -> [ReservableTimeSlot] {
        
        var availableTimeSlot = availableTime
        
        
        for currentDate in bookedDate {
            
            let isSameDateAsDatePicked = currentDate.isSameDay(date1: currentDate, date2: dateSelected)
            
//            We chekc if the current date is the same as the date selected, if it is not we do not check this date and just continue
            guard isSameDateAsDatePicked else {
                continue
            }
            
            let reservationHour = Calendar.current.component(.hour, from: currentDate)
            let reservationMinute = Calendar.current.component(.minute, from: currentDate).roundToFiveDecimal()
            
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
    
    private func removeFullyBookedHours(availableTimeSlot: [ReservableTimeSlot],
                                hoursFullyBooked:[Int]) -> [ReservableTimeSlot] {
        
//        Creating a copy of it to be able to remove element from array
        var availableTime = availableTimeSlot
        
//        We iterate over the available time slot, if we find a same occurrence in the fullyBooked hours array we remove it
        for (index, availableTimeSlot) in availableTime.enumerated() {
            
            let availableTimeSlotHour = availableTimeSlot.hour
            
            if hoursFullyBooked.contains(availableTimeSlotHour) {
                
                availableTime.remove(at: index)
                
            }
            
        }
        
        return availableTime
        
    }
    
//    Check if a reservation already exist for the date provided
    private func isThereReservationOnDate(date: Date, reservationsDate:[Date]) -> Bool {
        
        for iterateDay in reservationsDate {
            
            if date.isSameDay(date1: date, date2: iterateDay) {
                
                return true
                
            }
            
        }
        
        return false
    }
    
    func createReservationTimeSlot(lastTimeToReserve:Date?,
                                   dateToReserve:Date) -> [ReservableTimeSlot] {
        
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
        
//        if there is 0 person in the queue, we set the minutes offset to 0 otherwise we set our constant
        let minuteOffset = lastTimeToReserve == nil ? 0 : K.queueMinutesOffset
        
//        We create the firstHoursSlot since it can be either at the opening of the store or the time after the last person has been added to the queue
        let firstHourMinutesSlot = createMinuteSlot(minuteToStart: lastestTimeMinuteComponent.roundToFiveDecimal() + minuteOffset)
        
        let firstReservationTimeSlot = ReservableTimeSlot(hour: hourSlot[0],
                                                          minutes: firstHourMinutesSlot)
        
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
    private func createMinuteSlot(minuteToStart:Int) -> [Int] {
        
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
    
    /// Thisn function create an array representing the hours slot reservable, eg : [10,11,12,...]
    /// - Parameter hourToStart: The hours to start counting
    /// - Returns: An array of all the hours slot reservable respect to the closing hour of the store
    private func createHourSlot(hourToStart:Int) -> [String] {
        let increment = 1
        var array = [Int]()
        array.append(hourToStart)
        var lastElement = array[0]
        for _ in 0..<K.closingHour {
            
            let numberToAdd = lastElement + increment
            
            if numberToAdd >= 60 {
                break
            }
            
            array.append(numberToAdd)
            lastElement = numberToAdd
            
        }
        
        return array.map { value in
            return String(value)
        }
    }
    
    //MARK: - Limit Reservations Methods
    
//    Check if there are more reservations than the maximum allowed, ex 10 for now
    private func hasDayReachedMaximumReservations(date:Date, bookedDate:[Date], unavailableDays:[Date]?) -> Bool {
        
        var count = 0
        
//        We iterate over all the reservations and if there is more than 10 occurences of that particular date in the booking date we add it to our unavailable days list
        for iterateDay in bookedDate {
            
//            If our unavailableDays is not nil we will check if the date we are checking is not already present, if yes we return true
            if unavailableDays != nil {
                        
                let dateNoTime:Date = getDateNoTime(date: date)
                
                if unavailableDays!.contains(dateNoTime) {
                    return true
                }
                
            }
            
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
    private func hasHourReachedMaximumReservations(date: Date, bookedDate:[Date]) -> Bool {

        var count = 0
        
//        We iterate over all the booking date, if the date to check has same day and hour as one date in the reservation we increase our count. If the count > maximumPerHour we return true
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

//
//  Extensions.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-19.
//

import Foundation

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
    
    func isSameHour(date1:Date, date2:Date) -> Bool {
        
        let diff = Calendar.current.dateComponents([.hour], from: date1, to: date2)
            if diff.hour == 0 {
                return true
            } else {
                return false
            }
        
    }
    
}


//MARK: - Int Extension
extension Int {
    
    /// Will return the closest five multiplicant of a number, eg: 7 -> 10, 9 -> 10, 2 -> 5, 22 -> 25
    /// - Returns: closest five multiplicant of a number
    func roundToFiveDecimal() -> Int {
        
        if self % 5 == 0 {
            return self
        }
        
        let numberToAdd = 5 - (self % 5)
        
        return self + numberToAdd
        
    }
    
}

//
//  Reservation.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-06.
//

import Foundation

class Reservation:Identifiable, ObservableObject, Comparable, Equatable {
    
    var id:String?
    var clientName:String?
    var date:Date?
    
    //MARK: - Comparable delegate methods
    
    static func < (lhs:Reservation, rhs:Reservation) -> Bool {
        
        guard lhs.date != nil, rhs.date != nil else {
            
            print("Line number is nil")
            return false
            
        }
        
        return lhs.date! < rhs.date!
        
    }
    
    static func == (lhs: Reservation, rhs: Reservation) -> Bool {
        
        guard lhs.date != nil, rhs.date != nil else {
            
            print("Line number is nil")
            return false
        }
        
        return lhs.date! == rhs.date!
        
    }
    
    static func > (lhs: Reservation, rhs: Reservation) -> Bool {
        
        guard lhs.date != nil, rhs.date != nil else {
            
            print("Line number is nil")
            return false
        }
        
        return lhs.date! > rhs.date!
        
    }
    
}

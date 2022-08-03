//
//  reservableTimeSlot.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-17.
//

import Foundation

struct ReservableTimeSlot:Equatable {
    
    let hour:Int
    var minutes:[Int]
 
    
    func printf() {
        
        print("Hours bookable : \(hour)")
        print("Minutes Bookable : \(minutes)")
        
    }
    
}

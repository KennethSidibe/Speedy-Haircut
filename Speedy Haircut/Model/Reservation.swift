//
//  Reservation.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-06.
//

import Foundation

class Reservation:Identifiable, ObservableObject {
    
    var id:String?
    var clientName:String?
    var date:Date?
    
}

//
//  User.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-29.
//

import Foundation



class User:Identifiable, ObservableObject {
    var id:String?
    var firstName:String?
    var lastName:String?
    var photo:String?
    var lineNumber:Int?
}

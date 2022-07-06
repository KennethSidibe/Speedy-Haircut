//
//  User.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-29.
//

import Foundation



class User:Identifiable, ObservableObject, Comparable {
    
    
    var id:String?
    var firstName:String?
    var lastName:String?
    var photo:String?
    var lineNumber:Int?
    
    //MARK: - Comparable delegate methods
    
    static func < (lhs:User, rhs:User) -> Bool {
        
        guard lhs.lineNumber != nil, rhs.lineNumber != nil else {
            
            print("Line number is nil")
            return false
            
        }
        
        return lhs.lineNumber! < rhs.lineNumber!
        
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        
        guard lhs.lineNumber != nil, rhs.lineNumber != nil else {
            
            print("Line number is nil")
            return false
        }
        
        return lhs.lineNumber! == rhs.lineNumber!
        
    }
    
    static func > (lhs: User, rhs: User) -> Bool {
        
        guard lhs.lineNumber != nil, rhs.lineNumber != nil else {
            
            print("Line number is nil")
            return false
        }
        
        return lhs.lineNumber! > rhs.lineNumber!
        
    }
    
}

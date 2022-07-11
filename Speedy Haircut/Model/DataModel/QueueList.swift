//
//  QueueList.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import Foundation

struct QueueUser:Comparable, Identifiable {
    let id:String?
    let name: String?
    let lineNumber:Int?
    let timeEnteredQueue:Date?
    
    //MARK: - Comparable delegate methods
    
    static func < (lhs:QueueUser, rhs:QueueUser) -> Bool {
        
        guard lhs.timeEnteredQueue != nil, rhs.timeEnteredQueue != nil else {
            
            print("Line number is nil")
            return false
            
        }
        
        return lhs.timeEnteredQueue! < rhs.timeEnteredQueue!
        
    }
    
    static func == (lhs: QueueUser, rhs: QueueUser) -> Bool {
        
        guard lhs.timeEnteredQueue != nil, rhs.timeEnteredQueue != nil else {
            
            print("Line number is nil")
            return false
        }
        
        return lhs.timeEnteredQueue! == rhs.timeEnteredQueue!
        
    }
    
    static func > (lhs: QueueUser, rhs: QueueUser) -> Bool {
        
        guard lhs.timeEnteredQueue != nil, rhs.timeEnteredQueue != nil else {
            
            print("Line number is nil")
            return false
        }
        
        return lhs.timeEnteredQueue! > rhs.timeEnteredQueue!
        
    }
    
}

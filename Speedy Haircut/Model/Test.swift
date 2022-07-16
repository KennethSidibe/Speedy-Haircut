//
//  test.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-05.
//

import Foundation

class Test {
    
    func testUserArray(file:Bool = false) {
        
        let sort = QuickSort()
        
        let randomSize = Int.random(in: 0...1000)
        
        var userList = createRandomUsers(size: randomSize)
        
        let unsortedList = userList
        
        sort.sortQuick(array: &userList)
        
        print("CHECK SORT: \(checkSort(elementArray: userList))")
        
        if file {
            
            writeToTxt(list: unsortedList, filename: "unsorted.txt")
            
            writeToTxt(list: userList, filename: "sorted.txt")
            
        }
        
    }
    
    func testReservationArray(file:Bool = false) {
        
        let sort = QuickSort()
        
        let randomSize = Int.random(in: 0...1000)
        
        var reservationList = createRandomReservations(size: randomSize)
        
        let unsortedList = reservationList
        
        sort.sortQuick(array: &reservationList)
        
        print("CHECK SORT: \(checkSort(elementArray: reservationList))")
        
        if file {
            
            writeToTxt(list: unsortedList, filename: "unsorted.txt")
            
            writeToTxt(list: reservationList, filename: "sorted.txt")
            
        }
        
    }
    
    func checkSort<Element:Comparable>(elementArray: Array<Element>) -> Bool {
        
        let max = elementArray.count - 2
        
        for i in 0...max {
            
            if(elementArray[i+1] < elementArray[i]) {
                
                return false
                
            }
        }
        
        return true
        
    }
    
    func writeToTxt(list:[Any], filename:String = "output.txt") {
        
        let strList:Any
        
        switch list[0] {
            
        case is Reservation:
            strList = self.reservationToString(array: list as! Array<Reservation>)
            
        case is User:
            strList = self.userToString(array: list as! Array<User>)
            
        default:
            print("This function can only write list of type `User` and `Reservation` for now ")
            return
            
        }

        let strText = (strList as! [String]).joined(separator: ",")
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        
        
        let filename = getDocumentsDirectory().appendingPathComponent(filename)
        print(filename.path)

        do {
            try strText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
    }
    
    func userToString(array:Array<User>) -> [String] {
        
        var list = [String]()
        
        for i in 0...array.count - 1 {
            
            list.append(String(array[i].lineNumber!))
            
        }
        
        return list
    }
    
    func reservationToString(array:Array<Reservation>) -> [String] {
        
        var list = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        for i in 0...array.count - 1 {
            
            let date = formatter.string(from: array[i].date!)
            
            list.append(date)
            
        }
        
        return list
    }
    
    func createRandomUsers(size:Int) -> Array<User> {
        
        var userList = [User]()
        
        
        for _ in 0...size {
            
            let newUser = User()
            newUser.lineNumber = Int.random(in: 0...1000)
            userList.append(newUser)
            
        }
        
        
        
        return userList
        
    }
    
    func createRandomReservations(size:Int) -> Array<Reservation> {
        
        var randomReservationList = [Reservation]()
        
        for _ in 0...size {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let longPastedDate = formatter.date(from: "1961/06/09")

            let range:Range<Date> = longPastedDate!..<Date()
            
            
            let reservationDate = Date.random(in: range)
            
            let newReservation = Reservation(date: reservationDate)
            
            randomReservationList.append(newReservation)
            
        }
        
        return randomReservationList
        
    }
    
    func printUserArr(userArray:Array<User>) {
        
        for i in 0...userArray.count - 1 {
            
            print("\(userArray[i].firstName!) : \(userArray[i].lineNumber!),", terminator: "")
            
        }
        print()
        
    }
    
}

extension Date {
    
    static func random(in range: Range<Date>) -> Date {
        Date(
            timeIntervalSinceNow: .random(
                in: range.lowerBound.timeIntervalSinceNow...range.upperBound.timeIntervalSinceNow
            )
        )
    }
    
}

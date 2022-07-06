//
//  test.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-05.
//

import Foundation


class Test {
    
    func testArray(file:Bool = false) {
        
        let sort = QuickSort()
        
        let randomSize = Int.random(in: 0...1000)
        
        var userList = createRandomUsers(size: randomSize)
        
        let unsortedList = userList
        
        sort.sortQuick(array: &userList)
        
        print("CHECK SORT: \(checkSort(userArray: userList))")
        
        if file {
            
            writeToTxt(userList: unsortedList, filename: "unsorted.txt")
            
            sort.sortQuick(array: &userList)
            
            writeToTxt(userList: userList, filename: "sorted.txt")
            
        }
        
    }
    
    func checkSort(userArray: Array<User>) -> Bool {
        
        let max = userArray.count - 2
        
        for i in 0...max {
            
            if(userArray[i+1] < userArray[i]) {
                
                return false
                
            }
            
            
        }
        
        return true
        
    }
    
    func writeToTxt(userList:[User], filename:String = "output.txt") {
        
        let strList = self.userToString(array: userList)

        let strText = strList.joined(separator: ",")
        
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
    
    func createRandomUsers(size:Int) -> Array<User> {
        
        var userList = [User]()
        
        
        for _ in 0...size {
            
            let newUser = User()
            newUser.lineNumber = Int.random(in: 0...1000)
            userList.append(newUser)
            
        }
        
        
        
        return userList
        
    }
    
    func printUserArr(userArray:Array<User>) {
        
        for i in 0...userArray.count - 1 {
            
            print("\(userArray[i].firstName!) : \(userArray[i].lineNumber!),", terminator: "")
            
        }
        print()
        
    }
    
    
}

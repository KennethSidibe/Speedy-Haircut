
import Foundation

struct Day {
    
    let date:Date
    let number:String
    let isSelected:Bool
    let isWithinDisplayedMonth:Bool
    let isDayAvailable:Bool
    let isDayReservable:Bool
    
    
    func printDay() {
        
        print("Day Number is : \(number)")
        print("date is : \(date)")
        print("Is Day Available : \(isDayAvailable)")
        
        print()
        
    }
    
}

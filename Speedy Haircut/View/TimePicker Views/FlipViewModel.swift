//
//  FlipViewModel.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-07
//

import SwiftUI

class FlipViewModel: ObservableObject, Identifiable {
    
    init(timeSlot:[String]) {
        print("timeslot at init : \(timeSlot)")
        self.timeSlot = timeSlot
        self.selector = 0
        self.oldValue = String(timeSlot[selector])
        self.newValue = String(timeSlot[selector+1])
        
        print()
    }
    
    var timeSlot:[String]
    
    @Published var selector:Int

    @Published var newValue: String?
    @Published var oldValue: String?

    @Published var animateTop: Bool = false
    @Published var animateBottom: Bool = false

    func updateTexts(old: String?, new: String?) {
        print("timeslot at update : \(timeSlot)")
        
        guard old != new else { return }
        oldValue = old
        animateTop = false
        animateBottom = false

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            self?.newValue = new
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
    }
    
    func nextTimeSlot() {
        
        print("timeslot at next : \(timeSlot)")
        
        oldValue = timeSlot[selector]
        animateTop = false
        animateBottom = false
        

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            
            selector += 1
            
            if selector == timeSlot.count {
                selector = 0
            }
            self?.newValue = timeSlot[selector]
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
    }
    
    func previousTimeSlot() {
        
        oldValue = timeSlot[selector]
        animateTop = false
        animateBottom = false
        
        print("timeslot at previous : \(timeSlot)")

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            
            selector -= 1
            
            if selector < 0 {
                selector = timeSlot.count - 1
            }
            self?.newValue = timeSlot[selector]
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
    }
    
    func resetSlot(newTimeSlot:[String]) {
        
        oldValue = timeSlot[selector]
        animateTop = false
        animateBottom = false

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            
            selector = 0
            
            self?.timeSlot = newTimeSlot
            
            self?.newValue = timeSlot[selector]
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
        
    }
    
    func getCurrentTime() -> Int {
        
        print("timeslot flip view model\(timeSlot)")
        
        if let time = Int(timeSlot[selector]) {
            return time
        } else {
            return 0
        }
        
    }

}

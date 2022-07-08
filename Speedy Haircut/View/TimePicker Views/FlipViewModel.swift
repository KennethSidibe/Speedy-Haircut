//
//  FlipViewModel.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-07
//

import SwiftUI

class FlipViewModel: ObservableObject, Identifiable {
    
    init(timeSlot:[String]) {
        self.timeSlot = timeSlot
        self.selector = 0
        self.oldValue = String(timeSlot[selector])
        self.newValue = String(timeSlot[selector+1])
    }
    
    var timeSlot:[String]
    
    @Published var selector:Int

    @Published var newValue: String?
    @Published var oldValue: String?

    @Published var animateTop: Bool = false
    @Published var animateBottom: Bool = false

    func updateTexts(old: String?, new: String?) {
        
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
        
        oldValue = String(timeSlot[selector])
        animateTop = false
        animateBottom = false

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            
            selector += 1
            
            if selector == timeSlot.count {
                selector = 0
            }
            self?.newValue = String(timeSlot[selector])
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
    }
    
    func previousTimeSlot() {
        
        oldValue = String(timeSlot[selector])
        animateTop = false
        animateBottom = false

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            
            selector -= 1
            
            if selector < 0 {
                selector = timeSlot.count - 1
            }
            self?.newValue = String(timeSlot[selector])
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
    }
    
    func resetSlot() {
        
        oldValue = String(timeSlot[selector])
        animateTop = false
        animateBottom = false

        withAnimation(Animation.easeIn(duration: 0.2)) { [weak self] in
            
            selector = 0
            
            self?.newValue = String(timeSlot[selector])
            self?.animateTop = true
        }

        withAnimation(Animation.easeOut(duration: 0.2).delay(0.2)) { [weak self] in
            self?.animateBottom = true
        }
        
    }

}

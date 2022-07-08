//
//  TimePickerView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-07.
//

import SwiftUI

struct TimePickerView: View {
    
    init(hourBrain:FlipViewModel, minuteBrain:FlipViewModel) {
        self.hoursFlipBrain = hourBrain
        self.minutesFlipBrain = minuteBrain
    }
    
    let hoursFlipBrain:FlipViewModel
    let minutesFlipBrain:FlipViewModel
    
    var body: some View {
        
        HStack {
            
            // hour Flip
            VStack(spacing:10) {
                
                Button(action: {
                    hoursFlipBrain.previousTimeSlot()
                    minutesFlipBrain.resetSlot()
                }, label: {
                    Image(systemName: "arrowtriangle.up.fill")
                })
                
                FlipView(viewModel: hoursFlipBrain)
                
                Button(action: {
                    
                    hoursFlipBrain.nextTimeSlot()
                    minutesFlipBrain.resetSlot()
                    
                }, label: {
                    Image(systemName: "arrowtriangle.down.fill")
                })
                
            }
            
            Text(":")
                .font(.largeTitle)
            
            // Minutes flip
            VStack(spacing:10) {
                
                Button(action: {
                    minutesFlipBrain.previousTimeSlot()
                }, label: {
                    Image(systemName: "arrowtriangle.up.fill")
                })
                
                FlipView(viewModel: minutesFlipBrain)
                
                Button(action: {
                    minutesFlipBrain.nextTimeSlot()
                }, label: {
                    Image(systemName: "arrowtriangle.down.fill")
                })
                
            }
            
        }
        
    }
}

struct TimePickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let minuteSlot = ["15", "20", "25", "35", "50"]
        let hourSlot = ["3", "4", "9", "12"]
        let hourBrain = FlipViewModel(timeSlot: hourSlot)
        let minuteBrain = FlipViewModel(timeSlot: minuteSlot)
        
        TimePickerView(hourBrain: hourBrain, minuteBrain: minuteBrain)
    }
    
}

//
//  TimePickerView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-07.
//

import SwiftUI

struct TimePickerView: View {
    
    @Binding var timePicked:Date?
    @Binding var isPresented:Bool
    let hoursFlipBrain:FlipViewModel
    let minutesFlipBrain:FlipViewModel
    let availableTimeSlot:[Int: [Int] ]
    
    init(hourBrain: FlipViewModel,
         minuteBrain: FlipViewModel,
         timePicked: Binding<Date?>,
         isPresented: Binding<Bool>,
         availableTimeSlot: [Int: [Int]]
    ) {
        self.hoursFlipBrain = hourBrain
        self.minutesFlipBrain = minuteBrain
        self._timePicked = timePicked
        self._isPresented = isPresented
        self.availableTimeSlot = availableTimeSlot
        self.minutesFlipBrain.selector = 0
        self.hoursFlipBrain.selector = 0
    }
    
    var body: some View {
        
        VStack {
            HStack {
                
                // hour Flip
                VStack(spacing:10) {
                    
//                    Up Button
                    Button(action: {
                        hoursFlipBrain.previousTimeSlot()
                        
                        let pickedHour = hoursFlipBrain.getCurrentTime()
                        let newMinutesSlot = availableTimeSlot[pickedHour]
                        
                        let newMinutesSlotString = newMinutesSlot?.map({ value -> String in
                            if value == 0 {
                                return "00"
                            } else {
                                return String(value)
                            }
                        })
                        
                        
                        minutesFlipBrain.resetSlot(newTimeSlot: newMinutesSlotString!)
                    }, label: {
                        Image(systemName: "arrowtriangle.up.fill")
                    })
                    
                    FlipView(viewModel: hoursFlipBrain)
                    
//                    Down Button
                    Button(action: {
                        
                        hoursFlipBrain.nextTimeSlot()
                        
                        let pickedHour = hoursFlipBrain.getCurrentTime()
                        let newMinutesSlot = availableTimeSlot[pickedHour]
                        
                        let newMinutesSlotString = newMinutesSlot?.map({ value -> String in
                            if value == 0 {
                                return "00"
                            } else {
                                return String(value)
                            }
                        })
                        
                        minutesFlipBrain.resetSlot(newTimeSlot: newMinutesSlotString!)
                        
                    }, label: {
                        Image(systemName: "arrowtriangle.down.fill")
                    })
                    
                }
                
                Text(":")
                    .font(.largeTitle)
                
                // Minutes flip
                VStack(spacing:10) {
                    
//                    Up Button
                    Button(action: {
                        minutesFlipBrain.previousTimeSlot()
                    }, label: {
                        Image(systemName: "arrowtriangle.up.fill")
                    })
                    
                    FlipView(viewModel: minutesFlipBrain)
                    
//                    Down button
                    Button(action: {
                        minutesFlipBrain.nextTimeSlot()
                    }, label: {
                        Image(systemName: "arrowtriangle.down.fill")
                    })
                    
                }
                
            }
            
            Button(action: {
                
                let hour = hoursFlipBrain.getCurrentTime()
                let minutes = hoursFlipBrain.getCurrentTime()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                let timeString = String(hour) + ":" + String(minutes)
                
                timePicked = dateFormatter.date(from: timeString)
                
                self.isPresented = false
                
                
                
            }, label: {
                Text("Set Time")
                    .padding()
                    .frame(width: 150, height: 50, alignment: .center)
                    .background(Color.black)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                
            })
            .padding()
        }
        
    }
}

struct TimePickerView_Previews: PreviewProvider {
    
    @State static var timePicked:Date?
    @State static var isPresented:Bool = true
    
    static var previews: some View {
        
        let minuteSlot = ["15", "20", "25", "35", "50"]
        let hourSlot = ["3", "4", "9", "12"]
        let availableTimeSlot:[ Int: [Int] ] = {
            
            var dict = [Int: [Int]]()
                
                for (index, hour) in hourSlot.enumerated() {
                    
                    let key = Int(hourSlot[index])
                    
                    dict[key!] = minuteSlot.map({ element in
                        Int(element)!
                    })
                    
                }
                
            return dict
                
        }()
        
        let hourBrain = FlipViewModel(timeSlot: hourSlot)
        let minuteBrain = FlipViewModel(timeSlot: minuteSlot)
        
        TimePickerView(hourBrain: hourBrain, minuteBrain: minuteBrain, timePicked: $timePicked, isPresented: $isPresented, availableTimeSlot: availableTimeSlot)
    }
    
}

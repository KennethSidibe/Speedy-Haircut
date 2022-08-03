//
//  TimePickerView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-07.
//

import SwiftUI

struct TimePickerView: View {
    
    @Binding private var timePicked:Date?
    @Binding private var timePickedString:String?
    @Binding private var timePickerFlipBrains:TimePickerFlipBrains?
    private let hoursFlipBrain:FlipViewModel
    private let minutesFlipBrain:FlipViewModel
    private let availableTimeSlot:[Int: [Int] ]
    
    init(hourBrain: FlipViewModel,
         minuteBrain: FlipViewModel,
         timePicked: Binding<Date?>,
         timePickedString: Binding<String?>,
         timePickerFlipBrains: Binding<TimePickerFlipBrains?>,
         availableTimeSlot: [Int: [Int]]
    ) {
        self.hoursFlipBrain = hourBrain
        self.minutesFlipBrain = minuteBrain
        self._timePicked = timePicked
        self._timePickedString = timePickedString
        self._timePickerFlipBrains = timePickerFlipBrains
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
                let minutes = minutesFlipBrain.getCurrentTime()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let minutesString:String = {
                    if minutes == 0 {
                        return "00"
                    }
                    return String(minutes)
                }()
                
                let timeString = String(hour) + ":" + minutesString
                
                timePicked = dateFormatter.date(from: timeString)
                timePickedString = timeString
                
                self.timePickerFlipBrains = nil
                
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

//struct TimePickerView_Previews: PreviewProvider {
//
//    @State static var timePicked:Date?
//    @State static var isPresented:Bool = true
//    @State var timePickerFlipBrainsPreview:TimePickerFlipBrains?
//
//    static var previews: some View {
//
//        let minuteSlot = ["15", "20", "25", "35", "50"]
//        let hourSlot = ["3", "4", "9", "12"]
//        let availableTimeSlot:[ Int: [Int] ] = {
//
//            var dict = [Int: [Int]]()
//
//                for (index, hour) in hourSlot.enumerated() {
//
//                    let key = Int(hourSlot[index])
//
//                    dict[key!] = minuteSlot.map({ element in
//                        Int(element)!
//                    })
//
//                }
//
//            return dict
//
//        }()
//
//        let hourBrain = FlipViewModel(timeSlot: hourSlot)
//        let minuteBrain = FlipViewModel(timeSlot: minuteSlot)
//        self.timePickerFlipBrainsPreview = TimePickerFlipBrains(
//            hoursFlipBrains: hourBrain,
//            minutesFlipBrains: minuteBrain)
//
//
//        TimePickerView(hourBrain: hourBrain,
//                       minuteBrain: minuteBrain,
//                       timePicked: $timePicked,
//                       isPresented: $timePickerFlipBrainsPreview,
//                       availableTimeSlot: availableTimeSlot)
//    }
//
//}

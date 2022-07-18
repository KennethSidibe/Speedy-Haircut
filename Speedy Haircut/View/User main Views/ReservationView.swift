//
//  ReservationView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import SwiftUI

struct ReservationView: View {
    
    @EnvironmentObject var dbBrain:DatabaseBrain
    @State var isCalendarPickerShow:Bool = false
    @State var range:ClosedRange<Date>?
    @State var pickedDate:Date?
    @State var pickedTime:Date?
    @State var isTimePickerShow:Bool = false
    @State var availableTimeSlot: [Int: [Int]]?
    var unavailableDates: [Date] {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        let date1 = dateFormat.date(from: "20-07-2022")
        let date2 = dateFormat.date(from: "24-07-2022")
        let date3 = dateFormat.date(from: "31-07-2022")
        let date4 = dateFormat.date(from: "18-08-2022")
        
        return [date1!, date2!, date3!, date4!]
    }
    @State var minutesFlipBrain:FlipViewModel?
    @State var hoursFlipBrain:FlipViewModel?
    var today:String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        let today = Date()
        
        return dateFormat.string(from: today)
    }
    var pickedDateString: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        
        if let pickedDate = pickedDate {
            return dateFormat.string(from: pickedDate)
        } else {
            return today
        }
    }
    var pickedTimeString:String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm"
        
        if let pickedTime = pickedTime {
            return dateFormat.string(from: pickedTime)
        } else {
            
            return dateFormat.string(from: Date())
        }
        
    }
    
    var body: some View {
        
        VStack() {
            
            Text("Make your reservation!")
                .font(.largeTitle)
                .padding()
            
            Group {
                
                HStack() {
                    
                    Text("Reservation Date")
                        .padding()
                        .frame(width: 140)
                        .font(.footnote)
                    
                    HStack {
                        Text("\(pickedDateString)")
                            .frame(width: 200)
                        
                        Button(action: {
                            
                            isCalendarPickerShow = true
                            
                        }, label: {
                            Image(systemName: "calendar")
                                .foregroundColor(Color.blue)
                                .padding(.trailing)
                            
                        })
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(height: 35, alignment: .center)
                    )
                    
                }
                
            }
            .fullScreenCover(isPresented: $isCalendarPickerShow) {
                
                CalendarPicker(
                    date: $pickedDate, unavailableDays: unavailableDates)
                
            }
            
            Group {
                
                HStack() {
                    
                    Text("Time")
                        .frame(width: 100)
                        .padding()
                        .font(.footnote)
                    
                    HStack {
                        Text("\(pickedTimeString)")
                            .frame(width: 200)
                        
                        Button(action: {
                            
                            isTimePickerShow = true
                            
                        }, label: {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color.blue)
                                .padding(.trailing)
                            
                        })
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(height: 35, alignment: .center)
                    )
                    
                }
                
            }
            .sheet(isPresented: $isTimePickerShow) {
                
                let reservableTimeSlot = dbBrain.createReservationTimeSlot(lastTimeToReserve: nil, dateToReserve: pickedDate ?? Date())
                
                let optionalAvailableTimeSlot = Dictionary(
                    uniqueKeysWithValues: reservableTimeSlot.map(
                        { timeSlot in
                            (timeSlot.hour, timeSlot.minutes)
                        }
                    )
                )
                
                let optionalHourSlot = optionalAvailableTimeSlot.keys.sorted()
                let optionalHourString = optionalHourSlot.map { key in
                    return String(key)
                }
                
                let optionalMinutesSlot:[Int] = optionalAvailableTimeSlot[optionalHourSlot.first!]!
                let optionalMinutesSlotString = optionalMinutesSlot.map { value -> String in
                    if value == 0 {
                        return "01"
                    }
                    return String(value)
                }
                
                
                let optionalHourFlipBrain = FlipViewModel(timeSlot: optionalHourString)
                let optionalMinuteFlipBrain = FlipViewModel(timeSlot: optionalMinutesSlotString)

                
                TimePickerView(hourBrain: self.hoursFlipBrain ?? optionalHourFlipBrain, minuteBrain: self.minutesFlipBrain ?? optionalMinuteFlipBrain, timePicked: $pickedTime, isPresented: $isTimePickerShow, availableTimeSlot: self.availableTimeSlot ?? optionalAvailableTimeSlot)
                
            }
            
            Text("Time")
                .font(.title3)
            
            Button(action: {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                
                let reservDate = dateFormatter.date(from: "18-07-2022 12:10")
                
                let name = dbBrain.user.firstName ?? "client"
                
                //                    dbBrain.bookReservation(client:name, date: reservDate ?? Date())
                    
                
            }, label: {
                Text("Create reservation")
                    .padding()
                    .frame(width: 200, height: 50, alignment: .center)
                    .background(Color.black)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                
            })
            .padding()
            
        }
        .onAppear {
            
            Task {
                
                self.availableTimeSlot = await dbBrain.CalculateAvailableSlot(dateSelected: pickedDate ?? Date())
                
                let availableHourSlot = availableTimeSlot!.keys.sorted()
                
                let availableHourSlotString = availableHourSlot.map { key in
                    return String(key)
                }
                
                print("available hour string : \(availableHourSlotString)")
                
                
                let firstKey = availableHourSlot.min()!
                
                let firstMinutesSlot = availableTimeSlot![firstKey]
                
                let firstMinutesSlotString = firstMinutesSlot!.map { key in
                    String(key)
                }

            }
        }
        
    }
}

struct ReservationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let minuteSlot = ["15", "20", "25", "35", "50"]
        let hourSlot = ["3", "4", "9", "12"]
        let minutesFlipBrain = FlipViewModel(timeSlot: minuteSlot)
        let hoursFlipBrain = FlipViewModel(timeSlot: hourSlot)
            ReservationView(minutesFlipBrain: minutesFlipBrain, hoursFlipBrain: hoursFlipBrain)
                .environmentObject(DatabaseBrain())
    }
    
    
}

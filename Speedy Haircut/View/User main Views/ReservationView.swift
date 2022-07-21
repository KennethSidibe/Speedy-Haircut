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
    @State var isTimePickerShow:Bool = false
    private var reservBrain:ReservationBrain = ReservationBrain()
    @State var pickedDate:Date?
    @State var pickedDateString:String?
    @State var pickedTime:Date?
    private var dateFormatter = DateFormatter()
    @State var availableTimeSlot: [Int: [Int]]?
    @State var minutesFlipBrain:FlipViewModel?
    @State var hoursFlipBrain:FlipViewModel?
    private var today:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.string(from: Date())
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
                        Text("\(pickedDateString ?? today)")
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
                    date: $pickedDate,
                    dateString: $pickedDateString,
                    unavailableDays: reservBrain.getUnavailableDates() ?? [Date()])
                .onChange(of: pickedDate ?? Date()) { newValue in
                    reservBrain.setPickedDate(pickedDate: newValue)
                }
                
            }
            
            Group {
                
                HStack() {
                    
                    Text("Time")
                        .frame(width: 100)
                        .padding()
                        .font(.footnote)
                    
                    HStack {
                        Text("\(reservBrain.getPickedTimeString())")
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
            
//            Create Reservation
            Button(action: {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                
                let reservDate = dateFormatter.date(from: "18-07-2022 12:10")
                
                let name = dbBrain.user.firstName ?? "client"
                
                //  dbBrain.bookReservation(client:name, date: reservDate ?? Date())
                    
                
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
                
                let reservations = await dbBrain.fetchReservationList().1
                let queueDates = await dbBrain.fetchQueueList().1
                
                reservBrain.setBrain(reservations: reservations, queueDates: queueDates, datePicked: pickedDate)

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
        ReservationView()
                .environmentObject(DatabaseBrain())
    }
    
    
}

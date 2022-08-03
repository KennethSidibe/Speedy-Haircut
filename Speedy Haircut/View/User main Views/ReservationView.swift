//
//  ReservationView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import SwiftUI

struct TimePickerFlipBrains:Identifiable {
    let id = UUID()
    let hoursFlipBrains:FlipViewModel
    let minutesFlipBrains:FlipViewModel
}

struct ReservationView: View {
    
    @EnvironmentObject private var dbBrain:DatabaseBrain
    @State private var isCalendarPickerShow:Bool = false
    @State private var isTimePickerShow:Bool = false
    private var reservBrain:ReservationBrain = ReservationBrain()
    @State private var pickedDate:Date?
    @State private var pickedDateString:String?
    @State private var pickedTime:Date?
    @State private var pickedTimeString:String?
    @State private var timePickerFlipBrains:TimePickerFlipBrains?
    
    private var today:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.string(from: Date())
    }
    
    private var todayTime:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
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
                    
//                    Set new Picked date and new timeSlot
                    reservBrain.setPickedDate(pickedDate: newValue)
                    reservBrain.setAvailableTimSlotForDate(date: newValue)
                    
                    self.pickedTime = reservBrain.getFirstReservableTimeSlot()
                    self.pickedTimeString = reservBrain.getPickedTimeString()
                }
                
            }
            
            Group {
                
                HStack() {
                    
                    Text("Time")
                        .frame(width: 100)
                        .padding()
                        .font(.footnote)
                    
                    HStack {
                        Text("\(pickedTimeString ?? todayTime)")
                            .frame(width: 200)
                        
                        Button(action: {
                            
                            let hoursFlipModel:FlipViewModel = {
                                reservBrain.setAvailableTimSlotForDate(date: pickedDate ?? Date())
                                let hoursSlot = reservBrain.getHoursSlotFlipBrain()
                                return FlipViewModel(timeSlot: hoursSlot)
                            }()
                                
                            let minutesFlipModel:FlipViewModel = {
                                let firstMinutesSlot:[String] = reservBrain.getFirstMinutesSlot()
                                return FlipViewModel(timeSlot: firstMinutesSlot)
                            }()
                            
                            self.timePickerFlipBrains = TimePickerFlipBrains(
                                hoursFlipBrains: hoursFlipModel,
                                minutesFlipBrains: minutesFlipModel)
                            
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
            .sheet(item: $timePickerFlipBrains) { flipBrains in
                
                TimePickerView(hourBrain: flipBrains.hoursFlipBrains,
                               minuteBrain: flipBrains.minutesFlipBrains,
                               timePicked: $pickedTime,
                               timePickedString: $pickedTimeString,
                               timePickerFlipBrains: $timePickerFlipBrains,
                               availableTimeSlot: reservBrain.getAvailableTimeSlot()!)
                
            }
            
            Text("Time")
                .font(.title3)
            
//            Create Reservation
            Button(action: {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                
                let name = dbBrain.getUserFirstName() ?? "client"
                
                if let pickedTime = pickedTime, let pickedDate = pickedDate {
                    
                    let reservationDate = reservBrain.getReservationDate(date: pickedDate,
                                                                         time: pickedTime)
                    
                    dbBrain.bookReservation(client: name, date: reservationDate) {
                        
                        DispatchQueue.main.async {
                            
                            print("Reservation succesful !")
                        
                        }
                    }
                    
                }
                
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
                
                let reservations = dbBrain.getReservations()!.1
                let queueDates = dbBrain.getQueueList()!.1
                
                reservBrain.setBrain(
                    reservations: reservations,
                    queueDates: queueDates,
                    datePicked: pickedDate)
                
                
//                Methods to set date and time input forms to first date & time reservable 
                self.pickedDate = reservBrain.getFirstReservableDate()
                self.pickedTime = reservBrain.getFirstReservableTimeSlot()
                
                self.pickedDateString = reservBrain.getPickedDateString()
                self.pickedTimeString = reservBrain.getPickedTimeString()
                
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

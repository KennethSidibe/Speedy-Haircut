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
                    
                    let reservationDate = reservBrain.getBookingDate(date: pickedDate,
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
                
                dbBrain.fetchBookingData { Reservations, QueueList in
                    
                    DispatchQueue.main.async {
                        
                        let reservations = Reservations.1
                        let queueDates = QueueList.1
                        
                        setInputForms(reservations: reservations,
                                      queueDates: queueDates,
                                      pickedDate: pickedDate)
                        
                    }
                    
                }
                
            }
        }
        .onChange(of: dbBrain.hasDataUpdated()) { dataHasUpdated in
            
            DispatchQueue.main.async {
                
                if dataHasUpdated {
                    
                    guard let reservations = dbBrain.getReservationsDate(),
                          let queueListDates = dbBrain.getQueueListDates() else {
                        
                        print("Reservations and queueList was found empty")
                        
                        return
                    }
                    
                    setInputForms(reservations: reservations,
                                  queueDates: queueListDates,
                                  pickedDate: pickedDate)
                    
                    dbBrain.bookingDataHasBeenUpdated()
                    
                }
                
            }
            
            
            
        }
        
    }
}

extension ReservationView {
    
    //MARK: - Set methods
    func setInputForms(reservations:[Date], queueDates:[Date], pickedDate:Date?) {
        

        reservBrain.setBrain(
            reservations: reservations,
            queueDates: queueDates,
            datePicked: pickedDate)
        
        
//      Methods to set date and time input forms to first date & time reservable
        self.pickedDate = reservBrain.getFirstReservableDate()
        self.pickedTime = reservBrain.getFirstReservableTimeSlot()
        
        self.pickedDateString = reservBrain.getPickedDateString()
        self.pickedTimeString = reservBrain.getPickedTimeString()
    }
    
    func setPickedDate(pickedDate:Date) {
        self.pickedDate = pickedDate
    }
    func setPickedTime(pickedTime:Date) {
        self.pickedTime = pickedTime
    }
    func setPickedDateString(pickedDateString:String) {
        self.pickedDateString = pickedDateString
    }
    func setPickedTimeString(pickedTimeString:String) {
        self.pickedTimeString = pickedTimeString
    }
    
}

struct ReservationView_Previews: PreviewProvider {
    
    @EnvironmentObject private var dbBrain:DatabaseBrain
    
    static var previews: some View {
        let reservBrainPreview = ReservationBrain()
        let reservationsPreview:[Date] = reservBrainPreview.generateRandomDates()
        let queueListPreview:[Date] = reservBrainPreview.generateRandomQueueList()
        let pickedDatePreview = Date()
        
        
        ReservationView()
                .environmentObject(DatabaseBrain())
                .onAppear {
                    
                    reservBrainPreview.setBrain(
                        reservations: reservationsPreview,
                        queueDates: queueListPreview,
                        datePicked: pickedDatePreview)
                    
                }
    }
    
    func setInputForms(reservations:[Date], queueDates:[Date], pickedDate:Date?) {
        
    }
    
    
}

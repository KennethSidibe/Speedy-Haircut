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
    
    @EnvironmentObject var dbBrain:DatabaseBrain
    @State var isCalendarPickerShow:Bool = false
    @State var isTimePickerShow:Bool = false
    private var reservBrain:ReservationBrain = ReservationBrain()
    @State var pickedDate:Date?
    @State var pickedDateString:String?
    @State var pickedTime:Date?
    @State var pickedTimeString:String?
    @State var timePickerFlipBrains:TimePickerFlipBrains?
    
    private var reservationsDate:[Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        var reserv = [Date]()
        let reserv1 = dateFormatter.date(from: "23-07-2022 12:15")!
        let reserv2 = dateFormatter.date(from: "23-07-2022 12:35")!
        let reserv3 = dateFormatter.date(from: "23-07-2022 12:50")!
        let reserv4 = dateFormatter.date(from: "25-07-2022 11:20")!
        let reserv5 = dateFormatter.date(from: "25-07-2022 11:40")!
        let reserv6 = dateFormatter.date(from: "25-07-2022 11:10")!
        let reserv7 = dateFormatter.date(from: "25-07-2022 11:14")!
        let reserv8 = dateFormatter.date(from: "25-07-2022 11:28")!
        let reserv9 = dateFormatter.date(from: "25-07-2022 11:28")!
        let reserv10 = dateFormatter.date(from: "25-07-2022 11:28")!
        let reserv11 = dateFormatter.date(from: "25-07-2022 11:08")!
        let reserv12 = dateFormatter.date(from: "25-07-2022 11:11")!
        let reserv13 = dateFormatter.date(from: "25-07-2022 11:44")!
        let reserv14 = dateFormatter.date(from: "25-07-2022 11:54")!
        let reserv15 = dateFormatter.date(from: "25-07-2022 11:09")!
        
        reserv.append(reserv1)
        reserv.append(reserv2)
        reserv.append(reserv3)
        reserv.append(reserv4)
        reserv.append(reserv5)
        reserv.append(reserv6)
        reserv.append(reserv7)
        reserv.append(reserv8)
        reserv.append(reserv9)
        reserv.append(reserv10)
        reserv.append(reserv11)
        reserv.append(reserv12)
        reserv.append(reserv13)
        reserv.append(reserv14)
        reserv.append(reserv15)
        
        return reserv
    }
    private var queueDates:[Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        var dates = [Date]()
        let queue1 = dateFormatter.date(from: "22-07-2022 09:30")!
        let queue2 = dateFormatter.date(from: "22-07-2022 10:20")!
        let queue3 = dateFormatter.date(from: "22-07-2022 10:20")!
        
        dates.append(queue1)
        dates.append(queue2)
        dates.append(queue3)
        
        return dates
    }
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
                        Text("\(pickedTimeString ?? todayTime)")
                            .frame(width: 200)
                        
                        Button(action: {
                            
                            let hoursFlipModel:FlipViewModel = {
                                let hoursSlot = reservBrain.getHoursSlotFlipBrain()
                                print("hour slot: ",hoursSlot)
                                print()
                                return FlipViewModel(timeSlot: hoursSlot)
                            }()
                                
                            let minutesFlipModel:FlipViewModel = {
                                let firstMinutesSlot:[String] = reservBrain.getFirstMinutesSlot()
                                print("minutes slot: ",firstMinutesSlot)
                                print()
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
                
//                let reservations = await dbBrain.fetchReservationList().1
//                let queueDates = await dbBrain.fetchQueueList().1
                
                let reservations = self.reservationsDate
                let queueDates = self.queueDates
                
                self.pickedDate = Date()
                
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

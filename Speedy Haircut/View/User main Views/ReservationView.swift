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
    var unavailableDates: [Date] {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy"
        let date1 = dateFormat.date(from: "20-07-2022")
        let date2 = dateFormat.date(from: "24-07-2022")
        let date3 = dateFormat.date(from: "31-07-2022")
        let date4 = dateFormat.date(from: "18-08-2022")
        
        return [date1!, date2!, date3!, date4!]
    }
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
    
    

    
    var body: some View {
        
        let minuteSlot = ["15", "20", "25", "35", "50"]
        let hourSlot = ["3", "4", "9", "12"]
        let minutesFlipBrain:FlipViewModel = FlipViewModel(timeSlot: minuteSlot)
        let hoursFlipBrain:FlipViewModel = FlipViewModel(timeSlot: hourSlot)
        
        VStack() {
            
            Text("Make your reservation!")
                .font(.largeTitle)
                .padding()
            
            Group {
                
                HStack() {
                    
                    Text("Reservation Date")
                        .padding()
                        .font(.footnote)
                    
                    HStack {
                        Text("\(pickedDateString)")
                            .frame(width: 200)
                        
                        Button(action: {
                            
                            isCalendarPickerShow = true
                            
                        }, label: {
                            Image(systemName: "calendar")
                                .foregroundColor(Color.black)
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
            
            
            Text("Time")
                .font(.title3)
            
            
            TimePickerView(hourBrain: hoursFlipBrain, minuteBrain: minutesFlipBrain)
            
            Button(action: {
                
                Task {
                    
                    await dbBrain.CalculateAvailableSlot()
                    
                    let name = dbBrain.user.firstName ?? "client"
                    
//                    dbBrain.bookReservation(client:name, date: pickedDate ?? Date())
                    
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
            
        }
    }
}

struct ReservationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
            ReservationView()
                .environmentObject(DatabaseBrain())
    }
    
    
}

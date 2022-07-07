//
//  ReservationView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import SwiftUI

struct ReservationView: View {
    
    @EnvironmentObject var dbBrain:DatabaseBrain
    @State var reservationDate =  Date()
    @State var range:ClosedRange<Date>?
    
    
    var body: some View {
        
        VStack() {
            
            Text("Make your reservation!")
                .padding()
            
            DatePicker(
                "Pick a date",
                selection: $reservationDate,
                in:range ?? Date()...Date().addingTimeInterval(86400*365),
                displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.graphical)
            .frame(width: 300, alignment: .center)
            
            Button(action: {
                
                
                
            }, label: {
                Text("Create reservation")
                    .padding()
                    .frame(width: 200, height: 50, alignment: .center)
                    .background(Color.black)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                
            })
        }
        .onAppear {
            
            let currentYear = Date()
            let currentDay = Date()
            let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: currentYear) ?? currentYear.addingTimeInterval(86400*365)
            
            let twoHoursBefore = Calendar.current.date(byAdding: .hour, value: -2, to: currentDay) ?? currentDay.addingTimeInterval(-86400*365)
            
            range = twoHoursBefore...nextYear
        }
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        
        let rightNow = Date()
        let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: rightNow)
        
        ReservationView(range: Date()...nextYear!)
            .environmentObject(DatabaseBrain())
    }
    
    
}

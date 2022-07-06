//
//  ReservationView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import SwiftUI

struct ReservationView: View {
    
    @EnvironmentObject var dbBrain:DatabaseBrain
    
    var body: some View {
        Text("Make your reservation!")
        
        Button(action: {
            
            
            
        }, label: {
            Text("Create reservation now!")
                .padding()
                .frame(width: 150, height: 50, alignment: .center)
                .background(Color.black)
                .cornerRadius(10)
                .foregroundColor(Color.white)
            
        })
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView()
            .environmentObject(DatabaseBrain())
    }
    
    
}

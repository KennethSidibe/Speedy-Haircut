//
//  UserTabView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import SwiftUI

struct UserTabView: View {
    
    @State var tabSelected:Int = 1
    @State var queueNumber: Int
    @EnvironmentObject var authBrain:AuthenticationBrain
    @EnvironmentObject var dbBrain:DatabaseBrain
//    @State var animate = false
    
    var body: some View {
        
        TabView(selection: $tabSelected){
            
            ProfileView(queueNumber: queueNumber)
                .environmentObject(authBrain)
                .environmentObject(dbBrain)
                .tag(1)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
            
            if #available(iOS 15.0, *) {
                QueueView()
                    .tag(2)
                    .badge(5)
                    .tabItem {
                        Label("Queue", systemImage: "person.3.sequence.fill")
                    }
            } else {
                // Fallback on earlier versions
                QueueView()
                    .tag(2)
                    .tabItem {
                        Label("Queue", systemImage: "person.3.sequence.fill")
                    }
            }
            
            if #available(iOS 15.0, *) {
                ReservationView()
                    .tag(3)
                    .badge(7)
                    .tabItem {
                        Label("Reservation", systemImage: "scissors")
                    }
            } else {
                // Fallback on earlier versions
                ReservationView()
                    .tag(3)
                    .tabItem {
                        Label("Reservation", systemImage: "scissors")
                    }
            }
            
        }
        
    }
}

struct UserTabView_Previews: PreviewProvider {
    static var previews: some View {
        UserTabView(queueNumber: 1)
            .environmentObject(AuthenticationBrain())
            .environmentObject(DatabaseBrain())
    }
}

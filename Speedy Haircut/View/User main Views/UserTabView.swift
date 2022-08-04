//
//  UserTabView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//

import SwiftUI

struct UserTabView: View {
    
    init(queueNumber:Int) {
        self.queueNumber = queueNumber
    }
    
    @State private var tabSelected:Int = 1
    @State private var queueNumber: Int
    @EnvironmentObject private var authBrain:AuthenticationBrain
    @EnvironmentObject private var dbBrain:DatabaseBrain
    
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
                    .environmentObject(dbBrain)
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
                    .environmentObject(dbBrain)
                    .tag(3)
                    .badge(7)
                    .tabItem {
                        Label("Reservation", systemImage: "scissors")
                    }
            } else {
                // Fallback on earlier versions
                ReservationView()
                    .environmentObject(dbBrain)
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

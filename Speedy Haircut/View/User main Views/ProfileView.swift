//
//  ProfileView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-30.
//

/*
 
 View that generates the profile of user
 
 */

import SwiftUI

struct ProfileView: View {
    
    init(queueNumber:Int) {
        self.queueNumber = queueNumber
    }
    
    @EnvironmentObject private var authBrain:AuthenticationBrain
    @EnvironmentObject private var dbBrain:DatabaseBrain
    @State private var queueNumber: Int
    @State private var isQueueingViewPresented:Bool = false
    
    var body: some View {
        
        let currentUser = dbBrain.getUser()
        let name = currentUser.firstName ?? "User"
        
        NavigationView {
            
            VStack(spacing: 20) {
                
                Text("Welcome, \(name) ")
                    .font(.title)
                
                LottieView(fileName: "Lottie-Animations/barber-loading")
                    .frame(width: 100, height: 200, alignment: .center)
                
                Text("Get your haircut A$AP")
                    .padding()
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                
                Text("Queue: \(queueNumber)")
                
                Button(action: {
                    
                    isQueueingViewPresented = true
                    
                    dbBrain.addToQueue { currentQueueNumber in
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            
                            queueNumber = currentQueueNumber
                            isQueueingViewPresented = false
                            
                        }
                        
                    }
                    
                }, label: {
                    
                    Text("Check-in")
                        .padding()
                        .frame(width: 150, height: 50, alignment: .center)
                        .background(Color.black)
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                    
                }).fullScreenCover(isPresented: $isQueueingViewPresented, content: {
                    
                    QueueingView(isQueueing: $isQueueingViewPresented)
                    
                })
                
                .toolbar {
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            authBrain.signOut()
                            dbBrain.setUser(user: User())
                            dbBrain.setisUserDataFetched(false)
                        }, label: {
                            Text("Sign out")
                                .padding()
                        })
                    }
                    
                    ToolbarItemGroup (placement:.navigationBarLeading) {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "person.crop.circle")
                                .padding()
                        })
                    }
                }
                
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(queueNumber: 0)
            .environmentObject(AuthenticationBrain())
            .environmentObject(DatabaseBrain())
        
    }
}

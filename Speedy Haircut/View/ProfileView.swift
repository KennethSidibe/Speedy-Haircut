//
//  ProfileView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-30.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authBrain:AuthenticationBrain
    @EnvironmentObject var dbBrain:DatabaseBrain
    @State var queueNumber: Int 
    
    var body: some View {
        
        var currentUser = dbBrain.user
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
                    
                    dbBrain.addToQueue { currentQueueNumber in
                        
                        DispatchQueue.main.async {
                            
                            queueNumber = currentQueueNumber
                        }
                        
                    }
                    
                }, label: {
                    Text("Check-in")
                        .padding()
                        .frame(width: 150, height: 50, alignment: .center)
                        .background(Color.black)
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                    
                })
                
                
                .toolbar {
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            authBrain.signOut()
                            dbBrain.user = User()
                            dbBrain.isDataAvailable = false
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

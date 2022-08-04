//
//  AdministratorProfileView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-08-04.
//

import SwiftUI

struct AdministratorProfileView: View {
    
    @EnvironmentObject private var authBrain:AuthenticationBrain
    @EnvironmentObject private var dbBrain:DatabaseBrain
    
    var body: some View {
        
        let currentAdministrator = dbBrain.getUser()
        let name = currentAdministrator.firstName ?? "Admin"
        
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
                
                Button(action: {
                    
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

struct AdministratorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AdministratorProfileView()
            .environmentObject(AuthenticationBrain())
            .environmentObject(DatabaseBrain())
    }
}

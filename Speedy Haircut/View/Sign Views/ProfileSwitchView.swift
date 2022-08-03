//
//  profileSwitchView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-28
//

import SwiftUI
import FirebaseAuth

struct ProfileSwitchView: View {
    
    @EnvironmentObject var authBrain:AuthenticationBrain
    @StateObject var dbBrain = DatabaseBrain()
    
    var body: some View {
        
        if dbBrain.isUserDataAvailable() {
            
            UserTabView(queueNumber: dbBrain.getUserLineNumber()!)
                .environmentObject(authBrain)
                .environmentObject(dbBrain)
            
        }
        else {
            LoadingView()
                .onAppear{
                    
                    let loggedUserUid = authBrain.getSignedUserUid()!
                    dbBrain.setUserUid(userUid: loggedUserUid)
                    
                    Task {
                        
                        if let currentUser = await self.dbBrain.getUserData(with: loggedUserUid) {
                            
                            self.dbBrain.setUser(user: currentUser)
                            await self.dbBrain.setDatabaseBrain()
                            
                            //                        Delay to let loading animation play
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                
                                    self.dbBrain.setIsDataAvailable(true) 
                                
                                
                            }
                        }
                    }
                }
        }
        
    }
}

struct profileView_Preview:PreviewProvider {
    static var previews: some View {
        ProfileSwitchView()
            .environmentObject(AuthenticationBrain())
            .previewDevice(PreviewDevice(rawValue:"iPhone 12"))
            .previewDisplayName("iPhone 12")
        
    }
}

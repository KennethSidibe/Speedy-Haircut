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
        
        if dbBrain.isDataAvailable {
            
            UserTabView(queueNumber: dbBrain.user.lineNumber!)
                .environmentObject(authBrain)
                .environmentObject(dbBrain)
            
        }
        else {
            LoadingView()
                .onAppear{
                    
                    let loggedUserUid = authBrain.auth.currentUser!.uid
                    dbBrain.user.id = loggedUserUid
                    
                    Task {
                        
                        if let currentUser = await self.dbBrain.getUserData(with: loggedUserUid) {
                            
                            self.dbBrain.user = currentUser
                            await self.dbBrain.setDatabaseBrain()
                            
                            //                        Delay to let loading animation play
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                
                                    self.dbBrain.isDataAvailable = true
                                
                                
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

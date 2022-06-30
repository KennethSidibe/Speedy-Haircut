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
            
            ProfileView()
                .environmentObject(authBrain)
                .environmentObject(dbBrain)
            
        }
        else {
            LoadingView()
                .onAppear{
                    
                    self.dbBrain.getData { user in
                        
//                        Delay to let loading animation play
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            
                            if let currentUser = user {
                                
                                self.dbBrain.user = currentUser
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

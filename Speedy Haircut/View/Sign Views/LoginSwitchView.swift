//
//  LoginSwitchView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import FirebaseAuth

struct LoginSwitchView: View {
    
    @StateObject var authBrain:AuthenticationBrain = AuthenticationBrain()
    
    var body: some View {
        
        NavigationView {
            
            if authBrain.isSignedIn() {
                ProfileSwitchView()
                    .environmentObject(authBrain)
            }
            else {
                SignInView()
                    .environmentObject(authBrain)
            }
        }
//        If there is already a current user in our auth, we assign true to the signIn boolean
        .onAppear {
            self.authBrain.setIsSignedIn(true)
        }
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {

        LoginSwitchView()
            .environmentObject(AuthenticationBrain())
    }
}

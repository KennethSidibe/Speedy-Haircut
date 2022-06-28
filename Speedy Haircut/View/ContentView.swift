//
//  ContentView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var authBrain:AuthenticationBrain
    
    var body: some View {
        
        NavigationView {
            
            if authBrain.signIn {
                ProfileView()
                    .environmentObject(authBrain)
            }
            else {
                SignInView()
                    .environmentObject(authBrain)
            }
        }
        .environmentObject(authBrain)
//        If there is already a current user in our auth, we assign true to the signIn boolean
        .onAppear {
            self.authBrain.signIn = self.authBrain.isSignin
        }
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {

        ContentView()
            .environmentObject(AuthenticationBrain())
    }
}

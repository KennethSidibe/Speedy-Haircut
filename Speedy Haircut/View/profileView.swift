//
//  profileView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-28.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    
    @EnvironmentObject var authBrain:AuthenticationBrain
    
    var body: some View {
        
//        TO DO a lot 
        
        VStack {
            Text("Signed In succesfully")
                .padding()
                .font(.largeTitle)
                .foregroundColor(.black)
            
            Button(action: {
                authBrain.signOut()
            }, label: {
                Text("Sign out")
                    .frame(width: 300, height: 50, alignment: .center)
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            })
        }
        
    }
    
}

struct profileView_Preview:PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationBrain())
    }
}

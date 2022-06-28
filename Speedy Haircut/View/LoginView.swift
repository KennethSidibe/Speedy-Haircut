//
//  ContentView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import ChameleonFramework
import FirebaseAuth

struct ContentView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        let backgroundColor = "74b9ff"
        let textFieldBgImage = "TextField"
        
        NavigationView {
            
            ZStack {
                Color.init(FlatWhite()).ignoresSafeArea()
                
                .navigationTitle("Login")
                .navigationBarTitleDisplayMode(.automatic)
                
                VStack(alignment: .center) {
                    
                    Text("Get your haircut FAST")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        
                        Text("Login").font(.title).bold()
                        
                        TextField("Username",text: $username)
                            .padding()
                            .frame(width: 300, height: 50, alignment: .center)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                        
                        TextField("password",text: $password)
                            .padding()
                            .frame(width: 300, height: 50, alignment: .center)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                        
                    }
                    
                    Spacer()
                }
            }
            
        }

        
    }
    
    func authenticate(username:String, password:String) {
        
        
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

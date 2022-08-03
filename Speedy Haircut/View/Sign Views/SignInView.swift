//
//  SignInView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import ChameleonFramework
import FirebaseAuth

struct SignInView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @EnvironmentObject private var authBrain:AuthenticationBrain
    
//    Check if we should present the SignUp page or not
    
    @State private var showSignUp:Bool = false
    
    var body: some View {
        
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
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    
                    SecureField("password",text: $password)
                        .padding()
                        .frame(width: 300, height: 50, alignment: .center)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                }
                
                Button(action: {
                    
                    authBrain.signIn(username: username, password: password)
                    
                }, label: {
                    Text("Sign in")
                        .frame(width: 200, height: 50, alignment: .center)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                })
                
                Button(action: {
                    
                    showSignUp = true
                    
                }, label: {
                    
                    Text("Create Account")
                        .foregroundColor(Color.blue)
                        .padding()
                        
                    
                }).foregroundColor(Color.blue)
                
                    .sheet(isPresented: $showSignUp) {
                        SignUpView(isPresented: $showSignUp)
                            .environmentObject(authBrain)
                    }
                
                Spacer()
                
            }
        }
    }
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthenticationBrain())
    }
}

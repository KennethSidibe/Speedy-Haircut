//
//  SignUpView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-27.
//

import SwiftUI
import ChameleonFramework
import FirebaseAuth

struct SignUpView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authBrain:AuthenticationBrain
    
    var body: some View {
        
        ZStack {
            Color.init(FlatWhite()).ignoresSafeArea()
            
                .navigationTitle("Sign Up")
                .navigationBarTitleDisplayMode(.automatic)
            
            VStack(alignment: .center) {
                
                Text("Get your haircut FAST")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(alignment: .center) {
                    
                    Text("Sign up").font(.title).bold()
                    
                    TextField("Username",text: $username)
                        .padding()
                        .frame(width: 300, height: 50, alignment: .center)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.top)
                        
                    
                    GroupBox {
                        TextField("First name",text: $username)
                            .padding()
                            .frame(width: 300, height: 50, alignment: .center)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        
                        TextField("Last Name",text: $username)
                            .padding()
                            .frame(width: 300, height: 50, alignment: .center)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }.padding(15)
                    
                    SecureField("Password",text: $password)
                        .padding()
                        .frame(width: 300, height: 50, alignment: .center)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .padding(.bottom)
                }
                
                Button(action: {
                    
                    authBrain.signUp(username: username, password: password)
                    
                }, label: {
                    Text("Sign Up")
                        .frame(width: 200, height: 50, alignment: .center)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                    
                })
                
                Spacer()
                
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    
    static var previews: some View {

        SignUpView()
            .environmentObject(AuthenticationBrain())
    }
}

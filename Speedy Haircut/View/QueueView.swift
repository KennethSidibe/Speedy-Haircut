//
//  QueueView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-02.
//
/*
 One main view of the app that will show a list of all the people that are currently in the queue
 */


import SwiftUI

struct QueueView: View {
    
    @EnvironmentObject var dbBrain:DatabaseBrain
    @State var userList:[User] = [User]()
    
    var body: some View {
        
        VStack {
            
            Text("Here is a list of all the person in the queue")
            
            List() {
                
                ForEach(userList) { user in
                    
                    HStack {
                        
                        Text(user.firstName!)
                        
                        Text(String(user.lineNumber!))
                        
                    }
                }
                
                
            }
            
            Button(action: {
                
                dbBrain.fetchQueueList { userFetchList in
                    
                    DispatchQueue.main.async {
                        userList = userFetchList
                    }
                    
                }
                
            }, label: {
                Text("Check-in")
                    .padding()
                    .frame(width: 150, height: 50, alignment: .center)
                    .background(Color.black)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
                
            })
            
        }.onAppear {
            
            dbBrain.fetchQueueList { userFetchList in
                
                DispatchQueue.main.async {
                    userList = userFetchList
                }
                
            }
        }
        
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView()
    }
}

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
    
    @EnvironmentObject private var dbBrain:DatabaseBrain
    @State private var userList:[QueueUser] = [QueueUser]()
    
    
    var body: some View {
        
        VStack {
            
            Text("Here is a list of all the person in the queue")
            
            List() {
                
                ForEach(userList) { user in
                    
                    HStack {
                        
                        Text(user.name!)
                        
                        Text(String(user.lineNumber ?? 0) ?? "User")
                        
                    }
                }
                
                
            }
            
            Button(action: {
                
                Task {
                    
                    let (fetchList, timeEnteredQueueList) = await dbBrain.fetchQueueList()
                    
                    guard fetchList != [], timeEnteredQueueList != [] else {
                        print("Error while calling dbBrain fetchQueueList")
                        return
                    }
                    
                    userList = fetchList
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
            
            Task {
                
                let (fetchList, timeEnteredQueueList) = await dbBrain.fetchQueueList()
                
                guard fetchList != [], timeEnteredQueueList != [] else {
                    print("Error while calling dbBrain fetchQueueList")
                    return
                }
                
                userList = fetchList
            }

        }
        
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView()
            .environmentObject(DatabaseBrain())
    }
}

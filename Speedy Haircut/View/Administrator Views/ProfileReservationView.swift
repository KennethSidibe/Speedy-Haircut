//
//  ProfileReservationView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-08-05.
//

import SwiftUI

struct ProfileReservationView: View {
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red, lineWidth: 4)
                .background(Color.white.opacity(0.7))
                .frame(width: 60, height: 150)
                .offset(x: 129)
                .shadow(radius: 5)
                
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 4)
                .frame(width: 60, height: 150)
                .offset(x: 129+5)
                .opacity(0.8)
                .shadow(radius: 5)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.pink, lineWidth: 4)
                .frame(width: 60, height: 150)
                .offset(x: 129+5*2)
                .opacity(0.5)
                .shadow(radius: 5)
            
            HStack(alignment: .center) {
                
                VStack {
                    
                    Image(systemName: "person")
                        .resizable()
                        .frame(maxHeight: 50)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        
                    
                    Text("Ken")
                        .padding(.bottom)
                    
                }
                
                HStack {

                    Text("Tue 25 \n Aug")
                        .multilineTextAlignment(.center)
                        .padding(.trailing)
                        .padding(.leading)

                    Text("15: 30")
                        .padding(.trailing)

                }
                .frame(maxHeight: .infinity)
                .background(Color.white)
                .padding()
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .frame(height: 150)
            .overlay (
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 4)
            )
            
            
            
        }
        
        
    }
    
}

struct ProfileReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileReservationView()
    }
}

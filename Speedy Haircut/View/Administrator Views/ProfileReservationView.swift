//
//  ProfileReservationView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-08-05.
//

import SwiftUI

struct ProfileReservationView: View {
    
    var body: some View {
        
        ZStack() {
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.pink)
                .scaleEffect(x: 0.6, y: 0.6, anchor: .center)
                .frame(width: 60, height: 150)
                .offset(x: -(140+20*2+13))
                .shadow(radius: 5)
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.yellow)
                .scaleEffect(x: 0.7, y: 0.7, anchor: .center)
                .frame(width: 60, height: 150)
                .offset(x: -(140+(20*2)))
                .shadow(radius: 5)
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.blue)
                .scaleEffect(x: 0.8, y: 0.8, anchor: .center)
                .frame(width: 60, height: 150)
                .offset(x: -(140+20*1))
                .shadow(radius: 5)
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.red)
                .scaleEffect(x: 0.9, y: 0.9, anchor: .center)
                .frame(width: 60, height: 150)
                .offset(x: -(140))
                .shadow(radius: 5)
            
            HStack(alignment: .center) {
                
                VStack {
                    
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    
                    Text("Ken")
                    
                }
                
                HStack {

                    Text("Tue 25 \n Aug")
                        .multilineTextAlignment(.center)
                        .padding(.trailing)

                    Text("15: 30")

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
        .onTapGesture {
            print("Opening tiles")
        }
        
        
        
    }
    
}

struct ProfileReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileReservationView()
    }
}

//
//  LoadingView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-29.
//

import SwiftUI
import ChameleonFramework

struct LoadingView: View {
    
    @EnvironmentObject private var dbBrain:DatabaseBrain
    @EnvironmentObject private var authBrain:AuthenticationBrain
    
    var body: some View {
        
        ZStack {
            Color.init(FlatWhite()).ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Loading your haircut")
                    .font(.largeTitle)
                
                LottieView(fileName: "Lottie-Animations/loading-animation")
                    .frame(width: 400, height: 500, alignment: .center)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    .scaleEffect(3)
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

//
//  QueueingView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-01.
//

import SwiftUI
import ChameleonFramework

struct QueueingView: View {
    
    init(isQueueing:Binding<Bool>) {
        self._isQueueing = isQueueing
    }
    
    @Binding private var isQueueing: Bool
    
    var body: some View {
        
        ZStack {
            Color.init(white: 1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Queueing !")
                    .font(.largeTitle)
                
                LottieView(fileName: "Lottie-Animations/queueing-loading")
                    .frame(width: 400, height: 300, alignment: .center)
                    .padding()
                    .padding(.bottom, 40)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    .scaleEffect(3)
                    .padding()
            }
        }
    }
}

struct QueueingView_Previews: PreviewProvider {
    static var previews: some View {
        QueueingView(isQueueing: .constant(true))
    }
}

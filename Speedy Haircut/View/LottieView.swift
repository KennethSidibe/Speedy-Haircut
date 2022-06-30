//
//  LottieView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-06-29.
//

import SwiftUI
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
    
    typealias UIViewType = UIView
    
    let fileName:String
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: .zero)
        
        let animationView = AnimationView()
        animationView.animation = Animation.named(fileName)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
        
    }
    func updateUIView(_ uiView: UIView, context: Context) {
//        Do nothin
        return
    }
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(fileName: "Lottie-Animations/barber-loading")
    }
}

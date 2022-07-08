//
//  FlipView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-07-07.
//

import SwiftUI

struct FlipView: View {

    init(viewModel: FlipViewModel) {
        self.viewModel = viewModel
    }

    @ObservedObject var viewModel: FlipViewModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SingleFlipView(text: viewModel.newValue ?? "", type: .top)
                SingleFlipView(text: viewModel.oldValue ?? "", type: .top)
                    .rotation3DEffect(.init(degrees: self.viewModel.animateTop ? -90 : .zero),
                                      axis: (1, 0, 0),
                                      anchor: .bottom,
                                      perspective: 0.5)
            }
            
//            Separator
            Color.white
                .frame(height: 1)
            
            ZStack {
                SingleFlipView(text: viewModel.oldValue ?? "", type: .bottom)
                SingleFlipView(text: viewModel.newValue ?? "", type: .bottom)
                    .rotation3DEffect(.init(degrees: self.viewModel.animateBottom ? .zero : 90),
                                      axis: (1, 0, 0),
                                      anchor: .top,
                                      perspective: 0.5)
            }
        }
            .fixedSize()
    }

}

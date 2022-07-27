//
//  LoadingIndicator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(x: 1.7, y: 1.7)
        } else {
            ActivityIndicatorRepresentable(animating: .constant(true))
        }
    }
}

private struct ActivityIndicatorRepresentable: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    
    @Binding var animating: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        animating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

//
//  CreateSeedIdentityView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import SwiftUI

struct CreateSeedIdentityView: Page {
    @ObservedObject var viewModel: CreateSeedIdentityViewModel
    
    var pageBody: some View {
        WebView(
            request: viewModel.request,
            onResult: viewModel.send(_:)
        )
    }
}

private struct WebView: UIViewControllerRepresentable {
    let request: URLRequest?
    let onResult: (CreateSeedIdentityEvent) -> Void
    
    class Coordinator: IdentityProviderWebViewPresenterProtocol {
        var parent: WebView {
            didSet {
                if let request = parent.request {
                    view?.show(url: request)
                }
            }
        }
        weak var view: IdentityProviderWebViewViewProtocol?
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func viewDidLoad() {
            if let request = parent.request {
                view?.show(url: request)
            }
        }
        
        func closeTapped() {
            parent.onResult(.close)
        }
        
        func receivedCallback(_ callback: String) {
            parent.onResult(.receivedCallback(callback))
        }
        
        func urlFailedToLoad(error: Error) {
            parent.onResult(.failedToLoad(error))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        IdentityProviderWebViewFactory.create(with: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.parent = self
    }
}

struct CreateSeedIdentityView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = URL(string: "https://www.concordium.com") {
            CreateSeedIdentityView(
                viewModel: .init(
                    request: .init(url: url)
                )
            )
        }
    }
}

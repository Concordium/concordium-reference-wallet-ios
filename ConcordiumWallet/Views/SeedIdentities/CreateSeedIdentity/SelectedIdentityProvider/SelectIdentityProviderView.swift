//
//  SelectIdentityProviderView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SelectIdentityProviderView: Page {
    @ObservedObject var viewModel: SelectIdentityProviderViewModel
    
    var pageBody: some View {
        VStack {
            if !viewModel.isNewIdentityAfterSettingUpTheWallet {
                PageIndicator(numberOfPages: 4, currentPage: 3)
            }
            IdentityProvidersView(
                identityProviders: viewModel.identityProviders,
                onShowInfo: { viewModel.send(.showInfo(url: $0)) },
                onProviderSelected: {
                    viewModel.send(.selectIdentityProvider(identityProvider: $0))
                }
            )
        }.padding(.init(top: 10, leading: 0, bottom: 30, trailing: 0))
    }
}

private struct IdentityProvidersView: UIViewControllerRepresentable {
    let identityProviders: [IPInfoResponseElement]
    let onShowInfo: (URL) -> Void
    let onProviderSelected: (IPInfoResponseElement) -> Void
    
    class Coordinator: IdentityProviderListPresenterProtocol {
        var parent: IdentityProvidersView {
            didSet {
                updateViewModel()
            }
        }
        weak var view: IdentityProviderListViewProtocol?
        
        private let viewModel: IdentityProviderListViewModel
        
        init(parent: IdentityProvidersView) {
            self.parent = parent
            self.viewModel = IdentityProviderListViewModel()
        }
        
        private func updateViewModel() {
            viewModel.identityProviders = parent.identityProviders.map(IdentityProviderViewModel.init(ipInfo:))
        }
        
        func viewDidLoad() {
            self.view?.bind(to: viewModel)
        }
        
        func closeIdentityProviderList() {
            
        }
        
        func userSelected(identityProviderIndex: Int) {
            if identityProviderIndex >= 0 && identityProviderIndex < parent.identityProviders.count {
                parent.onProviderSelected(
                    parent.identityProviders[identityProviderIndex]
                )
            }
        }
        
        func userSelectedIdentitiyProviderInfo(url: URL) {
            parent.onShowInfo(url)
        }
        
        func getIdentityName() -> String {
           return ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        IdentityProviderListFactory.create(with: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.parent = self
    }
}

struct SelectIdentityProviderView_Previews: PreviewProvider {
    static var previews: some View {
        SelectIdentityProviderView(
            viewModel: .init(
                identityProviders: [], isNewIdentityAfterSettingUpTheWallet: false
            )
        )
    }
}

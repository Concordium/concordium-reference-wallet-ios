//
//  Page.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI
import Combine

enum PageAlert {
    case alert(AlertOptions)
    case error(ViewError)
}

protocol PageModel {
    var navigationTitle: String? { get }
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> { get }
    var alertPublisher: PassthroughSubject<PageAlert, Never> { get }
}

protocol Page: View {
    associatedtype ViewModel: PageModel
    associatedtype PageBody: View
    
    var viewModel: ViewModel { get }
    var pageBody: PageBody { get }
    
    init(viewModel: ViewModel)
}

extension Page {
    var body: some View {
        pageBody
            .withLoadingOverlay(viewModel.isLoadingPublisher)
            .title(viewModel.navigationTitle)
    }
}

private struct LoadingOverlay<P: Publisher>: ViewModifier where P.Output == Bool, P.Failure == Never {
    let isLoadingPublisher: P
    
    @State private var isLoading = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(!isLoading)
            if isLoading {
                VStack {
                    LoadingIndicator()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onReceive(isLoadingPublisher) { isLoading in
            self.isLoading = isLoading
        }
    }
}

private extension View {
    @ViewBuilder
    func title(_ title: String?) -> some View {
        if let title = title {
            if #available(iOS 14.0, *) {
                navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(verbatim: title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                    }
            } else {
                navigationBarTitle(title)
            }
        } else {
            self
        }
    }
    
    func withLoadingOverlay<P: Publisher>(_ publisher: P) -> some View where P.Output == Bool, P.Failure == Never {
        modifier(LoadingOverlay(isLoadingPublisher: publisher))
    }
}

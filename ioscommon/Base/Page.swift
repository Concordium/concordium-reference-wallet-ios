//
//  Page.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

protocol PageModel {
    var navigationTitle: String? { get }
}

protocol Page: View, ViewModelHolder where ViewModel: PageModel {
    associatedtype PageBody: View
    
    var pageBody: PageBody { get }
}

extension Page {
    var body: some View {
        pageBody
            .title(viewModel.navigationTitle)
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
}

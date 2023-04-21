//
//  SelectIdentityView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 23/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SelectIdentityView: Page {
    @ObservedObject var viewModel: SelectIdentityViewModel
    
    var pageBody: some View {
        ScrollView {
            VStack {
                StyledLabel(text: viewModel.title, style: .title)
                    .padding([.top], 60)
                ForEach(viewModel.identities, id: \.nickname) { identity in
                    IdentityCard(viewModel: .init(identity: identity))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.send(.identitySelected(identity))
                        }
                }
            }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
        }
    }
}

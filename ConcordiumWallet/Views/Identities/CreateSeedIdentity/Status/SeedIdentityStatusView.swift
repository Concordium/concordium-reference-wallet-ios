//
//  SeedIdentityStatusView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SeedIdentityStatusView: Page {
    @ObservedObject var viewModel: SeedIdentityStatusViewModel
    
    var pageBody: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SeedIdentityStatusView_Previews: PreviewProvider {
    static var previews: some View {
        SeedIdentityStatusView(
            viewModel: .init()
        )
    }
}

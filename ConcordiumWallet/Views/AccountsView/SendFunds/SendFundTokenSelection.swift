//
//  SendFundTokenSelection.swift
//  Mock
//
//  Created by Milan Sawicki on 01/09/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import Combine

struct SendFundTokenSelection: View {

    let service: CIS2ServiceProtocol
    let address: String
    
    @State var tokens: [CIS2TokenSelectionRepresentable] = []

    var body: some View {
        VStack {
            ForEach(tokens, id: \.self) { token in
                Text(token.name)
            }
        }
        .onAppear {
            tokens = service.getUserStoredCIS2Tokens(for: address)
        }
    }
}

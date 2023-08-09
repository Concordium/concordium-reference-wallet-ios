//
//  TokenLookupView.swift
//  ConcordiumWallet
//

import SwiftUI

struct TokenLookupView: View {
    
    var didTapSearch: ((_ token: String) -> ())?
    @State private var tokenIndex: String = ""
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.gray)
                .frame(width: 62, height: 3)
                .padding(4)

            Text("Enter a contract index to look for tokens.")
            TextField("Contract index", text: $tokenIndex)
                .textFieldStyle(.roundedBorder)
                .padding()
            Spacer()
            Button(action: {
                didTapSearch?(tokenIndex)
            }) {
                Text("Look for tokens")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Pallette.whiteText)
            }
            .background(Pallette.primary)
            .cornerRadius(10)
        }
        .padding()
    }
}

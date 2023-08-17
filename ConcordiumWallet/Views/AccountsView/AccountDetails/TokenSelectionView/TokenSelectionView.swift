//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import SwiftUI

struct TokenSelectionView: View {
    @State var metadata: [CIS2TokenDetails]
    @State private var tokenIndex: String = ""
    var popView: (() -> Void)?
    var body: some View {
        VStack {
            Text("Please select the tokens you want to add from the contract.")
                .multilineTextAlignment(.center)
            TextField("Search for token ID", text: $tokenIndex)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

                .padding()
            ForEach(metadata, id: \.self) { metadata in
                Text(metadata.symbol)
            }
            Spacer()
            HStack(spacing: 16) {
                Button(action: {}) {
                    Text("Back")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)

                Button(action: { popView?() }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct TokenSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TokenSelectionView(metadata: [])
    }
}

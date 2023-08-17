//
//  TokenSelectionView.swift
//  ConcordiumWallet
//

import SDWebImageSwiftUI
import SwiftUI

struct CIS2TokenSelectView: View {
    @State var metadata: [CIS2TokenDetails]
    @State private var tokenIndex: String = ""
    @State var selectedItems: Set<Int> = []
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
                HStack {
                    WebImage(url: metadata.thumbnail?.url)
                        .resizable()
                        .placeholder(Image(systemName: "photo"))
                        .indicator(.activity)
                        .transition(.fade(duration: 0.2))
                        .scaledToFit()
                        .frame(width: 45, height: 45, alignment: .center)
                    Text(metadata.name)
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(Pallette.primary)
                    }
                }
                .padding()
            }
            Spacer()
            HStack(spacing: 16) {
                Button(action: { popView?() }) {
                    Text("Back")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Pallette.primary)
                .cornerRadius(10)
                Button(action: { }) {
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

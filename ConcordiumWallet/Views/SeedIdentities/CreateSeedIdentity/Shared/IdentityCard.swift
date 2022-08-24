//
//  IdentityCard.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 08/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct IdentityCard: View {
    class ViewModel: ObservableObject {
        @Published var index: Int
        @Published var expirationDate: String?
        @Published var image: Image?
        @Published var state: IdentityState
        
        var title: String {
            String(
                format: "identities.seed.shared.identitytitle".localized,
                index
            )
        }
        
        init(
            index: Int = 0,
            expirationDate: String? = nil,
            image: Image? = nil,
            state: IdentityState = .pending
        ) {
            self.index = index
            self.expirationDate = expirationDate
            self.image = image
            self.state = state
        }
        
        init(identity: IdentityDataType) {
            index = identity.index
            state = identity.state
            if let validTo = identity.identityObject?.attributeList.validTo {
                expirationDate = String(
                    format: "identities.seed.shared.expirationdate".localized,
                    GeneralFormatter.formatISO8601Date(date: validTo)
                )
            }
            if let encodedImage = identity.identityProvider?.icon {
                image = Image(uiImage: .decodeBase64(toImage: encodedImage))
            }
        }
        
        func update(with seedIdentity: IdentityDataType) {
            index = seedIdentity.index
            state = seedIdentity.state
            if let validTo = seedIdentity.identityObject?.attributeList.validTo {
                expirationDate = String(
                    format: "identities.seed.shared.expirationdate".localized,
                    GeneralFormatter.formatISO8601Date(date: validTo)
                )
            }
            if let encodedImage = seedIdentity.identityProvider?.icon {
                image = Image(uiImage: .decodeBase64(toImage: encodedImage))
            }
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    let borderColor: Color
    
    var statusImage: String {
        switch viewModel.state {
        case .pending:
            return "pending"
        case .failed:
            return "problem_icon"
        case .confirmed:
            return "ok"
        }
    }
    
    init(viewModel: ViewModel, borderColor: Color = Pallette.text) {
        self.viewModel = viewModel
        self.borderColor = borderColor
    }
    
    var body: some View {
        VStack {
            HStack {
                viewModel.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 17)
                Image(statusImage)
                    .resizable()
                    .frame(width: 17, height: 17)
                    .foregroundColor(Pallette.primary)
                Spacer()
                StyledLabel(text: "Identity", style: .body, weight: .light)
            }
            Spacer()
            StyledLabel(text: viewModel.title, style: .heading)
            Spacer()
            StyledLabel(text: viewModel.expirationDate ?? "", style: .body, color: Pallette.fadedText)
        }
        .frame(height: 200)
        .padding(.init(top: 25, leading: 20, bottom: 25, trailing: 20))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .foregroundColor(borderColor)
        )
    }
}

struct IdentityCard_Previews: PreviewProvider {
    private static let expirationDate: Date = {
        var formatter = DateFormatter()
        formatter.dateFormat = "YYYY-mm-DD"
        
        return formatter.date(from: "2026-09-30") ?? Date()
    }()
    
    static var previews: some View {
        IdentityCard(
            viewModel: .init(
                index: 1,
                expirationDate: "Expires September, 2024",
                image: Image("concordium_title"),
                state: .pending
            )
        )
        
        IdentityCard(
            viewModel: .init(
                index: 2,
                expirationDate: nil,
                image: nil,
                state: .pending
            )
        )
    }
}

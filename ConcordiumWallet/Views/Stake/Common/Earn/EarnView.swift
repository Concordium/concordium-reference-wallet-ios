//
//  EarnView.swift
//  Mock
//
//  Created by Lars Christensen on 21/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct EarnView: Page {
    @ObservedObject var viewModel: EarnViewModel
    
    var pageBody: some View {
        VStack(alignment: .leading) {
            StyledLabel(text: "earn.desc.part1".localized, style: .body, textAlignment: .leading)
                .padding([.top, .horizontal], 16)
            StyledLabel(text: "earn.desc.baking.header".localized, style: .body, weight: .bold, textAlignment: .leading)
                .padding([.top, .horizontal], 16)
            StyledLabel(text: viewModel.bakingText, style: .body, textAlignment: .leading)
                .padding([.horizontal], 16)
            StyledLabel(text: "earn.desc.delegation.header".localized, style: .body, weight: .bold, textAlignment: .leading)
                .padding([.top, .horizontal], 16)
            StyledLabel(text: "earn.desc.delegation.text".localized, style: .body, textAlignment: .leading)
                .padding([.horizontal], 16)
            StyledLabel(text: "earn.desc.part2".localized, style: .body, textAlignment: .leading)
                .multilineTextAlignment(.leading)
                .padding([.top, .horizontal], 16)
            Spacer()
            Button("earn.button.baker".localized) {
                self.viewModel.send(.bakerTapped)
            }
            .applyStandardButtonStyle()
            Button("earn.button.delegation".localized) {
                self.viewModel.send(.delegationTapped)
            }
            .applyStandardButtonStyle()
        }
        .padding(16)
        .onAppear(perform: {
            viewModel.loadMinStake()
        })
    }
}

struct EarnView_Previews: PreviewProvider {
    static var previews: some View {
        EarnView(
            viewModel: .init(account: AccountDataTypeFactory.create())
        )
    }
}

//
//  IdentityBaseInfoWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

typealias ChosenAttributeFormattedTuple = (key: ChosenAttributeKeys, value: String)

struct IdentityDetailsInfoViewModel {
    var nickname: String
    var identityName: String
    var bottomIcon: String
    var bottomLabel: String
    var encodedImage: String
    var bottomIconTintColor: UIColor?

    var data: [ChosenAttributeFormattedTuple]

    init(identity: IdentityDataType) {
        identityName = identity.identityProviderName ?? ""
        nickname = identity.nickname

        switch identity.state {
        case .confirmed:
            //Show expiry date for confirmed state
            bottomLabel = "Expires on " + GeneralFormatter.formatISO8601Date(date: identity.identityObject?.attributeList.validTo ?? "")
            bottomIcon = "ok_icon"
            bottomIconTintColor = .text
        case .pending:
            bottomLabel = "" //"identityStatus.pending".localized
            bottomIcon = "pending"
            bottomIconTintColor = .primary
        case .failed:
            bottomLabel = "identityDetails.identityStatus.failed".localized
            bottomIcon = "problem_icon"
        }
        encodedImage = identity.identityProvider?.icon ?? ""
        data =
            identity.identityObject?.attributeList.chosenAttributes.compactMap { (key, value) in
                guard let attributeKey = ChosenAttributeKeys(rawValue: key) else { return nil }
                return (attributeKey, AttributeFormatter.format(value: value, for: attributeKey))
        } ?? [ChosenAttributeFormattedTuple]()

    }
}

// MARK: View -
protocol IdentityBaseInfoWidgetViewProtocol: class {

}

// MARK: Presenter -
protocol IdentityBaseInfoWidgetPresenterProtocol: class {
    var view: IdentityBaseInfoWidgetViewProtocol? { get set }

    var identityViewModel: IdentityDetailsInfoViewModel { get set }
    
    func format(date: Date) -> String
}

class IdentityBaseInfoWidgetPresenter: IdentityBaseInfoWidgetPresenterProtocol {

    weak var view: IdentityBaseInfoWidgetViewProtocol?

    var identityViewModel: IdentityDetailsInfoViewModel

    init(identity: IdentityDataType) {
        self.identityViewModel = IdentityDetailsInfoViewModel(identity: identity)
    }
    
    func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Expires on " + formatter.string(from: date)
    }
}

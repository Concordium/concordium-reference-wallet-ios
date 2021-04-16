//
//  IdentityInfoViewModel.swift
//  ConcordiumWallet
//
//  Created by Mohamed Ghonemi on 3/19/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

class IdentityInfoViewModel: IdentityGeneralViewModel {
    var state: IdentityState

    convenience init?(identity: IdentityDataType) {

        guard let ipIdentity = identity.identityProvider?.ipInfo?.ipIdentity,
              let name = identity.identityProviderName,
              let icon = identity.identityProvider?.icon
            else {
                return nil
        }

        let attributes = identity.identityObject?.attributeList.chosenAttributes
        let details = attributes?.keys
                .sorted()
                .compactMap(ChosenAttributeKeys.init(rawValue:))
                .map(AttributeFormatter.format)
                .joined(separator: ", ") ?? "identityStatus.\(identity.state.rawValue)".localized

        let expiresOn: String
        if let validTo = identity.identityObject?.attributeList.validTo  {
            expiresOn = "Expires on " + GeneralFormatter.formatISO8601Date(date: validTo)
        } else {
            expiresOn = ""
        }
        
        #warning("no privacy policy url")
        //TODO: add privacy policy
        let privacyPolicyURL = ""
        
        self.init(id: ipIdentity,
                  name: name,
                  iconEncoded: icon,
                  state: identity.state,
                  nickname: identity.nickname,
                  expiresOn: expiresOn,
                  privacyPolicyURL: privacyPolicyURL)
    }

    init(id: Int, name: String, iconEncoded: String, state: IdentityState, nickname: String, expiresOn: String, privacyPolicyURL: String) {
        self.state = state
        super.init(id: id, identityName: name, iconEncoded: iconEncoded, privacyPolicyURL: privacyPolicyURL, nickname: nickname, expiresOn: expiresOn)
    }
}

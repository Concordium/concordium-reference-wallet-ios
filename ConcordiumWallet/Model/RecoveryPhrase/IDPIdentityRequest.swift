//
//  IDPIdentityRequest.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 22/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct IDPIdentityRequest {
    let id: String
    let index: Int
    let identityProvider: IdentityProviderDataType
    let resourceRequest: ResourceRequest
}

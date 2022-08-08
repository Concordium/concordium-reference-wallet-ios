//
//  IDRequestV1.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct IDRequestV1: Codable {
    let idObjectRequest: ObjectWrapper<IDObjectRequest>
    
    struct IDObjectRequest: Codable {
        let idCredPub: String
        let ipArData: [String: IdentityProviderARData]
        let choiceArData: ChoiceArData
        let idCredSecCommitment: String
        let prfKeyCommitmentWithIP: String
        let prfKeySharingCoeffCommitments: [String]
        let proofsOfKnowledge: String
    }
    
    struct IdentityProviderARData: Codable {
        let encPrfKeyShare: String
        let proofComEncEq: String
    }
    
    struct ChoiceArData: Codable {
        let arIdentities: [Int]
        let threshold: Int
    }
}

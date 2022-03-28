//
//  DelegationEntity.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

//let stakedAmount: String?
//let restakeEarnings: Bool?
//let delegationTarget: DelegationTarget?
////let delegatorType: String?
////let bakerID: Int?

import Foundation
import RealmSwift

protocol DelegationDataType: DataStoreProtocol {
    var stakedAmount: String { get set}
    var restakeEarnings: Bool { get set}
    var delegationTargetType: String { get set}
    var delegationTargetBakerID: Int { get set}
}

final class DelegationEntity: Object {
    @objc dynamic var stakedAmount: String = ""
    @objc dynamic var restakeEarnings: Bool = false
    @objc dynamic var delegationTargetType: String = ""
    @objc dynamic var delegationTargetBakerID: Int = -1
    
    convenience init(accountDelegationModel: AccountDelegation) {
        self.init()
        self.stakedAmount = accountDelegationModel.stakedAmount
        self.restakeEarnings = accountDelegationModel.restakeEarnings
        self.delegationTargetType = accountDelegationModel.delegationTarget.delegateType
        self.delegationTargetBakerID = accountDelegationModel.delegationTarget.bakerID ?? -1
    }
}

extension DelegationEntity: DelegationDataType {
}

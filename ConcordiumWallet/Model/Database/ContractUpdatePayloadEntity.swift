//
//  ContractUpdatePayloadEntity.swift
//  ConcordiumWallet
//

import Foundation
import RealmSwift

final class ContractUpdatePayloadEntity: Object {
    @objc dynamic var amount: String = ""
    @objc dynamic var index: Int = 0
    @objc dynamic var subindex: Int = 0
    @objc dynamic var receiveName: String = ""
    @objc dynamic var maxContractExecutionEnergy: Int = 0
    @objc dynamic var message: String = ""

    convenience init(from payload: ContractUpdatePayload) {
        self.init()
        amount = payload.amount
        index = payload.address.index
        subindex = payload.address.subindex
        receiveName = payload.receiveName
        maxContractExecutionEnergy = payload.maxContractExecutionEnergy
        message = payload.message
    }
}

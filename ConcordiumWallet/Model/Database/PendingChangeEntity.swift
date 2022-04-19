//
//  PendingChangeEntity.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 01/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol PendingChangeDataType: DataStoreProtocol {
    var change: AccountPendingChangeType { get set}
    var updatedNewStake: String? { get set}
    var effectiveTime: String? { get set}
}

final class PendingChangeEntity: Object {
    @objc dynamic var changeString = ""
    @objc dynamic var updatedNewStake: String?
    @objc dynamic var effectiveTime: String?
    
    convenience init?(pendingChange: PendingChange?) {
        self.init()
        guard let pendingChange = pendingChange else {
            return
        }
        changeString = pendingChange.change
        updatedNewStake = pendingChange.newStake
        effectiveTime = pendingChange.effectiveTime
    }
}

extension PendingChangeEntity: PendingChangeDataType {
    
    var change: AccountPendingChangeType {
        get {
            AccountPendingChangeType(rawValue: changeString) ?? .NoChange
        }
        set {
            changeString = newValue.rawValue
        }
    }
    
}

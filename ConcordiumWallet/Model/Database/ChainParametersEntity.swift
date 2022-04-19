//
//  ChainParametersEntity.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 31/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol ChainParametersDataType: DataStoreProtocol {
    var delegatorCooldown: Int { get set}
    var poolOwnerCooldown: Int { get set}
}

final class ChainParametersEntity: Object {
    @objc dynamic var delegatorCooldown: Int = -1
    @objc dynamic var poolOwnerCooldown: Int = -1
    
    convenience init(delegatorCooldown: Int, poolOwnerCooldown: Int) {
        self.init()
        self.delegatorCooldown = delegatorCooldown
        self.poolOwnerCooldown = poolOwnerCooldown
    }
}

extension ChainParametersEntity: ChainParametersDataType {
    
    func with(delegatorCooldown: Int, poolOwnerCooldown: Int) -> ChainParametersDataType {
        _ = write {
            let chainParams = $0
            chainParams.delegatorCooldown = delegatorCooldown
            chainParams.poolOwnerCooldown = poolOwnerCooldown
        }
        return self
    }
}

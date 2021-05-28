//
//  TransferFiltersEntity.swift
//  ConcordiumWallet
//
//  Created by Concordium on 02/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol TransferFilterDataType: DataStoreProtocol {
    var showRewardTransactions: Bool { get set }
    var showFinalRewardTransactions: Bool { get set }
}

final class TransferFilter: Object {
    @objc dynamic var showRewardTransactions: Bool = true
    @objc dynamic var showFinalRewardTransactions: Bool = true
 
    convenience init(showRewards: Bool, showFinalRewards: Bool) {
        self.init()
        self.showRewardTransactions = showRewards
        self.showFinalRewardTransactions = showFinalRewards
    }
}

extension TransferFilter: TransferFilterDataType {
}

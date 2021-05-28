//
//  EncryptedBalance.swift
//  ConcordiumWallet
//
//  Concordium on 21/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol EncryptedBalanceDataType: DataStoreProtocol {
    var incomingAmounts: [String] { get set }
    var selfAmount: String? { get set }
    var startIndex: Int { get set }
    var numAggregated: Int { get set }

     init(accountEncryptedAmount: AccountEncryptedAmount?)
    
}

final class EncryptedBalanceEntity: Object {
  
    var incomingAmountList = List<String>()
    @objc dynamic var selfAmount: String? = ""
    @objc dynamic var startIndex: Int = 0
    @objc dynamic var numAggregated: Int = 0
    
    convenience init(accountEncryptedAmount: AccountEncryptedAmount?) {
        self.init()
        self.selfAmount = accountEncryptedAmount?.selfAmount
        self.incomingAmounts = accountEncryptedAmount?.incomingAmounts ?? []
        self.startIndex = accountEncryptedAmount?.startIndex ?? 0
        self.numAggregated = accountEncryptedAmount?.numAggregated ?? 0
    }
}

extension EncryptedBalanceEntity: EncryptedBalanceDataType {

    var incomingAmounts: [String] {
        get {
            incomingAmountList.map { (elem) -> String in
                elem
            }
        }
        set {
            incomingAmountList.removeAll()
            incomingAmountList.append(objectsIn: newValue)
        }
    }
}

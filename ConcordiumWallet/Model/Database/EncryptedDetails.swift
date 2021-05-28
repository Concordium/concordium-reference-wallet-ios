//
//  EncryptedDetails.swift
//  ConcordiumWallet
//
//  Concordium on 21/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol EncryptedDetailsDataType: DataStoreProtocol {
//    var encryptedAmount: String? { get set }
    var updatedNewSelfEncryptedAmount: String? { get set }
    var updatedNewStartIndex: Int { get set }

    init(encrypted: Encrypted?)
}

final class EncryptedDetailsEntity: Object {
//    @objc dynamic var encryptedAmount: String? = ""
    @objc dynamic var updatedNewSelfEncryptedAmount: String? = ""
    @objc dynamic var updatedNewStartIndex: Int = 0

    convenience init(encrypted: Encrypted?) {
        self.init()
//        self.encryptedAmount = encrypted?.encryptedAmount
        self.updatedNewSelfEncryptedAmount = encrypted?.newSelfEncryptedAmount
        self.updatedNewStartIndex = encrypted?.newStartIndex ?? 0
     
    }
    convenience init(newSelfEncryptedAmount: String, newStartIndex: Int?) {
        self.init()
        self.updatedNewSelfEncryptedAmount = newSelfEncryptedAmount
        self.updatedNewStartIndex = newStartIndex ?? 0
    }
    
}

extension EncryptedDetailsEntity: EncryptedDetailsDataType {
}

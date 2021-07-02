//
//  ScheduleEntity.swift
//  ConcordiumWallet
//
//  Concordium on 23/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol ScheduleDataType: DataStoreProtocol {
    var transactions: [String] { get set }
    var amount: String? { get set }
    var timestamp: Int { get set }
    
}

final class ScheduleEntity: Object {
    var transactionList = List<String>()
    @objc dynamic var amount: String? = ""
    @objc dynamic var timestamp: Int = 0
    
    convenience init(transactionList: List<String>, amount: String?, timestamp: Int) {
        self.init()
        self.transactionList = transactionList
        self.amount = amount
        self.timestamp = timestamp
    }
}

extension ScheduleEntity: ScheduleDataType {

    var transactions: [String] {
        get {
            transactionList.map { (elem) -> String in
                elem
            }
        }
        set {
            transactionList.removeAll()
            transactionList.append(objectsIn: newValue)
        }
    }
}

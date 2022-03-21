//
// Created by Concordium on 02/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift
protocol TransactionType {
}
extension Transaction: TransactionType {}

extension Transaction {
    func getTotalForShielded() -> Int? {
        if details.type == "transferToEncrypted" || details.type == "transferToPublic"{
            return -(Int(subtotal ?? "0") ?? 0)
        }
        return nil
    }
}

protocol TransferDataType: DataStoreProtocol, TransactionType {
    var amount: String { get set }
    var fromAddress: String {get set }
    var toAddress: String { get set }
    var expiry: Date { get set }
    var createdAt: Date { get set }
    var submissionId: String? { get set }
    var transactionStatus: SubmissionStatusEnum? { get set }
    var outcome: OutcomeEnum? { get set }
    var cost: String { get set }
    var energy: Int { get set }
    var transferType: TransferType { get set }
    var encryptedDetails: EncryptedDetailsDataType? { get set }
    var nonce: Int { get set}
    var memo: String? { get set }
    
    func getPublicBalanceChange() -> Int
    func getShieldedBalanceChange() -> Int
    func withUpdated(cost: String?, status: SubmissionStatusEnum, outcome: OutcomeEnum?) -> TransferDataType
}

extension TransferDataType {
    func getPublicBalanceChange() -> Int {
        if .absent == transactionStatus {
            return 0
        }

        let balanceChange: Int
        switch outcome {
        case .reject:
            balanceChange = Int(cost) ?? 0
        default:
            switch transferType {
            case .simpleTransfer, .transferToSecret: // transfer to public is included even if not finalized
                balanceChange = (Int(amount) ?? 0) + (Int(cost) ?? 0)
            case .transferToPublic:
                balanceChange = -(Int(amount) ?? 0) + (Int(cost) ?? 0)
            case .encryptedTransfer:
                balanceChange = (Int(cost) ?? 0)
            case .registerDelegation, .removeDelegation, .updateDelegation:
                balanceChange = 0
            case .registerBaker, .updateBakerKeys, .updateBakerPool, .updateBakerStake, .removeBaker:
                balanceChange = 0
            }
        }
        
        return -balanceChange
    }
    
    func getShieldedBalanceChange() -> Int {
        if .absent == transactionStatus {
            return 0
        }
        let balanceChange: Int
        switch outcome {
        case .reject:
            balanceChange = 0
        default:
            
            switch transferType {
            case .simpleTransfer:
                balanceChange = 0
            case .transferToSecret:
                balanceChange = -(Int(amount) ?? 0)// shielding is included even if not finalized
            case .encryptedTransfer, .transferToPublic:
                balanceChange = (Int(amount) ?? 0) + 0 // the cost is taken from the public balance
            case .registerDelegation, .removeDelegation, .updateDelegation:
                balanceChange = 0
            case .registerBaker, .updateBakerKeys, .updateBakerPool, .updateBakerStake, .removeBaker:
                balanceChange = 0
            }
            
        }
        return -balanceChange
    }
    
    func withUpdated(cost: String?, status: SubmissionStatusEnum, outcome: OutcomeEnum?) -> TransferDataType {
        _ = write {
            var transfer = $0
            transfer.cost = cost ?? transfer.cost
            transfer.transactionStatus = status
            transfer.outcome = outcome
        }
        return self
    }
}

struct TransferDataTypeFactory {
    static func create() -> TransferDataType {
        TransferEntity()
    }
}

final class TransferEntity: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var amount = "0"
    @objc dynamic var fromAddress = ""
    @objc dynamic var toAddress = ""
    @objc dynamic var expiry: Date = Date()
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var submissionId: String? = ""
    @objc dynamic var transactionStatusString: String? = ""
    @objc dynamic var transferTypeString: String = ""
    @objc dynamic var outcomeString: String? = ""
    @objc dynamic var memo: String?
    @objc dynamic var cost: String = "0"
    @objc dynamic var energy: Int = 0
    @objc dynamic var encryptedDetailsEntity: EncryptedDetailsEntity?
    @objc dynamic var nonce: Int = 0
}

extension TransferEntity: TransferDataType {
    var encryptedDetails: EncryptedDetailsDataType? {
        get {
            encryptedDetailsEntity
        }
        set {
            self.encryptedDetailsEntity = newValue as? EncryptedDetailsEntity
        }
    }
    
    var transactionStatus: SubmissionStatusEnum? {
        get {
            SubmissionStatusEnum(rawValue: transactionStatusString ?? "")
        }
        set {
            transactionStatusString = newValue?.rawValue
        }
    }
    
    var transferType: TransferType {
        get {
            TransferType(rawValue: transferTypeString) ?? .simpleTransfer
        }
        set {
            transferTypeString = newValue.rawValue
        }
    }
    
    var outcome: OutcomeEnum? {
        get {
            OutcomeEnum(rawValue: outcomeString ?? "")
        }
        set {
            outcomeString = newValue?.rawValue
        }
    }
}

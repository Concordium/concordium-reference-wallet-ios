//
// Created by Concordium on 27/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

enum IdentityState: String {
    case confirmed
    case pending
    case failed
}

protocol IdentityDataType: DataStoreProtocol {
    var identityProvider: IdentityProviderDataType? { get set }
    var identityObject: IdentityObject? { get set }
    var encryptedPrivateIdObjectData: String? { get set }
    var accountsCreated: Int { get set }
    var identityProviderName: String? { get }
    var nickname: String { get set }
    var state: IdentityState { get set }
    var ipStatusUrl: String { get set }
    var hashedIpStatusUrl: String? { get }
    var identityCreationError: String { get set }
}

extension IdentityDataType {
    func withUpdated(identityObject: IdentityObject) -> IdentityDataType {
        _ = write {
            var identity = $0
            identity.identityObject = identityObject
            identity.state = .confirmed
        }
        return self
    }

    func withUpdated(identityCreationError: String) -> IdentityDataType {
        _ = write {
            var identity = $0
            identity.identityCreationError = identityCreationError
            identity.state = .failed
        }
        return self
    }
    
    func withUpdated(state: IdentityState, pollUrl: String) -> IdentityDataType {
        _ = write {
            var identity = $0
            identity.state = state
            identity.ipStatusUrl = pollUrl
        }
        return self
    }
    
    func withUpdated(accountsCreated: Int) -> IdentityDataType {
        _ = write {
            var identity = $0
            identity.accountsCreated = accountsCreated
        }
        return self
    }
    
    func withUpdated(identityProvider: IdentityProviderDataType) -> IdentityDataType {
        _ = write {
            var identity = $0
            identity.identityProvider = identityProvider
        }
        return self
    }
    func withUpdated(encryptedPrivateIdObjectData: String) -> IdentityDataType {
        _ = write {
            var identity = $0
            identity.encryptedPrivateIdObjectData = encryptedPrivateIdObjectData
        }
        return self
    }
    
}

struct IdentityDataTypeFactory {
    static func create() -> IdentityDataType {
        IdentityEntity()
    }
}

final class IdentityEntity: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var identityProviderEntity: IdentityProviderEntity? = IdentityProviderEntity()
    @objc dynamic var identityObjectJson: String = ""
    @objc dynamic var encryptedPrivateIdObjectData: String? = ""
    @objc dynamic var accountsCreated = 1
    @objc dynamic var nickname: String = ""
    @objc dynamic var ipStatusUrl: String = ""
    @objc dynamic var stateString: String = IdentityState.pending.rawValue
    @objc dynamic var identityCreationError: String = ""
}

extension IdentityEntity: IdentityDataType {
    var hashedIpStatusUrl: String? { HashingHelper.hash(ipStatusUrl) }
    
    var identityProvider: IdentityProviderDataType? {
        get { identityProviderEntity }
        set { self.identityProviderEntity = newValue as? IdentityProviderEntity }
    }
    
    var identityObject: IdentityObject? {
        get {
            try? IdentityObject(identityObjectJson)
        }
        set {
            guard let jsonData = try? newValue?.jsonString() else {return}
            self.identityObjectJson = jsonData
        }
    }
    
    var identityProviderName: String? {
        identityProvider?.ipInfo?.ipDescription.name
    }

    var state: IdentityState {
        get {
            IdentityState(rawValue: stateString) ?? .confirmed
        }
        set {
            stateString = newValue.rawValue
        }
    }
}

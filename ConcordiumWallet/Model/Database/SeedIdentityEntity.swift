//
//  SeedIdentityEntity.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import RealmSwift

enum SeedIdentityState: String {
    case confirmed
    case pending
    case failed
}

protocol SeedIdentityDataType: DataStoreProtocol {
    var identityProvider: IdentityProviderDataType? { get set }
    var identityObject: SeedIdentityObject? { get set }
    var encryptedPrivateIdObjectData: String? { get set }
    var accountsCreated: Int { get set }
    var identityProviderName: String? { get }
    var index: Int { get }
    var state: SeedIdentityState { get set }
    var ipStatusUrl: String { get set }
    var hashedIpStatusUrl: String? { get }
    var identityCreationError: String { get set }
}

extension SeedIdentityDataType {
    func withUpdated(identityObject: SeedIdentityObject) -> SeedIdentityDataType {
        _ = write {
            var identity = $0
            identity.identityObject = identityObject
            identity.state = .confirmed
        }
        return self
    }

    func withUpdated(identityCreationError: String) -> SeedIdentityDataType {
        _ = write {
            var identity = $0
            identity.identityCreationError = identityCreationError
            identity.state = .failed
        }
        return self
    }
    
    func withUpdated(state: SeedIdentityState, pollUrl: String) -> SeedIdentityDataType {
        _ = write {
            var identity = $0
            identity.state = state
            identity.ipStatusUrl = pollUrl
        }
        return self
    }
    
    func withUpdated(accountsCreated: Int) -> SeedIdentityDataType {
        _ = write {
            var identity = $0
            identity.accountsCreated = accountsCreated
        }
        return self
    }
    
    func withUpdated(identityProvider: IdentityProviderDataType) -> SeedIdentityDataType {
        _ = write {
            var identity = $0
            identity.identityProvider = identityProvider
        }
        return self
    }
    func withUpdated(encryptedPrivateIdObjectData: String) -> SeedIdentityDataType {
        _ = write {
            var identity = $0
            identity.encryptedPrivateIdObjectData = encryptedPrivateIdObjectData
        }
        return self
    }
    
}

struct SeedIdentityDataTypeFactory {
    static func create(index: Int) -> SeedIdentityDataType {
        let entity = SeedIdentityEntity()
        entity.index = index
        return entity
    }
}

final class SeedIdentityEntity: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var identityProviderEntity: IdentityProviderEntity? = IdentityProviderEntity()
    @objc dynamic var identityObjectJson: String = ""
    @objc dynamic var encryptedPrivateIdObjectData: String? = ""
    @objc dynamic var accountsCreated = 1
    @objc dynamic var index: Int = -1
    @objc dynamic var ipStatusUrl: String = ""
    @objc dynamic var stateString: String = SeedIdentityState.pending.rawValue
    @objc dynamic var identityCreationError: String = ""
}

extension SeedIdentityEntity: SeedIdentityDataType {
    var hashedIpStatusUrl: String? { HashingHelper.hash(ipStatusUrl) }
    
    var identityProvider: IdentityProviderDataType? {
        get { identityProviderEntity }
        set { self.identityProviderEntity = newValue as? IdentityProviderEntity }
    }
    
    var identityObject: SeedIdentityObject? {
        get {
            try? SeedIdentityObject.decodeFromSring(identityObjectJson)
        }
        set {
            guard let jsonData = try? newValue?.encodeToString() else {return}
            self.identityObjectJson = jsonData
        }
    }
    
    var identityProviderName: String? {
        identityProvider?.ipInfo?.ipDescription.name
    }

    var state: SeedIdentityState {
        get {
            SeedIdentityState(rawValue: stateString) ?? .confirmed
        }
        set {
            stateString = newValue.rawValue
        }
    }
}

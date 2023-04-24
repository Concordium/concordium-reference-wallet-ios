//
// Created by Concordium on 31/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol IdentityProviderDataType: AnyObject {
    var ipInfo: IPInfo? { get set }
    var arsInfos: [String: ArsInfo]? { get set }
    var icon: String { get set }
    var issuanceStartURL: String { get set }
    var recoveryStartURL: String? { get set }
    var support: String? { get set }
    init(ipData: IPInfoResponseElement)
}

struct IdentityProviderDataTypeFactory {
    static func create(ipData: IPInfoResponseElement) -> IdentityProviderDataType {
        IdentityProviderEntity(ipData: ipData)
    }
}

class IdentityProviderEntity: Object {
    @objc dynamic var ipInfoJson: String = ""
    @objc dynamic var arsInfosJson: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var issuanceStartURL: String = ""
    @objc dynamic var recoveryStartURL: String?
    @objc dynamic var support: String? = ""

    required convenience init(ipData: IPInfoResponseElement) {
        self.init()
        self.ipInfo = ipData.ipInfo
        self.arsInfos = ipData.arsInfos
        self.icon = ipData.metadata.icon
        self.issuanceStartURL = ipData.metadata.issuanceStart
        self.recoveryStartURL = ipData.metadata.recoveryStart
        self.support = ipData.metadata.support
    }
}

extension IdentityProviderEntity: IdentityProviderDataType {
    var ipInfo: IPInfo? {
        get {
            try? IPInfo(ipInfoJson)
        }
        set {
            guard let ipInfoJson = try? newValue?.jsonString() else {return}
            self.ipInfoJson = ipInfoJson
        }
    }
    
    var arsInfos: [String: ArsInfo]? {
        get {
            guard let data = arsInfosJson.data(using: .utf8) else { return nil }
            let decoded = try? JSONDecoder().decode([String: ArsInfo].self, from: data)
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            self.arsInfosJson = String(data: encoded, encoding: .utf8) ?? ""
        }
    }
}

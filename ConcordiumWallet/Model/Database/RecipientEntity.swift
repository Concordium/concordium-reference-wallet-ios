//
// Created by Johan Rugager Vase on 27/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol RecipientDataType {
    var name: String { get set }
    var address: String { get set }
}

struct RecipientDataTypeFactory {
    static func create() -> RecipientDataType {
        RecipientEntity()
    }
}

class RecipientEntity: Object, RecipientDataType {
    @objc dynamic var name: String = ""
    @objc dynamic var address: String = ""

    convenience init(name: String, address: String) {
        self.init()
        self.name = name
        self.address = address
    }
}

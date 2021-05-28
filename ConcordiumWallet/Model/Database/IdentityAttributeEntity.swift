//
// Created by Concordium on 01/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

class IdentityAttributeEntity: Object {
    @objc dynamic var name = ""
    @objc dynamic var value = ""

    convenience init(name: String, value: String) {
        self.init()
        self.name = name
        self.value = value
    }
}

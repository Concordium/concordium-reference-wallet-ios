//
// Created by Concordium on 27/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol RecipientDataType {
    var name: String { get set }
    var address: String { get set }
    func displayName() -> String
}

extension RecipientDataType {
    func displayName() -> String {
        if name.isEmpty {
            let lowerBound = address.startIndex
            let upperBound = address.index(lowerBound, offsetBy: 8)
            return "<" + String(address[lowerBound..<upperBound]) + ">"
        } else {
            return name
        }
    }
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

//
// Created by Concordium on 01/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol DataStoreProtocol {
    func write(code: (Self) -> Void) -> Result<Void, Error>
}

extension DataStoreProtocol where Self: Object {
    func write(code: (Self) -> Void) -> Result<Void, Error> {
        do {
            let realm = try Realm(configuration: RealmHelper.realmConfiguration)
            try realm.write {
                code(self)
            }
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
}

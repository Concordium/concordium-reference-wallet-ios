//
//  RealmHelper.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 15/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import RealmSwift
import Foundation

struct RealmHelper {
    
    // Set the new schema version. This must be greater than the previously used
    // version (if you've never set a schema version before, the version is 0).
    private static let schemaVersion: UInt64 = 23

    static let realmConfiguration = Realm.Configuration(
        schemaVersion: schemaVersion,

        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { _, oldSchemaVersion in
            if oldSchemaVersion < schemaVersion {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })
    
    //Used to expose generic
    static func DetachedCopy<T:Codable>(of object:T) -> T?{
        do{
            let json = try JSONEncoder().encode(object)
            return try JSONDecoder().decode(T.self, from: json)
        }
        catch let error{
            print(error)
            return nil
        }
    }
}

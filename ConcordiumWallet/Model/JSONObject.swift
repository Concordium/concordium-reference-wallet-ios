//
//  JSONObject.swift
//  ConcordiumWallet
//
//  Created by Concordium on 28/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

struct JSONObject: Codable, Hashable {
    typealias JSONDictionary = [String: AnyHashable]

    let dictionary: JSONDictionary

    private struct Key: CodingKey {

        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(dictionary: JSONDictionary) {
        self.dictionary = dictionary
    }

    init(from decoder: Decoder) throws {
        let con = try decoder.container(keyedBy: Key.self)
        var dict = [String: AnyHashable]()
        for key in con.allKeys {
            if let value = try? con.decode(String.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? con.decode(Int.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? con.decode([Int].self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? con.decode(Double.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let value = try? con.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = value
            } else if let data = try? con.decode(JSONObject.self, forKey: key) as JSONObject {
                dict[key.stringValue] = data.dictionary
            } else if let data = try? con.decode([JSONObject].self, forKey: key) as [JSONObject] {
                dict[key.stringValue] = data
            } else {
                Logger.warn("JSON Object failed decoding for key \(key)")
            }

        }
        self.dictionary = dict
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        for key in self.dictionary.keys {
            let value = dictionary[key]
            if let value = value as? [Int] {
                try container.encode(value, forKey: Key(stringValue: key)!)
            } else if let value = value as? String {
                try container.encode(value, forKey: Key(stringValue: key)!)
            } else if let value = value as? Int {
                try container.encode(value, forKey: Key(stringValue: key)!)
            } else if let value = value as? Double {
                try container.encode(value, forKey: Key(stringValue: key)!)
            } else if let value = value as? Bool {
                try container.encode(value, forKey: Key(stringValue: key)!)
            } else if let value = value as? JSONDictionary {
                try container.encode(JSONObject(dictionary: value), forKey: Key(stringValue: key)!)
            } else if let value = value as? [JSONObject] {
                try container.encode(value, forKey: Key(stringValue: key)!)
            } else {
                Logger.warn("JSON Object failed encoding for key \(key) value \(value)")
            }
        }
    }
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

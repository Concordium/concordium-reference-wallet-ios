import Foundation
import RealmSwift
/// Response object containg detaile information about token metadata.
/// - Remark: Decoded as result for request to ``CIS2TokensMetadataItem.metadataURL``

struct CIS2TokenMetadataDetails: Codable, Hashable {
    let name: String
    let symbol: String?
    let decimals: Int?
    let description: String
    let thumbnail: ImageData?
    let unique: Bool?
    struct ImageData: Codable, Hashable, Equatable {
        let url: URL?
    }
    
    init(from entity: CIS2TokenMetadataDetailsEntity) {
        self.name = entity.name
        self.symbol = entity.symbol
        self.decimals = entity.decimals
        self.description = entity.metadataDescription
        self.unique = entity.unique
        if let urlString = entity.thumbnail, let url = URL(string: urlString) {
            self.thumbnail = .init(url: url)
        } else {
            self.thumbnail = nil
        }
    }
}

final class CIS2TokenMetadataDetailsEntity: Object {
    @Persisted(primaryKey: true) var url: String
    @Persisted var name: String = ""
    @Persisted var symbol: String? = nil
    @Persisted var decimals: Int? = nil
    @Persisted var metadataDescription: String = ""
    @Persisted var thumbnail: String? = nil
    @Persisted var unique: Bool? = nil

    convenience init(
        with metadata: CIS2TokenMetadataDetails
    ) {
        self.init()
        self.name = metadata.name
        self.symbol = metadata.symbol
        self.decimals = metadata.decimals
        self.metadataDescription = metadata.description
        self.thumbnail = metadata.thumbnail?.url?.absoluteString
        self.unique = metadata.unique
    }
}

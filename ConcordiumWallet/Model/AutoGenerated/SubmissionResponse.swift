// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let submissionResponse = try SubmissionResponse(json)

import Foundation

// MARK: - SubmissionResponse
struct SubmissionResponse: Codable {
    let submissionID: String

    enum CodingKeys: String, CodingKey {
        case submissionID = "submissionId"
    }
}

// MARK: SubmissionResponse convenience initializers and mutators

extension SubmissionResponse {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SubmissionResponse.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        submissionID: String? = nil
    ) -> SubmissionResponse {
        return SubmissionResponse(
            submissionID: submissionID ?? self.submissionID
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

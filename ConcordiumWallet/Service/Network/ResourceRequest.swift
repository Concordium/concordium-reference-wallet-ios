import Foundation

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

struct ResourceRequest {
    let url: URL
    let parameters: [String: CustomStringConvertible?]
    let httpMethod: HttpMethod
    let body: Data?

    var request: URLRequest? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = parameters.keys.map { key in
            URLQueryItem(name: key, value: parameters[key]??.description)
        }
        guard let url = components.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue

        urlRequest.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: CookieJar.cookies)

        let DeviceLanguageCode = NSLocale.current.identifier
        urlRequest.setValue(DeviceLanguageCode, forHTTPHeaderField: "Accept-Language")
        
        // add headers for the request
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        if let body = body {
            urlRequest.httpBody = body
        }

        // urlRequest.log()
        
        return urlRequest
    }

    init(url: URL, httpMethod: HttpMethod = .get, parameters: [String: CustomStringConvertible?] = [:], body: Data? = nil) {
        self.url = url
        self.parameters = parameters
        self.httpMethod = httpMethod
        self.body = body
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension URLRequest {
    func log() {
        print("\(httpMethod ?? "") \(self)")
        print("BODY \n \(httpBody?.toString() ?? "")")
        print("HEADERS \n \(allHTTPHeaderFields ?? [:])")
    }
}

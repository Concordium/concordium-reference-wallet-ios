//
//  URLProtocolMock.swift
//  MOCK ConcordiumWallet
//
//  Created by Johan Rugager Vase on 20/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

class NetworkSessionMock: NetworkSession {
    /***
       Instead of returning mock objects, setting this to true will fall the server and the
       overwrite local mock json files with the returned data from the server
     */
    let overwriteMockFilesWithServerData = false

    let urlMapping = [ApiConstants.ipInfo: "1.1.2.RX-backend_identity_provider_info",
                      ApiConstants.global: "2.1.2.RX-backend_global",
                      ApiConstants.submitCredential: "2.3.2.RX_backend_submitCredential",
                      ApiConstants.submissionStatus: "2.4.2.RX_backend_submissionStatus",
                      ApiConstants.accNonce: "3.1.2.RX_backend_accNonce",
                      ApiConstants.transferCost: "2.5.2.RX_backend_transferCost",
                      ApiConstants.submitTransfer: "3.3.2.RX_backend_submitTransfer",
                      ApiConstants.accountTransactions: "4.2.2.RX_backend_accTransactions_mock"]

    func load(request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        if overwriteMockFilesWithServerData {return loadFromServerAndOverwriteWithReceivedData(request: request)}
        if let url = request.url,
           let (data, returnCode) = loadFile(for: url),
           let urlResponse: URLResponse = HTTPURLResponse(url: request.url!, statusCode: returnCode, httpVersion: nil, headerFields: nil) {
            Logger.debug("mock returning \(String(data: data, encoding: .utf8)?.prefix(50) ?? "")")
            return .just((data, urlResponse))
        } else {
            return .fail(URLError(.fileDoesNotExist))
        }
    }

    func loadFile(for url: URL) -> (Data, Int)? {
        if let path = Bundle.main.path(forResource: getFilename(for: url), ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                if path.contains("error") {
                    return (jsonData as Data, 400)
                }
                return (jsonData as Data, 200)
            }
        }
        return nil
    }

    //swiftlint:disable:next cyclomatic_complexity
    func getFilename(for url: URL) -> String {
//        if url.absoluteString.hasPrefix(ApiConstants.submitCredential.absoluteString) {
//            return "backend_server_error"
//            return "backend_invalidRequest_error"
//        }
        if url.absoluteString.hasPrefix(ApiConstants.submissionStatus.absoluteString) {
            let submissionId = url.lastPathComponent
            switch submissionId {
            case "a01": 
                return "2.4.2.RX_backend_submissionStatus_success"
            case "a02": 
                return "2.4.2.RX_backend_submissionStatus_received"
            case "a03": 
                return "2.4.2.RX_backend_submissionStatus_committed"
            case "a04": 
                return "2.4.2.RX_backend_submissionStatus_absent"
            case "t01": 
                return "3.4.2.RX_backend_submissionStatus_rec"
            case "t02": 
                return "3.4.2.RX_backend_submissionStatus_com"
            case "t03": 
                return "3.4.2.RX_backend_submissionStatus_com_amb"
            case "t04": 
                return "3.4.2.RX_backend_submissionStatus_com_reject"
            case "t05": 
                return "3.4.2.RX_backend_submissionStatus_abs"
            case "t06": 
                return "3.4.2.RX_backend_submissionStatus_fin"
            case "t07": 
                return "3.4.2.RX_backend_submissionStatus_fin_reject"
            default:
                return "2.4.2.RX_backend_submissionStatus_success"
            }
        }
        for key in urlMapping.keys {
            if url.absoluteString.hasPrefix(key.absoluteString) {
                return urlMapping[key]!
            }
        }
        return ""
    }
}

extension NetworkSessionMock { //Methods for overwriting data instead of returning the mocked data
    private func loadFromServerAndOverwriteWithReceivedData(request: URLRequest)
                    -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        URLSession.shared.dataTaskPublisher(for: request).handleEvents(receiveOutput: { (data, _) in
            if let url = request.url,
               let path = Bundle.main.url(forResource: self.getOverwriteFilename(for: url), withExtension: "json") {
                Logger.info("Writing to \(path)")
                try? data.write(to: path)
            }
        }).eraseToAnyPublisher()
    }

    func getOverwriteFilename(for url: URL) -> String {
        for key in urlMapping.keys {
            if url.absoluteString.hasPrefix(key.absoluteString) {
                return urlMapping[key]!
            }
        }
        return ""
    }
}

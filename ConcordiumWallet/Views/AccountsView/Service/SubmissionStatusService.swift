//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SubmissionStatusService {
    var networkManager: NetworkManagerProtocol { get }
    func submissionStatus(submissionId: String) -> AnyPublisher<SubmissionStatus, Error>
}

extension SubmissionStatusService {
    func submissionStatus(submissionId: String) -> AnyPublisher<SubmissionStatus, Error> {
        networkManager.load(ResourceRequest(url: ApiConstants.submissionStatus.appendingPathComponent(submissionId)))
    }
}

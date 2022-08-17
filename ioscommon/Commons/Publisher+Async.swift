//
//  Publisher+Async.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 12/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

struct MissingOutput: Error {}

extension Publisher {
    func awaitFirst() async throws -> Output {
        return try await withCheckedThrowingContinuation { continuation in
            let subscriber = AwaitFirstSubscriber<Output, Failure>(continuation: continuation)
            
            self.first().subscribe(subscriber)
        }
    }
}

private class AwaitFirstSubscriber<Input, Failure: Error>: Subscriber {
    private var continuation: CheckedContinuation<Input, Error>?
    
    init(continuation: CheckedContinuation<Input, Error>) {
        self.continuation = continuation
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        if let continuation = continuation {
            continuation.resume(returning: input)
            self.continuation = nil
        }
        
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        if let continuation = continuation {
            switch completion {
            case let .failure(error):
                continuation.resume(throwing: error)
            case .finished:
                continuation.resume(throwing: MissingOutput())
            }
            self.continuation = nil
        }
    }
}

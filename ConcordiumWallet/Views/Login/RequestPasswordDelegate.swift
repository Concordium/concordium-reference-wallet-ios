//
// Created by Concordium on 07/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine
import UIKit

protocol RequestPasswordDelegate: AnyObject {
    func requestUserPassword(keychain: KeychainWrapperProtocol) -> AnyPublisher<String, Error>
}

extension RequestPasswordDelegate {
    @MainActor
    func requestUserPassword(keychain: KeychainWrapperProtocol) async throws -> String {
        return try await requestUserPassword(keychain: keychain).awaitFirst()
    }
}

extension RequestPasswordDelegate where Self: Coordinator {
    func requestUserPassword(keychain: KeychainWrapperProtocol) -> AnyPublisher<String, Error> {
        let requestPasswordPresenter = RequestPasswordPresenter(keychain: keychain)
        var modalPasswordVCShown = false

        let enterPasswordController = EnterPasswordFactory.create(with: requestPasswordPresenter)
        let enterPasswordTransparentController = TransparentNavigationController()
        enterPasswordTransparentController.modalPresentationStyle = .fullScreen
        enterPasswordTransparentController.viewControllers = [enterPasswordController]

        requestPasswordPresenter.performBiometricLogin(fallback: { [weak self] in
            self?.present(controller: enterPasswordTransparentController, animated: true)
            modalPasswordVCShown = true
        })

        let cleanup: (Result<String, Error>) -> Future<String, Error> = { result in
            let future = Future<String, Error> { promise in
                if modalPasswordVCShown {
                    enterPasswordTransparentController.dismiss(animated: true) {
                        promise(result)
                    }
                } else {
                    promise(result)
                }
            }
            return future
        }

        return requestPasswordPresenter.passwordPublisher
            .flatMap { cleanup(.success($0)) }
            .catch { cleanup(.failure($0)) }
            .eraseToAnyPublisher()
    }
    
    private nonisolated func present(controller: UIViewController, animated: Bool) {
        Task {
            await self.navigationController.present(controller, animated: animated)
        }
    }
}

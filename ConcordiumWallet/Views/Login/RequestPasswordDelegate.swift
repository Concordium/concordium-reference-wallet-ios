//
// Created by Concordium on 07/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

protocol RequestPasswordDelegate: AnyObject {
    func requestUserPassword(keychain: KeychainWrapperProtocol) -> AnyPublisher<String, Error>
}

extension RequestPasswordDelegate where Self: Coordinator {
    func requestUserPassword(keychain: KeychainWrapperProtocol) -> AnyPublisher<String, Error> {
        let requestPasswordPresenter = RequestPasswordPresenter(keychain: keychain)
        var modalPasswordVCShown = false

        requestPasswordPresenter.performBiometricLogin(fallback: { [weak self] in
            self?.show(requestPasswordPresenter)
            modalPasswordVCShown = true
        })

        let cleanup: (Result<String, Error>) -> Future<String, Error> = { [weak self] result in
                    let future = Future<String, Error> { promise in
                        if modalPasswordVCShown {
                            self?.navigationController.dismiss(animated: true) {
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

    private func show(_ presenter: RequestPasswordPresenter) {
        let vc = EnterPasswordFactory.create(with: presenter)
        let nc = TransparentNavigationController()
        nc.modalPresentationStyle = .fullScreen
        nc.viewControllers = [vc]
        self.navigationController.present(nc, animated: true)
    }
}

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

        let enterPasswordController = EnterPasswordFactory.create(with: requestPasswordPresenter)
        let enterPasswordTransparantController = TransparentNavigationController()
        enterPasswordTransparantController.modalPresentationStyle = .fullScreen
        enterPasswordTransparantController.viewControllers = [enterPasswordController]

        requestPasswordPresenter.performBiometricLogin(fallback: { [weak self] in
            self?.navigationController.present(enterPasswordTransparantController, animated: true)
            modalPasswordVCShown = true
        })

        let cleanup: (Result<String, Error>) -> Future<String, Error> = { result in
            let future = Future<String, Error> { promise in
                if modalPasswordVCShown {
                    enterPasswordTransparantController.dismiss(animated: true) {
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
}

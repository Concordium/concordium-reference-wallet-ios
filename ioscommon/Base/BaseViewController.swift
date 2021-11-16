//
//  BaseViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 10/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    private var cancellables: [AnyCancellable] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(_ keyboardHeight: CGFloat) { }
    func keyboardWillHide(_ keyboardHeight: CGFloat) { }
}

// MARK: - Keyboard Notifications

private extension BaseViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardEvent(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardEvent(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardEvent(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else {
            return
        }

        let extraSpacing: CGFloat = 5
        let keyboardHeight = (keyboardFrame.height - self.view.safeAreaInsets.bottom)
        let newHeight = keyboardHeight + extraSpacing

        UIView.animate(withDuration: 0.5) { [weak self] in
            switch notification.name {
            case UIResponder.keyboardWillHideNotification:
                self?.keyboardWillHide(newHeight)
            case UIResponder.keyboardWillShowNotification:
                self?.keyboardWillShow(newHeight)
            default:
                return
            }
        }

        view.layoutIfNeeded()
    }
}

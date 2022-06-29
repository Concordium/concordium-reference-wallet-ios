//
//  BaseViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 10/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class BaseViewController: UIViewController {
    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotifications()
    }

    func keyboardWillShow(_ keyboardHeight: CGFloat) { }
    func keyboardWillHide(_ keyboardHeight: CGFloat) { }
}

// MARK: - Keyboard Notifications

private extension BaseViewController {
    func registerKeyboardNotifications() {
            Publishers.MergeMany(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            )
            .sink(receiveValue: { [weak self] notification in
                guard
                    let self = self,
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

                self.view.layoutIfNeeded()
            })
            .store(in: &cancellables)
    }
}

// MARK: - SwiftUI View Support
extension BaseViewController {
    func show<Content: View>(_ content: Content, in view: UIView) {
        let controller = UIHostingController(rootView: content)
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
        ])
        
        controller.didMove(toParent: self)
    }
}

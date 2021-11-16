//
//  KeyboardDismissableBaseViewController.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 15/11/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

class KeyboardDismissableBaseViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedView() {
        didDismissKeyboard()
    }

    func didDismissKeyboard() {
        view.endEditing(true)
    }
}

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - Keyboard Notifications

extension BaseViewController {
    func keyboardWillShow(_ animationBlock: @escaping (CGFloat) -> Void) {
        animateWithKeyboard(UIResponder.keyboardWillShowNotification, animationBlock)
    }
    
    func keyboardWillHide(_ animationBlock: @escaping (CGFloat) -> Void) {
        animateWithKeyboard(UIResponder.keyboardWillHideNotification, animationBlock)
    }
    
    private func animateWithKeyboard(_ notification: NSNotification.Name, _ animationBlock: @escaping (CGFloat) -> Void) {
        NotificationCenter.default
            .publisher(for: notification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .sink { [weak self] keyboardFrame in
                UIView.animate(withDuration: 0.5) {
                    animationBlock(keyboardFrame.height)
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
}

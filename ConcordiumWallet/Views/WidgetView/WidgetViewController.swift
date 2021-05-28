//
//  WidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
typealias VoidClosure = () -> Void

class WidgetViewController: BaseViewController, Storyboarded {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var footerStackView: UIStackView!
    
    @IBOutlet weak var footerStackHeightConstraint: NSLayoutConstraint!
    
    var viewControllers = [UIViewController]()
    var footerViewControllers = [UIViewController]()
    
    var rightBarButtonClosure: VoidClosure?

    override func viewDidLoad() {
        super.viewDidLoad()
        showViewControllers()
        showFooterViewControllers()
    }
    
    func addRightBarButton(iconName: String, closure: @escaping VoidClosure) {
        rightBarButtonClosure = closure
        let rightButtonImage = UIImage(named: iconName)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightButtonImage,
                                                            style: .plain,
                                                            target: self, action: #selector(rightButtonAction))
    }

    func add(viewControllers: [UIViewController]) {
        self.viewControllers.append(contentsOf: viewControllers)
        if isViewLoaded {
            showViewControllers()
        }
    }
    
    func addToFooter(viewControllers: [UIViewController]) {
        self.footerViewControllers.append(contentsOf: viewControllers)
        if isViewLoaded {
            showFooterViewControllers()
        }
    }

    func showViewControllers() {
        stackView.removeAllArrangedSubviews()
        for vc in viewControllers {
            stackView.addArrangedSubview(vc.view)
        }
    }
    
    func showFooterViewControllers() {
        footerStackView.removeAllArrangedSubviews()
        for vc in footerViewControllers {
            footerStackView.addArrangedSubview(vc.view)
        }
        
        if footerViewControllers.count == 0 {
            footerStackHeightConstraint.constant = 0
        }
    }
    
    @objc func rightButtonAction() {
        rightBarButtonClosure?()
    }
}

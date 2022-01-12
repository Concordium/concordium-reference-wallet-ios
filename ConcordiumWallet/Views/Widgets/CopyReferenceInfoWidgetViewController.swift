//
//  CopyReferenceInfoWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 15/10/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit
import Foundation

protocol CopyReferenceInfoWidgetViewProtocol: AnyObject {}

class CopyReferenceInfoWidgetFactory {
    class func create(with presenter: CopyReferenceInfoWidgetPresenter) -> CopyReferenceInfoWidgetViewController {
        CopyReferenceInfoWidgetViewController.instantiate(fromStoryboard: "Widget") { coder in
            return CopyReferenceInfoWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class CopyReferenceInfoWidgetViewController: BaseViewController, CopyReferenceInfoWidgetViewProtocol, Storyboarded {
    
    var presenter: CopyReferenceInfoWidgetPresenterProtocol
    @IBOutlet weak var label: UILabel!
    
    init?(coder: NSCoder, presenter: CopyReferenceInfoWidgetPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view = self
        presenter.viewDidLoad()
        
        label.text = String(format: "copyreference.info.text".localized,
                            presenter.identityProviderName,
                            presenter.identityProviderSupportEmail,
                            AppConstants.Support.concordiumSupportMail)
    }
}

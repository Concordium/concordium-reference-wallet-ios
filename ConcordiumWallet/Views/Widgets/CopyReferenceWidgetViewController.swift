//
//  CopyReferenceWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 08/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit
import Foundation

protocol CopyReferenceWidgetViewProtocol: AnyObject {
    func showToast()
}

class CopyReferenceWidgetFactory {
    class func create(with presenter: CopyReferenceWidgetPresenter) -> CopyReferenceWidgetViewController {
        CopyReferenceWidgetViewController.instantiate(fromStoryboard: "Widget") { coder in
            return CopyReferenceWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class CopyReferenceWidgetViewController: BaseViewController, CopyReferenceWidgetViewProtocol, Storyboarded, ShowToast {
    
    var presenter: CopyReferenceWidgetPresenterProtocol
    @IBOutlet weak var label: UILabel!
    
    init?(coder: NSCoder, presenter: CopyReferenceWidgetPresenterProtocol) {
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
    }
    
    func showToast() {
        showToast(withMessage: "supportmail.copied".localized)
    }
    
    @IBAction func copyReferenceTapped(_ sender: Any) {
        presenter.copyReferenceButtonTapped()
    }
}

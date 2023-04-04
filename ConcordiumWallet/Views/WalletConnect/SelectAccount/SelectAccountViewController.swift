//
//  SelectAccountViewController.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.4.23.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import UIKit

class SelectAccountFactory {
    class func create(with presenter: SelectAccountPresenter) -> SelectAccountViewController {
        return SelectAccountViewController(presenter: presenter)
    }
}

class SelectAccountViewController: BaseViewController {

    var presenter: SelectAccountPresenterProtocol
    
    init(presenter: SelectAccountPresenterProtocol) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sample title"

        presenter.view = self
        presenter.viewDidLoad()

        view.backgroundColor = UIColor.cyan
    }
}

extension SelectAccountViewController: SelectAccountViewProtocol {
}

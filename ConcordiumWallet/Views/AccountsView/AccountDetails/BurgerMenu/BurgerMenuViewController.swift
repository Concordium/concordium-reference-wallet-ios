//
//  BurgerMenuViewController.swift
//  ConcordiumWallet
//
//  Concordium on 04/12/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class BurgerMenuFactory {
    class func create(with presenter: BurgerMenuPresenter) -> BurgerMenuViewController {
        BurgerMenuViewController.instantiate(fromStoryboard: "Account") { coder in
            return BurgerMenuViewController(coder: coder, presenter: presenter)
        }
    }
}

class BurgerMenuViewController: BaseViewController, BurgerMenuViewProtocol, Storyboarded, ShowToast {
    
    var presenter: BurgerMenuPresenterProtocol
    
    init?(coder: NSCoder, presenter: BurgerMenuPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func bind(to viewModel: BurgerMenuViewModel) {
    }

    @IBAction func pressedDismiss(sender: Any) {
        presenter.pressedDismiss()
    }

    @IBAction func pressedReleaseSchedule(sender: Any) {
        presenter.pressedShowRelease()
    }

    @IBAction func pressedTransferFilters(sender: Any) {
        presenter.pressedShowFilters()
    }

    @IBAction func pressedShieldedBalance(_ sender: Any) {
        presenter.pressedShowShieldedBalance()
    }
}

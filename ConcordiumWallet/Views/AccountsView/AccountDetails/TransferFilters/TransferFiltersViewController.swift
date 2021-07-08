//
//  TransferFiltersViewController.swift
//  Mock
//
//  Created by Concordium on 26/02/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit
import Combine

class TransferFiltersFactory {
    class func create(with presenter: TransferFiltersPresenter) -> TransferFiltersViewController {
        TransferFiltersViewController.instantiate(fromStoryboard: "Account") { coder in
            return TransferFiltersViewController(coder: coder, presenter: presenter)
        }
    }
}

class TransferFiltersViewController: BaseViewController, TransferFiltersViewProtocol, Storyboarded {
    private var cancellables: [AnyCancellable] = []
    var presenter: TransferFiltersPresenterProtocol
    
    @IBOutlet weak var showRewardCheckboxButton: UIButton!
    @IBOutlet weak var showFinalRewardCheckboxButton: UIButton!
    var showRewardsEnabled: Bool = true
    var showFinalRewardsEnabled: Bool = true
    
    init?(coder: NSCoder, presenter: TransferFiltersPresenter) {
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

    func bind(to viewModel: TransferFiltersViewModel) {
        viewModel.$title.sink { (title) in
            self.title = title
        }
        .store(in: &cancellables)
        
        viewModel.$showRewards.sink { (enabled) in
            self.showRewardsEnabled = enabled
            self.setCheckboxImageState(checked: self.showRewardsEnabled, forButton: self.showRewardCheckboxButton)
        }
        .store(in: &cancellables)

        viewModel.$showFinalRewards.sink { (enabled) in
            self.showFinalRewardsEnabled = enabled
            self.setCheckboxImageState(checked: self.showFinalRewardsEnabled, forButton: self.showFinalRewardCheckboxButton)
        }
        .store(in: &cancellables)
    }
    
    func setCheckboxImageState(checked: Bool, forButton button: UIButton) {
        let image = checked ? UIImage(named: "checkmark_active") : UIImage(named: "checkmark")
        button.setImage(image, for: .normal)
    }
    
    @IBAction func showRewardButtonPressed(_ sender: Any) {
        showRewardsEnabled = !showRewardsEnabled
        presenter.setShowRewardsEnabled(showRewardsEnabled)
        print("toggled show rewards to \(showRewardsEnabled)")
    }
    
    @IBAction func showFinalRewardButtonPressed(_ sender: Any) {
        showFinalRewardsEnabled = !showFinalRewardsEnabled
        presenter.setShowFinalRewardsEnabled(showFinalRewardsEnabled)
        print("toggled show final rewards to \(showFinalRewardsEnabled)")
    }
}

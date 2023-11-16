//
//  BakerCommissionSettingsViewController.swift
//  Mock
//
//  Created by Milan Sawicki on 16/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

class BakerCommissionSettingsViewFactory {
    class func create(with viewModel: BakerCommissionSettingsViewModel) -> BakerCommissionSettingsViewController {
        BakerCommissionSettingsViewController.instantiate(fromStoryboard: "Stake") { coder in
            BakerCommissionSettingsViewController(coder: coder, viewModel: viewModel)
        }
    }
}

class BakerCommissionSettingsViewController: BaseViewController, Storyboarded, Loadable {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var transactionFeeAmountLabel: UILabel!
    @IBOutlet weak var bakingRewardFeeLabel: UILabel!

    private let viewModel: BakerCommissionSettingsViewModel
    init?(coder: NSCoder, viewModel: BakerCommissionSettingsViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
        self.transactionFeeAmountLabel.text = "\(viewModel.transactionFeeComission)"
        self.bakingRewardFeeLabel.text = "\(viewModel.bakingRewardComission)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        viewModel.continueButtonTapped()
    }
}

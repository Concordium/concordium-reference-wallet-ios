//
//  BakerCommissionSettingsViewController.swift
//  Mock
//
//  Created by Milan Sawicki on 16/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit
import Combine

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
    private var cancellables: [AnyCancellable] = []
    private var formatter = NumberFormatter.commissionFormatter
    private let viewModel: BakerCommissionSettingsViewModel

    init?(coder: NSCoder, viewModel: BakerCommissionSettingsViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
        viewModel.$transactionFeeCommission
            .compactMap { [weak self] in
                guard let self = self else { return nil }
                return "\(self.formatter.string(from: NSNumber(value: $0))!)%" }
            .assign(to: \.text, on: transactionFeeAmountLabel)
            .store(in: &cancellables)
        viewModel.$bakingRewardCommission
            .compactMap { [weak self] in
                guard let self = self else { return nil }
                return "\(self.formatter.string(from: NSNumber(value: $0))!)%" }
            .assign(to: \.text, on: bakingRewardFeeLabel)
            .store(in: &cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        viewModel.continueButtonTapped()
    }
}

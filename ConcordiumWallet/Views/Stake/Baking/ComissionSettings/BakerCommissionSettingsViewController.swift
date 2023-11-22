//
//  BakerCommissionSettingsViewController.swift
//  Mock
//
//  Created by Milan Sawicki on 16/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import UIKit

class BakerCommissionSettingsViewFactory {
    class func create(with viewModel: BakerCommissionSettingsViewModel) -> BakerCommissionSettingsViewController {
        BakerCommissionSettingsViewController.instantiate(fromStoryboard: "Stake") { coder in
            BakerCommissionSettingsViewController(coder: coder, viewModel: viewModel)
        }
    }
}

extension BakerCommissionSettingsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool { true }
}

class BakerCommissionSettingsViewController: BaseViewController, Storyboarded, Loadable {
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var transactionFeeAmountLabel: UILabel!
    @IBOutlet var bakingRewardFeeLabel: UILabel!
    private var cancellables: [AnyCancellable] = []
    private var formatter = NumberFormatter.commissionFormatter
    private let viewModel: BakerCommissionSettingsViewModel

    init?(coder: NSCoder, viewModel: BakerCommissionSettingsViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadData()
        setupDescriptionAttributes()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        viewModel.continueButtonTapped()
    }

    private func setupDescriptionAttributes() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17.0),
        ]
        let attributedString = NSMutableAttributedString(
            string: "In Concordium Legacy Wallet, commission rates are locked and cannot be changed. If you wish to change the commission rates for your staking pool, you must install the Concordium Blockchain Wallet. To see how to do this, refer to the Concordium Wallet FAQ.",
            attributes: attributes
        )
        attributedString.addAttribute(
            .link,
            value: "https://developer.concordium.software/en/mainnet/net/mobile-wallet-gen2/faq.html#wallet-migrate",
            range: (attributedString.string as NSString).range(of: "Concordium Wallet FAQ")
        )

        descriptionTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primary,
        ]
        descriptionTextView.attributedText = attributedString
        descriptionTextView.delegate = self
        descriptionTextView.isSelectable = true
        descriptionTextView.isEditable = false
        descriptionTextView.delaysContentTouches = false
        descriptionTextView.isScrollEnabled = false
    }

    private func setupBindings() {
        if let label = transactionFeeAmountLabel {
            viewModel.$transactionFeeCommission
                .compactMap { [weak self] in
                    guard let self = self else { return nil }
                    return "\(self.formatter.string(from: NSNumber(value: $0))!)%"
                }
                .assign(to: \.text, on: label)
                .store(in: &cancellables)
        }
        if let label = bakingRewardFeeLabel {
            viewModel.$bakingRewardCommission
                .compactMap { [weak self] in
                    guard let self = self else { return nil }
                    return "\(self.formatter.string(from: NSNumber(value: $0))!)%"
                }
                .assign(to: \.text, on: label)
                .store(in: &cancellables)
        }
    }
}

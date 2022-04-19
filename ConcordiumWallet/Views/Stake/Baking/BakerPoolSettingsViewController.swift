//
//  BakerPoolSettingsViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 14/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

// MARK: View
protocol BakerPoolSettingsViewProtocol: AnyObject {
    func bind(viewModel: BakerPoolSettingsViewModel)
}

class BakerPoolSettingsFactory {
    class func create(with presenter: BakerPoolSettingsPresenter) -> BakerPoolSettingsViewController {
        BakerPoolSettingsViewController.instantiate(fromStoryboard: "Stake") {coder in
            return BakerPoolSettingsViewController(coder: coder, presenter: presenter)
        }
    }
}

class BakerPoolSettingsViewController: BaseViewController, BakerPoolSettingsViewProtocol, Storyboarded {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var poolControl: UISegmentedControl!
    
    var poolSettingPublisher = PassthroughSubject<Int, Error>()
    
	var presenter: BakerPoolSettingsPresenterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init?(coder: NSCoder, presenter: BakerPoolSettingsPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        poolControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        poolControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.whiteText], for: .selected)
        poolControl.setTitle("baking.openfordelegators".localized, forSegmentAt: 0)
        poolControl.setTitle("baking.keeppoolclosed".localized, forSegmentAt: 1)
        
        presenter.view = self
        presenter.viewDidLoad()
    }
    
    func bind(viewModel: BakerPoolSettingsViewModel) {
        viewModel.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
        
        viewModel.$text
            .compactMap { $0 }
            .assign(to: \.text, on: textLabel)
            .store(in: &cancellables)
        
        viewModel.$currentValue.sink { [weak self] currentValue in
            guard let self = self else { return }
            if let currentValue = currentValue {
                self.poolControl.insertSegment(withTitle: "baking.closedfornewdelegators".localized,
                                               at: 1,
                                               animated: false) // we addd an extra option
                self.currentValueLabel.text = currentValue
                self.currentValueLabel.isHidden = false
            } else {
                self.currentValueLabel.isHidden = true
            }
        }.store(in: &cancellables)
        
        viewModel.$selectedPoolSettingIndex
            .assign(to: \.selectedSegmentIndex, on: poolControl)
            .store(in: &cancellables)
    }

    @IBAction func restakeValueChanged(_ sender: UISegmentedControl) {
        poolSettingPublisher.send(sender.selectedSegmentIndex)
    }
    
    @IBAction func pressedContinue(_ sender: UIButton) {
        presenter.pressedContinue()
    }
    
}

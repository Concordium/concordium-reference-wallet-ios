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
protocol BakerPoolSettingsViewProtocol: ShowAlert {
    func bind(viewModel: BakerPoolSettingsViewModel)
    var poolSettingPublisher: PassthroughSubject<Int, Error> { get }
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
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0,
                                                     left: 0,
                                                     bottom: 10,
                                                     right: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close_icon"),
            style: .plain,
            target: self,
            action: #selector(pressedClose)
        )
        
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
                self.currentValueLabel.text = currentValue
                self.currentValueLabel.isHidden = false
            } else {
                self.currentValueLabel.isHidden = true
            }
        }.store(in: &cancellables)
        
        viewModel.$showsCloseForNew.sink { [weak self] shows in
            guard let self = self else { return }
            if shows {
                self.poolControl.insertSegment(withTitle: "baking.closedfornewdelegators".localized,
                                               at: 1,
                                               animated: false)
            } else if self.poolControl.numberOfSegments == 3 {
                self.poolControl.removeSegment(at: 1, animated: false)
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
    
    @objc func pressedClose() {
        presenter.pressedClose()
    }
}

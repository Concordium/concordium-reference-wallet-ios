//
//  StakeStatusViewController.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit
import Combine

// MARK: View
protocol StakeStatusViewProtocol: AnyObject {
    func bind(viewModel: StakeStatusViewModel)
}

class StakeStatusFactory {
    class func create(with presenter: StakeStatusPresenterProtocol) -> StakeStatusViewController {
        StakeStatusViewController.instantiate(fromStoryboard: "Stake") {coder in
            return StakeStatusViewController(coder: coder, presenter: presenter)
        }
    }
}

class StakeStatusViewController: BaseViewController, StakeStatusViewProtocol, Storyboarded {
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gracePeriodLabel: UILabel!
    @IBOutlet weak var warningTextLabel: UILabel!
    @IBOutlet weak var importantTextLabel: UILabel!
    @IBOutlet weak var newStakeLabel: UILabel!
    @IBOutlet weak var newStakeValue: UILabel!
    @IBOutlet weak var newStakeView: UIView!
    @IBOutlet weak var stopWidgetButton: WidgetButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var nextButton: StandardButton!
    
    
    var dataSource: UITableViewDiffableDataSource<String, StakeRowViewModel>?
    var presenter: StakeStatusPresenterProtocol

    private var cancellables = Set<AnyCancellable>()
    
    init?(coder: NSCoder, presenter: StakeStatusPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stopWidgetButton.applyConcordiumEdgeStyle(color: .error)
        
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0,  bottom: 10, right: 0)
        
        dataSource = UITableViewDiffableDataSource<String, StakeRowViewModel>(tableView: tableView, cellProvider: createCell)
        dataSource?.defaultRowAnimation = .none
        
        presenter.view = self
        presenter.viewDidLoad()
    }

    func bind(viewModel: StakeStatusViewModel) {
        viewModel.$topText
            .compactMap { $0 }
            .assign(to: \.text, on: topTextLabel)
            .store(in: &cancellables)
        
        viewModel.$topImageName
            .compactMap { UIImage.init(named: $0) }
            .assign(to: \.image, on: topImageView)
            .store(in: &cancellables)
        
        
        viewModel.$rows.sink { rows in
            var snapshot = NSDiffableDataSourceSnapshot<String, StakeRowViewModel>()
            snapshot.appendSections([""])
            snapshot.appendItems(rows, toSection: "")

            if rows.count > 0 {
                self.dataSource?.apply(snapshot)
            }
            self.tableView.reloadData()
        }.store(in: &cancellables)
        
        
        viewModel.$bottomImportantMessage
            .sink(receiveValue: { [weak self] text in
                if let text = text {
                    self?.importantTextLabel.text = text
                    self?.importantTextLabel.isHidden = false
                } else {
                    self?.importantTextLabel.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        
        viewModel.$bottomInfoMessage
            .sink(receiveValue: { [weak self] text in
                if let text = text {
                    self?.warningTextLabel.text = text
                    self?.warningTextLabel.isHidden = false
                } else {
                    self?.warningTextLabel.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel.$gracePeriodText
            .sink(receiveValue: { [weak self] text in
                if let text = text {
                    self?.gracePeriodLabel.text = text
                    self?.gracePeriodLabel.isHidden = false
                } else {
                    self?.gracePeriodLabel.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel.$newAmount
            .sink(receiveValue: { [weak self] text in
                if let text = text {
                    self?.newStakeValue.text = text
                    self?.newStakeView.isHidden = false
                } else {
                    self?.newStakeView.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        viewModel.$newAmountLabel
            .compactMap { $0 }
            .assign(to: \.text, on: newStakeLabel)
            .store(in: &cancellables)
        
        viewModel.$stopButtonShown
            .assign(to: \.isHidden, on: stopButton)
            .store(in: &cancellables)
        
        viewModel.$stopButtonEnabled
            .assign(to: \.isEnabled, on: stopButton)
            .store(in: &cancellables)
        
        viewModel.$updateButtonEnabled
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
    }
    
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: StakeRowViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StakeEntryCell", for: indexPath) as? StakeEntryCell
        cell?.headerLabel.text = viewModel.headerLabel
        cell?.valueLabel.text = viewModel.valueLabel
        return cell
    }
}

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
protocol StakeStatusViewProtocol: Loadable, ShowAlert {
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
    @IBOutlet weak var placeholderLabel: UILabel!
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
    
    var updateTimer: Timer?

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
 
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        dataSource = UITableViewDiffableDataSource<String, StakeRowViewModel>(tableView: tableView, cellProvider: createCell)
        dataSource?.defaultRowAnimation = .none
        
        presenter.view = self
        presenter.viewDidLoad()
        showCloseButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUpdateTimer()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startUpdateTimer),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopUpdateTimer),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdateTimer()
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func startUpdateTimer() {
        DispatchQueue.main.async {
            self.updateTimer = Timer.scheduledTimer(
                timeInterval: 60.0,
                target: self,
                selector: #selector(self.updateStatus),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    @objc private func stopUpdateTimer() {
        DispatchQueue.main.async {
            self.updateTimer?.invalidate()
            self.updateTimer = nil
        }
    }
    
    @objc private func updateStatus() {
        presenter.updateStatus()
    }
    
    func showCloseButton() {
        let closeIcon = UIImage(named: "close_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(self.closeButtonTapped))
    }

    @objc func closeButtonTapped() {
        presenter.closeButtonTapped()
    }

    // swiftlint:disable function_body_length
    func bind(viewModel: StakeStatusViewModel) {
        viewModel.$title.sink { [weak self] title in
            self?.title = title
        }.store(in: &cancellables)
        
        viewModel.$topText
            .compactMap { $0 }
            .assign(to: \.text, on: topTextLabel)
            .store(in: &cancellables)
        
        viewModel.$topImageName
            .compactMap { UIImage.init(named: $0) }
            .assign(to: \.image, on: topImageView)
            .store(in: &cancellables)
        
        viewModel.$placeholderText.sink { [weak self] text in
            if let text = text {
                self?.placeholderLabel.isHidden = false
                self?.placeholderLabel.text = text
            } else {
                self?.placeholderLabel.isHidden = true
            }
        }.store(in: &cancellables)
        
        viewModel.$rows.sink { rows in
            var snapshot = NSDiffableDataSourceSnapshot<String, StakeRowViewModel>()
            snapshot.appendSections([""])
            snapshot.appendItems(rows, toSection: "")
            self.dataSource?.apply(snapshot)
            
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
            .sink(receiveValue: { [weak self] shown in
                self?.stopWidgetButton.isHidden = !shown
                self?.stopButton.isHidden = !shown
                
            })
            .store(in: &cancellables)
        
        viewModel.$stopButtonEnabled.sink(receiveValue: { [weak self] enabled in
            self?.stopButton.isEnabled = enabled
            if enabled {
                self?.stopWidgetButton.applyConcordiumEdgeStyle(color: .error)
            } else {
                self?.stopWidgetButton.applyConcordiumEdgeStyle(color: .fadedText)
            }
        }).store(in: &cancellables)
        
        viewModel.$updateButtonEnabled
            .assign(to: \.isEnabled, on: nextButton)
            .store(in: &cancellables)
        
        viewModel.$buttonLabel.sink(receiveValue: { [weak self] text in
            self?.nextButton.setTitle(text, for: .normal)
        }).store(in: &cancellables)
        
        viewModel.$stopButtonLabel.sink(receiveValue: { [weak self] text in
            self?.stopButton.setTitle(text, for: .normal)
        }).store(in: &cancellables)
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: StakeRowViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StakeEntryCell", for: indexPath) as? StakeEntryCell
        cell?.headerLabel.text = viewModel.headerLabel
        cell?.valueLabel.text = viewModel.valueLabel
        return cell
    }
    
    @IBAction func pressedButton(_ sender: UIButton) {
        presenter.pressedButton()
    }
    
    @IBAction func pressedStop( sender: UIButton) {
        presenter.pressedStopButton()
    }
}

//
//  IdentitiesViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

enum IdentitiesFlowMode {
    case show
    case createAccount
}

class IdentitiesFactory {
    class func create(with presenter: IdentitiesPresenterProtocol, flow: IdentitiesFlowMode) -> IdentitiesViewController {
        IdentitiesViewController.instantiate(fromStoryboard: "Identity") { coder in
            return IdentitiesViewController(coder: coder, presenter: presenter, flowMode: flow)
        }
    }
}

// MARK: View
protocol IdentitiesViewProtocol: ShowError {
    func showCreateIdentityView(show: Bool)
    func reloadView()
    func showIdentityFailed(_ errorMessage: String, showCancel: Bool, completion: @escaping () -> Void)
}

class IdentitiesViewController: BaseViewController, Storyboarded {

    var presenter: IdentitiesPresenterProtocol
    private weak var updateTimer: Timer?
    
    @IBOutlet weak var emptyIdentitiesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createIdentityButton: StandardButton!
    
    private var flowMode: IdentitiesFlowMode

    init?(coder: NSCoder, presenter: IdentitiesPresenterProtocol, flowMode: IdentitiesFlowMode) {
        self.presenter = presenter
        self.flowMode = flowMode

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self

        title = presenter.getTitle()
        tableView.tableFooterView = UIView(frame: .zero)

        //Set the right bar button item depending on the flow
        var barButtonSelector: Selector
        var iconName: String
        switch flowMode {
        case .show:
            barButtonSelector = #selector(self.createIdentity)
            iconName = "add_icon"
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
            tableView.refreshControl = refreshControl
        case .createAccount:
            barButtonSelector = #selector(self.cancel)
            iconName = "close_icon"
        }
        let buttonBarIcon = UIImage(named: iconName)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: buttonBarIcon,
                                                            style: .plain,
                                                            target: self,
                                                            action: barButtonSelector)

    }
    
    @objc func refresh(_ sender: AnyObject) {
        presenter.refresh()
        tableView.refreshControl?.endRefreshing()
    }

    func startRefreshTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0,
                                           target: self,
                                           selector: #selector(refreshOnTimerCallback),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    func stopRefreshTimer() {
        if updateTimer != nil {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
    
    @objc func refreshOnTimerCallback() {
        presenter.refresh()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        startRefreshTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
    }
    
    @IBAction func createIdentity() {
        presenter.createIdentitySelected()
    }

    @objc func cancel() {
        presenter.cancel()
    }
}

extension IdentitiesViewController: IdentitiesViewProtocol {
    func showCreateIdentityView(show: Bool) {
        emptyIdentitiesView.isHidden = !show
        createIdentityButton.isHidden = show
        tableView.isHidden = show
    }

    func reloadView() {
        tableView.reloadData()
    }
    
    func showIdentityFailed(_ errorMessage: String, showCancel: Bool = true, completion: @escaping () -> Void) {
        let ac = UIAlertController(title: "identityfailed.title".localized, message: errorMessage, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "identityfailed.tryagain".localized, style: .default) { (action) in
            completion()
        }
        ac.addAction(continueAction)
        if showCancel {
            let cancelAction = UIAlertAction(title: "errorAlert.cancelButton".localized, style: .cancel)
            ac.addAction(cancelAction)
        }
        present(ac, animated: true)
    }
}

extension IdentitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.viewModelsCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityCell", for: indexPath) as? IdentityCell
        if let viewModel = presenter.identityViewModel(index: indexPath.row) {
            cell?.identityCardView?.titleLabel?.text = viewModel.nickname
            cell?.identityCardView?.expirationDateLabel?.text = viewModel.expiresOn
            cell?.identityCardView?.iconImageView?.image = UIImage.decodeBase64(toImage: viewModel.iconEncoded)
            switch viewModel.state {
            case .confirmed:
                cell?.identityCardView?.statusIcon.image = UIImage(named: "ok_icon")
            case .pending:
                cell?.identityCardView?.statusIcon.image = UIImage(named: "pending")
                cell?.identityCardView?.statusIcon.tintColor = .primary
            case .failed:
                cell?.identityCardView?.statusIcon.image = UIImage(named: "problem_icon")
            }
        }
        return cell!
    }
}

extension IdentitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userSelectedIdentity(index: indexPath.row)
    }
}

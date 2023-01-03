//
//  IdentitiesViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import MessageUI
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
protocol IdentitiesViewProtocol: ShowAlert {
    func showCreateIdentityView(show: Bool)
    func reloadView()
    func showIdentityFailed(identityProviderName: String,
                            identityProviderSupportEmail: String,
                            reference: String,
                            completion: @escaping (_ option: IdentityFailureAlertOption) -> Void)
}

class IdentitiesViewController: BaseViewController, Storyboarded, ShowToast, SupportMail, ShowIdentityFailure {

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

        // Set the right bar button item depending on the flow
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
    
    @objc func refreshIdentities() {
        presenter.refresh()
    }

    func startRefreshTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 5.0,
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIdentities), name:     Notification.Name("seedIdentityCoordinatorWasFinishedNotification"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("seedIdentityCoordinatorWasFinishedNotification"), object: nil)
    }
    
    @objc func appDidBecomeActive() {
        presenter.refresh()
        startRefreshTimer()
    }
    
    @objc func appWillResignActive() {
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
    
    func showIdentityFailed(identityProviderName: String,
                            identityProviderSupportEmail: String,
                            reference: String,
                            completion: @escaping (_ option: IdentityFailureAlertOption) -> Void) {
        showIdentityFailureAlert(identityProviderName: identityProviderName,
                                 identityProviderSupportEmail: identityProviderSupportEmail,
                                 reference: reference,
                                 completion: completion)
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
                cell?.identityCardView?.applyConcordiumEdgeStyle(color: UIColor.primary)
            case .pending:
                cell?.identityCardView?.statusIcon.image = UIImage(named: "pending")
                cell?.identityCardView?.statusIcon.tintColor = .primary
                cell?.identityCardView?.applyConcordiumEdgeStyle(color: UIColor.fadedText)
            case .failed:
                cell?.identityCardView?.statusIcon.image = UIImage(named: "problem_icon")
                cell?.identityCardView?.applyConcordiumEdgeStyle(color: .error)
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

extension IdentitiesViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}

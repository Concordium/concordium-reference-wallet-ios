//
//  BurgerMenuViewController.swift
//  ConcordiumWallet
//
//  Concordium on 04/12/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class BurgerMenuFactory {
    class func create(with presenter: BurgerMenuPresenterProtocol) -> BurgerMenuViewController {
        BurgerMenuViewController.instantiate(fromStoryboard: "Account") { coder in
            return BurgerMenuViewController(coder: coder, presenter: presenter)
        }
    }
}

class BurgerMenuViewController: BaseViewController, BurgerMenuViewProtocol, Storyboarded, ShowToast {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: BurgerMenuPresenterProtocol
    var dataSource: UITableViewDiffableDataSource<String, BurgerMenuViewModel.Action>?
    private var cancellables: [AnyCancellable] = []
    
    var loadContainerView: UIView {
        return self.view
    }
    
    var activityIndicatorTint: UIColor? {
        return .white
    }
    
    init?(coder: NSCoder, presenter: BurgerMenuPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = CGFloat.zero
        }
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: createCell)
        self.presenter.view = self
        self.presenter.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: BurgerMenuViewModel.Action) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BurgerMenuOptionCell", for: indexPath) as? BurgerMenuOptionCell
        cell?.setup(
            cellRow: indexPath.row,
            title: viewModel.displayName,
            destructive: viewModel.destructive,
            enabled: viewModel.enabled,
            delegate: self
        )
        return cell
    }
    
    func bind(to viewModel: BurgerMenuViewModel) {
        
        viewModel.$displayActions.sink { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<String, BurgerMenuViewModel.Action>()
            snapshot.appendSections([""])
            snapshot.appendItems($0, toSection: "")
            if $0.count > 0 {
                self?.dataSource?.apply(snapshot)
            }
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }

    @IBAction func pressedDismiss(sender: Any) {
        presenter.pressedDismiss()
    }
}

extension BurgerMenuViewController: BurgerMenuOptionCellDelegate {
    func selectedCellAt(row: Int) {
        presenter.selectedAction(at: row)
    }
}

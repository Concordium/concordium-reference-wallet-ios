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
    class func create(with presenter: BurgerMenuAccountDetailsPresenter) -> BurgerMenuViewController {
        BurgerMenuViewController.instantiate(fromStoryboard: "Account") { coder in
            return BurgerMenuViewController(coder: coder, presenter: presenter)
        }
    }
}

class BurgerMenuViewController: BaseViewController, BurgerMenuViewProtocol, Storyboarded, ShowToast  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: BurgerMenuPresenterProtocol
    var dataSource: UITableViewDiffableDataSource<String, String>?
    private var cancellables: [AnyCancellable] = []
    
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
        self.presenter.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: String) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BurgerMenuOptionCell", for: indexPath) as? BurgerMenuOptionCell
        cell?.setup(cellRow: indexPath.row, title: viewModel, delegate: self)
        return cell
    }
    
    func bind(to viewModel: BurgerMenuViewModel) {
        
        viewModel.$displayActions.sink { [weak self] in
            var snapshot = NSDiffableDataSourceSnapshot<String, String>()
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

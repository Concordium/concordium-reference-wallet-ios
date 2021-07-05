//
//  IdentityDataWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/10/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class IdentityDataWidgetFactory {
    class func create(with presenter: IdentityDataWidgetPresenter) -> IdentityDataWidgetViewController {
        IdentityDataWidgetViewController.instantiate(fromStoryboard: "Widget") {coder in
            return IdentityDataWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class IdentityDataWidgetViewController: BaseViewController, IdentityDataWidgetViewProtocol, Storyboarded {

	var presenter: IdentityDataWidgetPresenterProtocol

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    init?(coder: NSCoder, presenter: IdentityDataWidgetPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To remove separator when not needed
        tableView.tableFooterView = UIView(frame: .zero)
//        tableView.applyConcordiumEdgeStyle()
        tableView.backgroundColor = .clear

        presenter.view = self
        presenter.viewDidLoad()
    }

    func reloadData() {
        tableView.reloadData()
        // To set the height of the table as the height of its content
        tableHeightConstraint.constant = tableView.contentSize.height
    }
}

extension IdentityDataWidgetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.countOfData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityDataHeaderCellView", for: indexPath)
                cell.backgroundColor = .clear
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityDataRowCellView", for: indexPath)
                cell.textLabel?.text = presenter.dataItem(index: indexPath.row).keys.first
                cell.detailTextLabel?.text = presenter.dataItem(index: indexPath.row).values.first
                cell.backgroundColor = .clear
              
                return cell
        }
    }
}

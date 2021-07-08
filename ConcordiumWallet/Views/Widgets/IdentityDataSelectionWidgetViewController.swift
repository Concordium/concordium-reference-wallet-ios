//
//  IdentityDataSelectionWidgetViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/10/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class IdentityDataSelectionWidgetFactory {
    class func create(with presenter: IdentityDataSelectionWidgetPresenter) -> IdentityDataSelectionWidgetViewController {
        IdentityDataSelectionWidgetViewController.instantiate(fromStoryboard: "Widget") {coder in
            return IdentityDataSelectionWidgetViewController(coder: coder, presenter: presenter)
        }
    }
}

class IdentityDataSelectionWidgetViewController: BaseViewController, IdentityDataSelectionWidgetViewProtocol, Storyboarded {

	var presenter: IdentityDataSelectionWidgetPresenterProtocol

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    init?(coder: NSCoder, presenter: IdentityDataSelectionWidgetPresenterProtocol) {
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

        presenter.view = self
        presenter.viewDidLoad()
    }

    func reloadData() {
        tableView.reloadData()
        // To set the height of the table as the height of its content
        tableHeightConstraint.constant = tableView.contentSize.height
    }    
}

extension IdentityDataSelectionWidgetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.countOfData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityDataHeaderCellView", for: indexPath)
//                return cell
//            default:
                // swiftlint:disable:next force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityDataSelectionCell", for: indexPath) as! IdentityDataSelectionCell
                
                cell.delegate = self
                
                let dataItem = presenter.dataItem(index: indexPath.row)
                cell.titleLabel?.text = dataItem.title
                cell.detailLabel?.text = dataItem.details
                
                var checkButtonImageName = "checkmark"
                if dataItem.isChecked {
                    checkButtonImageName = "checkmark_active"
                }
                cell.checkButton.setImage(UIImage(named: checkButtonImageName), for: .normal)
                return cell
//        }
    }
}

extension IdentityDataSelectionWidgetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userCheckedItem(at: indexPath.row)
    }
}

extension IdentityDataSelectionWidgetViewController: IdentityDataSelectionCellDelegate {
    func cellCheckTapped(_ cell: IdentityDataSelectionCell) {
        // Get the index
        if let index = tableView.indexPath(for: cell) {
            presenter.userCheckedItem(at: index.row)
        }
    }
}

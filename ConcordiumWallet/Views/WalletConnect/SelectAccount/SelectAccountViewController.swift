//
//  SelectAccountViewController.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.4.23.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import UIKit

class SelectAccountFactory {
    class func create(with presenter: SelectAccountPresenter) -> SelectAccountViewController {
        return SelectAccountViewController(presenter: presenter)
    }
}

class SelectAccountViewController: BaseViewController {

    var presenter: SelectAccountPresenterProtocol
    
    private let tableView = UITableView()
    
    private var rowHeight: CGFloat = 104.0
    
    init(presenter: SelectAccountPresenterProtocol) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "selectaccount.title".localized

        presenter.view = self
        presenter.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Description Label
        let descriptionLabelOriginX: CGFloat = 40.0
        let descriptionLabel = UILabel(frame: CGRect(x: descriptionLabelOriginX, y: UIApplication.statusBarHeight + navigationController!.navigationBarHeight, width: view.width - 2 * descriptionLabelOriginX, height: 100.0))
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .black
        descriptionLabel.text = "selectaccount.description".localized
        descriptionLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        view.addSubview(descriptionLabel)
        
        // Table View
        let tableViewOriginY = descriptionLabel.frame.maxY
        tableView.frame = CGRect(x: 0.0, y: tableViewOriginY, width: view.width, height: view.height - tableViewOriginY)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
}

extension SelectAccountViewController: SelectAccountViewProtocol {
}

extension SelectAccountViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Select Account Table View Cell Id"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SelectAccountCell

        if cell == nil {
            cell = SelectAccountCell(style: .default, reuseIdentifier: cellIdentifier, frame: CGRect(x: 0.0, y: 0.0, width: tableView.width, height: rowHeight))
        }
        
        return cell!
    }
}

extension SelectAccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}

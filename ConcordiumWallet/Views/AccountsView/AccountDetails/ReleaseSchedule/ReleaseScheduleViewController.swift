//
//  ReleaseScheduleViewController.swift
//  ConcordiumWallet
//
//  Concordium on 27/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

class ReleaseScheduleDataFactory {
    class func create(with presenter: ReleaseSchedulePresenter) -> ReleaseScheduleViewController {
        ReleaseScheduleViewController.instantiate(fromStoryboard: "Account") { coder in
            return ReleaseScheduleViewController(coder: coder, presenter: presenter)
        }
    }
}

class ReleaseScheduleViewController: BaseViewController, ReleaseScheduleViewProtocol, Storyboarded, ShowToast {
    var presenter: ReleaseSchedulePresenterProtocol
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var noData: UILabel!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var dataSource: UITableViewDiffableDataSource<ReleaseScheduleHeader, ReleaseScheduleTransactionViewModel>?
    let tableHeaderHeight: CGFloat = 35
    private var cancellables: [AnyCancellable] = []
    
    init?(coder: NSCoder, presenter: ReleaseSchedulePresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        dataSource = UITableViewDiffableDataSource<ReleaseScheduleHeader,
                                                   ReleaseScheduleTransactionViewModel>(tableView: tableView, cellProvider: createCell)
        dataSource?.defaultRowAnimation = .none
        
        tableView.applyConcordiumEdgeStyle()
        presenter.view = self
        presenter.viewDidLoad()
    }

    func bind(to viewModel: ReleaseScheduleListViewModel) {
        viewModel.$releaseScheduleList.sink { schedules in
            var snapshot = NSDiffableDataSourceSnapshot<ReleaseScheduleHeader, ReleaseScheduleTransactionViewModel>()
            for schedule in schedules {
                let section = ReleaseScheduleHeader(date: schedule.date, amount: schedule.amount)
                if snapshot.sectionIdentifiers.last != section {
                    snapshot.appendSections([section])
                }
                
                snapshot.appendItems(schedule.transactionIds, toSection: section)
            }
            DispatchQueue.main.async {
                self.dataSource?.apply(snapshot)
                self.tableHeightConstraint.constant = self.tableView.contentSize.height > 150 ? self.tableView.contentSize.height : 150
            }
            if schedules.count == 0 {
                self.noData.isHidden = false
            } else {
                self.noData.isHidden = true
            }
            
        }.store(in: &cancellables)
        
        viewModel.$total.sink { (totalGTU) in
            self.totalAmount.text = totalGTU?.displayValueWithGStroke()
        }.store(in: &cancellables)
        
        viewModel.$title.sink { (value) in
            self.title = value
        }.store(in: &cancellables)
        
    }

    private func createCell(tableView: UITableView, indexPath: IndexPath, viewModel: ReleaseScheduleTransactionViewModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReleaseScheduleCell", for: indexPath)
            as? ReleaseScheduleCell
        cell?.transactionHashLabel.text = viewModel.getTransactionHashDisplayValue() // .getTransactionHashDisplayValue(index: indexPath.row)
        return cell
        
    }
}

extension ReleaseScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = dataSource?.itemIdentifier(for: indexPath)
        let fullHash = viewModel?.getTransactionHashFullHash() ?? ""
       
        CopyPasterHelper.copy(string: fullHash)
        tableView.deselectRow(at: indexPath, animated: true)
        self.showToast(withMessage: "general.copied".localized + " " + fullHash)
       
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: tableHeaderHeight))
        headerView.backgroundColor = .background
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.size.width/2 - 15, height: tableHeaderHeight))
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        titleLabel.textColor = .text
        titleLabel.font = Fonts.body
        headerView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel(frame: CGRect(x: headerView.frame.size.width/2,
                                                  y: 0,
                                                  width: headerView.frame.size.width/2 - 15,
                                                  height: tableHeaderHeight))
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = true
        subtitleLabel.textColor = .text
        subtitleLabel.font = Fonts.body
        subtitleLabel.textAlignment = .right
        headerView.addSubview(subtitleLabel)
        
        let diffableDataSource = tableView.dataSource as? UITableViewDiffableDataSource<ReleaseScheduleHeader, ReleaseScheduleTransactionViewModel>
        let sectionIdentifier = diffableDataSource?.snapshot().sectionIdentifiers[section]
        
        if let date = sectionIdentifier?.date {
            titleLabel.text = GeneralFormatter.formatDateWithTime(for: date)
        }
        subtitleLabel.text = sectionIdentifier?.amount.displayValueWithGStroke()
        
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 1))
        separatorView.backgroundColor = UIColor.fadedText.withAlphaComponent(0.2)
        headerView.addSubview(separatorView)
        
        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableHeaderHeight
    }
}

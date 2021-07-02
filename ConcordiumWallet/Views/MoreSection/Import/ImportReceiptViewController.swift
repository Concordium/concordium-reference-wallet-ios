//
//  ImportReceiptViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

// MARK: View
protocol ImportReceiptViewProtocol: AnyObject {

}

class ImportReceiptFactory {
    class func create(with presenter: ImportReceiptPresenter) -> ImportReceiptViewController {
        ImportReceiptViewController.instantiate(fromStoryboard: "More") { coder in
            return ImportReceiptViewController(coder: coder, presenter: presenter)
        }
    }
}

class ImportReceiptViewController: BaseViewController, ImportReceiptViewProtocol, Storyboarded, Loadable {

    var presenter: ImportReceiptPresenterProtocol

    @IBOutlet weak var stackView: UIStackView!

    init?(coder: NSCoder, presenter: ImportReceiptPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        presenter.view = self
        presenter.viewDidLoad()
    }

    @IBAction func okButtonPressed(_ sender: Any) {
        presenter.okButtonPressed()
    }

    func receiptState(report: ImportedItemsReport) {
        renderIdentities(report: report)
        renderRecipients(report: report)
    }

    private func renderIdentities(report: ImportedItemsReport) {
        report.importedIdentities.forEach { identity in
            let importStatusCell = ImportStatusCell.instanceFromNib()
            importStatusCell.showIdentity(identity)
            stackView.addArrangedSubview(importStatusCell)
        }
        report.duplicateIdentities.forEach { identity in
            let importStatusCell = ImportStatusCell.instanceFromNib()
            importStatusCell.showDuplicateIdentity(identity)
            stackView.addArrangedSubview(importStatusCell)
        }
        report.failedIdentities.forEach { identityName in
            let importStatusCell = ImportStatusCell.instanceFromNib()
            importStatusCell.showFailedIdentity(identityName)

        }

    }

    private func renderRecipients(report: ImportedItemsReport) {
        if report.importedRecipients.count == 0 && report.duplicateRecipients.count == 0 && report.failedRecipients.count == 0 {
            return
        }
        let importStatusCell = ImportStatusCell.instanceFromNib()
        importStatusCell.showRecipient(imported: report.importedRecipients, duplicate: report.duplicateRecipients, failed: report.failedRecipients)
        stackView.addArrangedSubview(importStatusCell)
    }
}

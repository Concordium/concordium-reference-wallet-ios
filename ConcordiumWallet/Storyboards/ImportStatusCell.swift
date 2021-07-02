//
//  ImportStatusCell.swift
//  ConcordiumWallet
//
//  Created by Concordium on 13/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

class ImportStatusCell: UIView {
    
    @IBOutlet weak var idTitleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel! {didSet {idLabel.text = ""}}
    @IBOutlet weak var stackview: UIStackView!
    
    class func instanceFromNib() -> ImportStatusCell {
        // swiftlint:disable:next force_cast
        UINib(nibName: "ImportStatusCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ImportStatusCell
    }

    func showDuplicateIdentity(_ identity: ImportedIdentity) {
        showIdentity(identity, identityNamePostfix: "import.report.alreadyExistedPostfix".localized)
    }

    func showIdentity(_ identity: ImportedIdentity, identityNamePostfix: String? = nil) {
        idLabel.text = "\(identity.name)\(identityNamePostfix ?? "")"
        let accountsTitleLabel = createTitleLabel(text: "import.report.accountsTitle".localized)
        stackview.addArrangedSubview(accountsTitleLabel)
        let accountsLabel = createTextLabel()
        stackview.addArrangedSubview(accountsLabel)
        
        accountsLabel.text = identity.importedAccounts.joined(separator: "\n")
        accountsLabel.text = identity.duplicateAccounts.reduce(into: accountsLabel.text) { (first, second) in
            if first?.count ?? 0 > 0 {
                first = first! + "\n"
            }
            first = "\(first ?? "")\(second)\("import.report.alreadyExistedPostfix".localized)"
        }
        
        accountsLabel.text = identity.failedAccounts.reduce(into: accountsLabel.text) { (first, second) in
            if first?.count ?? 0 > 0 {
                first = first! + "\n"
            }
            first = "\(first ?? "")\(second)\("import.report.failedPostfix".localized)"
        }
        if identity.readOnlyAccounts.count > 0 {
            let accountsReadOnlyTitleLabel = createTitleLabel(text: "import.report.accountsReadonlyTitle".localized)
            stackview.addArrangedSubview(accountsReadOnlyTitleLabel)
            let accountsReadOnlyLabel = createTextLabel()
            stackview.addArrangedSubview(accountsReadOnlyLabel)
            accountsReadOnlyLabel.text = identity.readOnlyAccounts.joined(separator: "\n")
        }
    }

    private func createTextLabel() -> UILabel {
        let accountsLabel = UILabel()
        accountsLabel.textColor = .fadedText
        accountsLabel.font = .systemFont(ofSize: 14)
        accountsLabel.numberOfLines = 0
        return accountsLabel
    }

    private func createTitleLabel(text: String) -> UILabel {
        let accountsTitleLabel = UILabel()
        accountsTitleLabel.textColor = .fadedText
        accountsTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        accountsTitleLabel.text = text
        return accountsTitleLabel
    }

    func showFailedIdentity(_ identityName: String) {
        idLabel.text = "\(identityName)\("import.report.failedPostfix".localized)"
    }

    func showRecipient(imported: [String], duplicate: [String], failed: [String]) {
        idTitleLabel.removeFromSuperview()
        idLabel.text = "import.report.addressBookTitle".localized

        stackview.addArrangedSubview(createTitleLabel(text: "import.report.recipientAccountsTitle".localized))

        let recipientsLabel = createTextLabel()
        stackview.addArrangedSubview(recipientsLabel)

        var text = imported.joined(separator: "\n")
        if text.count > 0 {
            text += "\n"
        }
        if duplicate.count > 0 {
            text += "(\(duplicate.count) \("import.report.recipientAccountsAlreadyExisted".localized))"
        }
        if failed.count > 0 {
            text += "(\(duplicate.count) \("import.report.recipientAccountsFailed".localized)"
        }
        recipientsLabel.text = text
    }
}

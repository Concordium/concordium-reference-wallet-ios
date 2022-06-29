//
//  AccountCell.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/26/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol AccountCellDelegate: AnyObject {
    func perform(onCellRow: Int, action: AccountCardAction)
}

class AccountCell: UITableViewCell {

    @IBOutlet weak var accountCardView: AccountCardView!

    var cancellables: [AnyCancellable] = []
    weak var delegate: AccountCellDelegate?
    var cellRow: Int = 0
    
    override func awakeFromNib() {
        accountCardView.delegate = self
        clipsToBounds = false
        layer.masksToBounds = false
        contentView.layer.masksToBounds = false
    }
    
    func setup(accountViewModel: AccountViewModel) {
        accountViewModel.$state.sink { [weak self] state in
            switch state {
            case .finalized:
               self?.showStatusImage(nil)
            case .absent:
               self?.showStatusImage(UIImage(named: "problem_icon"))
            case .received, .committed:
               self?.showStatusImage(UIImage(named: "pending"))
            }
        }.store(in: &cancellables)
        accountCardView.setup(accountViewModel: accountViewModel)
    }
    
    func showStatusImage(_ image: UIImage?) {
        accountCardView.showStatusImage(image)
    }
        
    override func prepareForReuse() {
        cancellables = []
    }
    
}

extension AccountCell: AccountCardViewDelegate {
    
    func perform(action: AccountCardAction) {
        delegate?.perform(onCellRow: cellRow, action: action)
    }
}

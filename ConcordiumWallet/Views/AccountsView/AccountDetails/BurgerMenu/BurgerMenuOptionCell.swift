//
//  BurgerMenuOptionCell.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 28/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import UIKit

protocol BurgerMenuOptionCellDelegate: AnyObject {
    func selectedCellAt(row: Int)
}

class BurgerMenuOptionCell: UITableViewCell {
    private var cellRow: Int = 0
    private weak var delegate: BurgerMenuOptionCellDelegate?
    
    @IBOutlet weak var optionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(
        cellRow: Int,
        title: String,
        destructive: Bool,
        enabled: Bool,
        delegate: BurgerMenuOptionCellDelegate
    ) {
        self.cellRow = cellRow
        self.delegate = delegate
        optionButton.setTitle(title, for: .normal)
        optionButton.setTitleColor(destructive ? .error : .text, for: .normal)
        optionButton.setTitleColor(.fadedText, for: .disabled)
        if destructive {
            optionButton
                .applyConcordiumEdgeStyle(color: .error)
        } else if !enabled {
            optionButton
                .applyConcordiumEdgeStyle(color: .fadedText)
        }
        optionButton.isEnabled = enabled
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        delegate?.selectedCellAt(row: cellRow)
    }
}

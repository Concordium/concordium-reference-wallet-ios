//
//  IdentityCardView.swift
//  ConcordiumWallet
//
//  Concordium on 04/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol IdentityCardViewDelegate {
    func edit()
}

@IBDesignable
class IdentityCardView: UIView, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var expirationDateLabel: UILabel?
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var editIcon: UIImageView!
    
    var delegate: IdentityCardViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addEditListener()
    }
    
    private func addEditListener() {
        guard delegate != nil else {
            editIcon.isHidden = true
            return
        }
        
        let tapGetsure = UITapGestureRecognizer(target: self, action: #selector(self.editTapped))
        tapGetsure.numberOfTapsRequired = 1
        editIcon.gestureRecognizers = [ tapGetsure ]
        editIcon.isUserInteractionEnabled = true
    }
    
    @objc func editTapped() {
        delegate?.edit()
    }
}

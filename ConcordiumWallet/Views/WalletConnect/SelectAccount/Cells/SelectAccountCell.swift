//
//  SelectAccountCell.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 22.4.23.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit

class SelectAccountCell: UITableViewCell {
    
    // MARK: - Properties
    
    let accountLabel = UILabel()
    let identityLabel = UILabel()
    
    // MARK: - Memory Management
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, frame: CGRect) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .systemBackground
        
        self.frame = frame
        
        selectionStyle = .none
        
        loadSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Workflow
    
    private func loadSubviews() {
        // Container View
        let containerViewOriginX: CGFloat = 20.0
        let containerViewHeight: CGFloat = 90.0
        let containerView = UIView(frame: CGRect(x: containerViewOriginX, y: (height - containerViewHeight) / 2.0, width: width - 2 * containerViewOriginX, height: containerViewHeight))
        containerView.layer.cornerRadius = 10.0
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 0.5
        containerView.clipsToBounds = true
        contentView.addSubview(containerView)
        
        // Account Label
        let accountLabelOriginX: CGFloat = 10.0
        let accountLabelHeight: CGFloat = 30.0
        accountLabel.frame = CGRect(x: accountLabelOriginX, y: 0.0, width: 0.0, height: accountLabelHeight)
        accountLabel.textColor = .black
        accountLabel.text = "Account 2"
        accountLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        accountLabel.width = accountLabel.intrinsicContentSize.width
        containerView.addSubview(accountLabel)
        
        // Identity Label
        identityLabel.frame = CGRect(x: 0.0, y: accountLabel.originY, width: 0.0, height: accountLabel.height)
        identityLabel.textColor = .black
        identityLabel.text = "Identity 2"
        identityLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        identityLabel.originX = accountLabel.frame.maxX + 8.0
        identityLabel.width = identityLabel.intrinsicContentSize.width
        containerView.addSubview(identityLabel)
        
        // Total Label
        let totalLabelHeight: CGFloat = 30.0
        let totalLabel = UILabel(frame: CGRect(x: accountLabel.originX, y: accountLabel.frame.maxY, width: 0.0, height: totalLabelHeight))
        totalLabel.textColor = .black
        totalLabel.text = "Total"
        totalLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        totalLabel.width = totalLabel.intrinsicContentSize.width
        containerView.addSubview(totalLabel)
        
        // Total Value Label
        let totalValueLabel = UILabel(frame: CGRect(x: 0.0, y: totalLabel.originY, width: 0.0, height: totalLabel.height))
        totalValueLabel.textColor = .black
        totalValueLabel.text = "Ͼ0,00"
        totalValueLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        totalValueLabel.width = totalValueLabel.intrinsicContentSize.width
        totalValueLabel.originX = containerView.width - totalValueLabel.width - accountLabel.originX
        containerView.addSubview(totalValueLabel)
        
        // Disposal Label
        let disposalLabelHeight: CGFloat = 26.0
        let disposalLabel = UILabel(frame: CGRect(x: accountLabel.originX, y: totalLabel.frame.maxY, width: 0.0, height: disposalLabelHeight))
        disposalLabel.textColor = .black
        disposalLabel.text = "At disposal"
        disposalLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        disposalLabel.width = disposalLabel.intrinsicContentSize.width
        containerView.addSubview(disposalLabel)
        
        // Total Value Label
        let disposalValueLabel = UILabel(frame: CGRect(x: 0.0, y: disposalLabel.originY, width: 0.0, height: disposalLabel.height))
        disposalValueLabel.textColor = .black
        disposalValueLabel.text = "Ͼ0,00"
        disposalValueLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        disposalValueLabel.width = disposalValueLabel.intrinsicContentSize.width
        disposalValueLabel.originX = containerView.width - disposalValueLabel.width - accountLabel.originX
        containerView.addSubview(disposalValueLabel)
    }
}

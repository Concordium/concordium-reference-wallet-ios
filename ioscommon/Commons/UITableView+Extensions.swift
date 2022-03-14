//
//  UITableView+scroll.swift
//  sos-demo
//
//  Concordium on 22/10/2019.
//  Copyright © 2019 Ruxandra Nistor. All rights reserved.
//

import UIKit

extension UITableView {
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection: self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

    func sizeHeaderToFit() {
        if let headerView = tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame

            tableHeaderView = headerView
        }
    }
}

//
// Created by Concordium on 13/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol ShowToast: AnyObject {
    func showToast(withMessage toastMessage: String?, centeredIn view: UIView?, time: Double?)
}

extension ShowToast {
    func showToast(withMessage toastMessage: String?, centeredIn view: UIView? = (UIApplication.shared.delegate as? AppDelegate)?.window, time: Double? = 0.3) {
        OperationQueue.main.addOperation({
            let toastView = ToastLabel()
            toastView.text = toastMessage
            toastView.backgroundColor = UIColor.primary.withAlphaComponent(0.9)
            toastView.textAlignment = .center
            toastView.frame = CGRect(x: 0.0, y: 0.0, width: (view?.frame.size.width ?? 0.0) / 2.0, height: 70.0)
            toastView.layer.cornerRadius = 10
            toastView.layer.masksToBounds = true
            toastView.center = view?.center ?? CGPoint.zero
            toastView.minimumScaleFactor = 0.5
            toastView.numberOfLines = 0
            toastView.adjustsFontSizeToFitWidth = true
            toastView.setBottom((view?.frame.size.height ?? 30) - 30)

            view?.addSubview(toastView)
            UIView.animate(withDuration: 2.0, delay: time ?? 0.3, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}

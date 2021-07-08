//
//  LoadProtocol.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/24/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol Loadable: AnyObject {
    func showLoading()
    func hideLoading()
}

extension Loadable where Self: UIViewController {
    private func getMainView() -> UIView {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            return window
        }
        return view
    }
    
    private var activityIndicatorTag: Int {
        1122
    }

    private var eventCapturingViewTag: Int {
        1123
    }

    func showLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let mainView = self.getMainView()
            let eventCapturingView = UIView()
            eventCapturingView.frame = mainView.bounds
            eventCapturingView.backgroundColor = .clear
            mainView.addSubview(eventCapturingView)
            eventCapturingView.tag = self.eventCapturingViewTag

            let activityIndicatorView = UIActivityIndicatorView(style: .large)
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.tag = self.activityIndicatorTag
            eventCapturingView.addSubview(activityIndicatorView)
            activityIndicatorView.center = mainView.center
            activityIndicatorView.startAnimating()

        })
    }

    func hideLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let mainView: UIView = self.getMainView()
            if let activityIndicator = mainView.viewWithTag(self.activityIndicatorTag) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            mainView.viewWithTag(self.eventCapturingViewTag)?.removeFromSuperview()
        })
    }
}

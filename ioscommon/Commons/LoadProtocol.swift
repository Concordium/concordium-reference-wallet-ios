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
    var loadContainerView: UIView { get }
    var activityIndicatorTint: UIColor? { get }
}

extension Loadable {
    var activityIndicatorTint: UIColor? {
        nil
    }
    
    private var activityIndicatorTag: Int {
        1122
    }

    private var eventCapturingViewTag: Int {
        1123
    }

    func showLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
            guard let self = self else { return }
           
            let mainView = self.loadContainerView
            if mainView.viewWithTag(self.activityIndicatorTag) as? UIActivityIndicatorView != nil {
                return // we already show an activity Indicator
            }
            let eventCapturingView = UIView()
            eventCapturingView.frame = mainView.bounds
            eventCapturingView.backgroundColor = .clear
            mainView.addSubview(eventCapturingView)
            eventCapturingView.tag = self.eventCapturingViewTag

            let activityIndicatorView = UIActivityIndicatorView(style: .large)
            if let tint = self.activityIndicatorTint {
                activityIndicatorView.color = tint
            }
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.tag = self.activityIndicatorTag
            eventCapturingView.addSubview(activityIndicatorView)

            activityIndicatorView.center = mainView.center
            activityIndicatorView.startAnimating()

        })
    }

    func hideLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
            guard let self = self else { return }
            let mainView: UIView = self.loadContainerView
            if let activityIndicator = mainView.viewWithTag(self.activityIndicatorTag) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            mainView.viewWithTag(self.eventCapturingViewTag)?.removeFromSuperview()
        })
    }
}

extension Loadable where Self: UIViewController {
    var loadContainerView: UIView {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            return window
        }
        return view
    }
}

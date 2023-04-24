//
//  IdentityProviderWebViewViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 03/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import WebKit

class IdentityProviderWebViewFactory {
    class func create(with presenter: IdentityProviderWebViewPresenterProtocol) -> IdentityProviderWebViewViewController {
        IdentityProviderWebViewViewController.instantiate(fromStoryboard: "Identity") {coder in
            return IdentityProviderWebViewViewController(coder: coder, presenter: presenter)
        }
    }
}

class IdentityProviderWebViewViewController: BaseViewController, IdentityProviderWebViewViewProtocol, Storyboarded, Loadable {

	var presenter: IdentityProviderWebViewPresenterProtocol

    @IBOutlet weak var webview: WKWebView!
    
    init?(coder: NSCoder, presenter: IdentityProviderWebViewPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
        presenter.viewDidLoad()
        webview.navigationDelegate = self
    }

    func show(url: URLRequest) {
        webview.load(url)
    }
    
    @IBAction func close(_ sender: Any) {
        presenter.closeTapped()
    }
}

extension IdentityProviderWebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString, url.hasPrefix(ApiConstants.notabeneCallback) {
            presenter.receivedCallback(url)
            hideLoading()
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // If navigation fails we report error
        if !error.isAttemptedToLoadCallbackError {
            presenter.urlFailedToLoad(error: error)
        }
        hideLoading()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !error.isAttemptedToLoadCallbackError {
            presenter.urlFailedToLoad(error: error)
        }
        hideLoading()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoading()
    }
}

private extension Error {
    /*
     The web view will occasionally try to load the callback and fail.
     This can be used to filter out these errors.
     */
    var isAttemptedToLoadCallbackError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain
        && nsError.code == NSURLErrorUnsupportedURL
        && (failingURL?.absoluteString.hasPrefix(ApiConstants.notabeneCallback) ?? false)
    }
    
    private var failingURL: URL? {
        return (self as NSError).userInfo[NSURLErrorFailingURLErrorKey] as? URL
    }
}

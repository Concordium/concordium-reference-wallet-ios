//
//  OnboardingCarouselWebContentViewController.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 09/02/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import WebKit

final class OnboardingCarouselWebContentViewController: BaseViewController {

    private let htmlFilename: String
    private var webView: WKWebView?

    init(htmlFilename: String) {
        self.htmlFilename = htmlFilename
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.navigationDelegate = self
        loadLocalHTMLFile(with: htmlFilename)
    }

    private func loadLocalHTMLFile(with name: String) {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "html") else { return }
        webView?.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl)
        webView?.load(URLRequest(url: fileUrl))
    }
}

// MARK: - WKNavigationDelegate
extension OnboardingCarouselWebContentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'")
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none'")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url {
            if UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url, options: [:])
                return .cancel
            }
        }
        return .allow
    }

}

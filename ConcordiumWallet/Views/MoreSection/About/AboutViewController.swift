//
//  AboutViewController.swift
//  Mock
//
//  Created by Carsten Nørby on 18/02/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

class AboutFactory {
    class func create(with presenter: AboutPresenter) -> AboutViewController {
        AboutViewController.instantiate(fromStoryboard: "More") { coder in
            return AboutViewController(coder: coder, presenter: presenter)
        }
    }
}

class AboutViewController: BaseViewController, AboutViewProtocol, Storyboarded, UITextViewDelegate {
    var presenter: AboutPresenterProtocol

    let linkDiscord = "https://www.google.com"
    let linkTelegram = ""
    
    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var supportTextView: UITextView!
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var privateTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    init?(coder: NSCoder, presenter: AboutPresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "more.about".localized
        presenter.view = self
        presenter.viewDidLoad()
        
        // Note the spaces since we only want to insert links at the exact match in the orginal text.
        let links = ["Discord  ": "https://discord.com/invite/xWmQ5tp",
                     "Telegram  ": "https://t.me/concordium_official",
                     "support@concordium.com": "mailto:support@concordium.com",
                     "contact@concordium.com": "mailto:contact@concordium.com"]

        let supportText = "more.about.support.text".localized
        supportTextView.addHyperLinksToText(originalText: supportText, hyperLinks: links)
        supportTextView.textContainerInset = UIEdgeInsets.zero
        supportTextView.textContainer.lineFragmentPadding = 0
        supportTextView.delegate = self

        let contactText = "more.about.contact.text".localized
        contactTextView.addHyperLinksToText(originalText: contactText, hyperLinks: links)
        contactTextView.textContainerInset = UIEdgeInsets.zero
        contactTextView.textContainer.lineFragmentPadding = 0
        contactTextView.delegate = self
        
        let privacyText = "more.about.privacy.text".localized
        privateTextView.addHyperLinksToText(originalText: privacyText, hyperLinks: links)
        privateTextView.textContainerInset = UIEdgeInsets.zero
        privateTextView.textContainer.lineFragmentPadding = 0
        privateTextView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+300)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith link: URL, in characterRange: NSRange) -> Bool {
        if link.absoluteString.contains("@") {
            UIApplication.shared.open(link)
        } else {
            UIApplication.shared.open(link)
        }
        return false
    }
}

extension UITextView {

  func addHyperLinksToText(originalText: String, hyperLinks: [String: String]) {
    let font = Fonts.body
    let color = UIColor.systemBlue
    
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    let attributedOriginalText = NSMutableAttributedString(string: originalText)
    for (hyperLink, urlString) in hyperLinks {
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: font, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.fadedText, range: fullRange)
    }

    self.linkTextAttributes = [
        NSAttributedString.Key.foregroundColor: color,
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    self.attributedText = attributedOriginalText
  }
}

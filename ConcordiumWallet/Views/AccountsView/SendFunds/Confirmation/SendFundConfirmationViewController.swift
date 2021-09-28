//
//  SendFundConfirmationViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 29/05/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class SendFundConfirmationFactory {
    class func create(with presenter: SendFundConfirmationPresenter) -> SendFundConfirmationViewController {
        SendFundConfirmationViewController.instantiate(fromStoryboard: "SendFund") { coder in
            return SendFundConfirmationViewController(coder: coder, presenter: presenter)
        }
    }
}

class SendFundConfirmationViewController: BaseViewController, SendFundConfirmationViewProtocol, Storyboarded {
    var presenter: SendFundConfirmationPresenterProtocol
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!
    @IBOutlet weak var line4: UILabel!
    @IBOutlet weak var line5: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var shieldedWaterMark: UIImageView!
    
    var line1Text: String? {
        didSet {
            line1.text = line1Text
        }
    }

    var line2Text: String? {
        didSet {
            line2.text = line2Text
        }
    }
    
    var line3Text: String? {
        didSet {
            line3.text = line3Text
        }
    }
    
    var line4Text: String? {
        didSet {
            line4.text = line4Text
        }
    }
    
    var line5Text: String? {
        didSet {
            line5.text = line5Text
        }
    }
    
    var buttonText: String? {
        didSet {
            sendButton.setTitle(buttonText, for: .normal)
        }
    }
    
    var visibleWaterMark: Bool = false {
        didSet {
            shieldedWaterMark.isHidden = !visibleWaterMark
        }
    }

    init?(coder: NSCoder, presenter: SendFundConfirmationPresenterProtocol) {
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
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        presenter.userTappedConfirm()
    }
}

//
//  SupportMailViewController.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 12/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import MessageUI
import UIKit

class SupportMailViewController: MFMailComposeViewController {

    required init(recipients: [String], subject: String, body: String) {
        super.init(nibName: nil, bundle: nil)
        setToRecipients(recipients)
        setSubject(subject)
        setMessageBody(body, isHTML: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

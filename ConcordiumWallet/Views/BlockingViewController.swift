//
//  LaunchScreenViewController.swift
//  ConcordiumWallet
//
//  Created by Dennis Kristensen on 02/06/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

class BlockingViewController: UIViewController {

    var concordiumSplash: UIImageView!
    var concordiumLogo: UIImageView!
    var concordiumtitle: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        concordiumSplash = UIImageView(image: UIImage(named: "concordium_splash")!)
        concordiumLogo = UIImageView(image: UIImage(named: "concordium_logo")!)
        concordiumtitle = UIImageView(image: UIImage(named: "concordium_title")!)

        view.backgroundColor = UIColor.clear
        view.addSubview(concordiumSplash)
        view.addSubview(concordiumLogo)
        view.addSubview(concordiumtitle)

        concordiumLogo.translatesAutoresizingMaskIntoConstraints = false
        concordiumLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        concordiumLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        concordiumtitle.translatesAutoresizingMaskIntoConstraints = false
        concordiumtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        concordiumtitle.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
    }
}

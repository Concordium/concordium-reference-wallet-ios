//
//  BlockingViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 02/06/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import UIKit

class BlockingViewController: UIViewController {

    var concordiumSplash: UIImageView!
    var concordiumLogo: UIImageView!
    var concordiumtitle: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        concordiumSplash = UIImageView(image: UIImage(named: "concordium_splash")!)
        concordiumSplash.translatesAutoresizingMaskIntoConstraints = false

        concordiumLogo = UIImageView(image: UIImage(named: "concordium_logo")!)
        concordiumLogo.translatesAutoresizingMaskIntoConstraints = false

        concordiumtitle = UIImageView(image: UIImage(named: "concordium_title")!)
        concordiumtitle.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = UIColor.clear
        view.addSubview(concordiumSplash)
        view.addSubview(concordiumLogo)
        view.addSubview(concordiumtitle)

        NSLayoutConstraint.activate([
            concordiumLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            concordiumLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            concordiumSplash.topAnchor.constraint(equalTo: view.topAnchor),
            concordiumSplash.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            concordiumSplash.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            concordiumSplash.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            concordiumtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.bottomAnchor.constraint(equalTo: concordiumtitle.bottomAnchor, constant: 40)
        ])
    }
}

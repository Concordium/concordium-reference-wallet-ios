//
//  ImportViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 15/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

// MARK: View
protocol ImportViewProtocol: class {

}

class ImportFactory {
    class func create() -> ImportViewController {
        ImportViewController.instantiate(fromStoryboard: "More")
    }
}

class ImportViewController: BaseViewController, Storyboarded {
}

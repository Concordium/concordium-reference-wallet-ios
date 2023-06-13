//
//  WCDebugViewController.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 13/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit
import Web3Wallet

class WCDebugViewController: UITableViewController {
    private var sessions: [Session] = []
    private var pairings: [Pairing] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let metadata = AppMetadata(
            name: "Concordium",
            description: "Concordium - Blockchain Wallet",
            url: "wallet.connect",
            icons: [],
            verifyUrl: "verify.walletconnect.com"
        )

        Pair.configure(metadata: metadata)
        Networking.configure(projectId: "76324905a70fe5c388bab46d3e0564dc", socketFactory: SocketFactory())

        sessions = Sign.instance.getSessions()
        pairings = Pair.instance.getPairings()
    }
}

extension WCDebugViewController {
    enum Sections: Int, CaseIterable {
        case sessions
        case pairings

        var title: String {
            switch self {
            case .sessions: return "Sessions"
            case .pairings: return "Pairings"
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Sections(rawValue: section)?.title ?? "-none-"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .pairings: return pairings.count
        case .sessions: return sessions.count
        default: return 0
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { Sections.allCases.count }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            tableView.beginUpdates()
            cell.textLabel?.numberOfLines = cell.textLabel?.numberOfLines == 0 ? 3 : 0
            tableView.endUpdates()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 3
        switch Sections(rawValue: indexPath.section) {
        case .pairings:
            var str = """
            topic \(pairings[indexPath.row].topic)
            
            expiryDate \(pairings[indexPath.row].expiryDate)
            
            peer \(String(describing: pairings[indexPath.row].peer))
            
            """
            cell.textLabel?.text = str
            return cell
        case .sessions:
            var str = """
            pairingTopic \(sessions[indexPath.row].pairingTopic)
            
            topic \(sessions[indexPath.row].topic)
            
            peer \(sessions[indexPath.row].peer)
            
            expiryDate \(sessions[indexPath.row].expiryDate)
            
            namespaces \(sessions[indexPath.row].namespaces)
            """
            cell.textLabel?.text = str
            return cell
        default: return cell
        }
    }
}

//
//  WCDebugViewController.swift
//  ConcordiumWallet
//

import Combine
import SwiftUI
import UIKit
import Web3Wallet

// MARK: - WCDebugViewController

class WCDebugViewController: UIViewController {
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
        addSwiftUIViewToController(WCDebugView())
    }
}

// MARK: - WCDebugView

fileprivate struct WCDebugView: View {
    @State var sessions: [Session]
    @State var pairings: [Pairing]

    private var cancellables: [AnyCancellable] = []
    init() {
        self.sessions = Sign.instance.getSessions()
        self.pairings = Pair.instance.getPairings()
    }

    var body: some View {
        ScrollView {
            VStack {
                Text("sessions").fontWeight(.bold)
                if sessions.isEmpty {
                    Text("No active session ❌").padding()
                } else {
                    ForEach(sessions.indices, id: \.self) { i in
                        SessionItem(session: sessions[i])
                    }
                }
                
                Text("pairings").fontWeight(.bold)
                if pairings.isEmpty {
                    Text("No pairing ❌").padding()
                } else {
                    ForEach(pairings.indices, id: \.self) { i in
                        PairingItem(pairing: pairings[i]) {
                            Task {
                                do {
                                    try await Pair.instance.disconnect(topic: pairings[i].topic)
                                    pairings.remove(at: i)
                                } catch let error {
                                    print(error)
                                }
                            }
                        }
                    }
                }
               
            }
        }
        .onReceive(Sign.instance.sessionsPublisher) { sessions in
            self.sessions = sessions
    
        }
    }

    // MARK: - SessionItem

    fileprivate struct SessionItem: View {
        @State var isExpanded = false
        var session: Session
        var body: some View {
            HStack(alignment: .center) {
                VStack {
                    buildDataCell(title: "topic", content: session.topic)
                    if isExpanded {
                        buildDataCell(title: "pairingTopic", content: String(describing: session.pairingTopic))
                        buildDataCell(title: "peer", content: String(describing: session.peer))
                        buildDataCell(title: "namespaces", content: String(describing: session.namespaces))
                        buildDataCell(title: "expiry date", content: String(describing: session.expiryDate))

                    }
                    Divider()
                }
                Button(action: {
                    Task {
                        try await Sign.instance.disconnect(topic: session.topic)
                    }
                }) {
                    Image(systemName: "xmark.circle.fill") // << base !!
                        .resizable()
                        .frame(width: 24, height: 24) // << for demo
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .padding([.top, .bottom], 4)
            .padding(.trailing, 8)
        }

        func buildDataCell(
            title: String,
            content: String
        ) -> some View {
            HStack(alignment: .top) {
                Text(title)
                    .font(.footnote)
                    .frame(width: 75)
                    .font(.custom("Courier New", fixedSize: 14))
                    .textSelection(.enabled)
                Divider()
                Text(content)
            }
            .padding(4)
        }
    }

    // MARK: - PairingItem

    fileprivate struct PairingItem: View {
        @State var isExpanded = false
        var pairing: Pairing
        var action: (() -> Void)
        var body: some View {
            HStack(alignment: .center) {
                VStack {
                    buildDataCell(title: "topic", content: pairing.topic)
                    if isExpanded {
                        buildDataCell(title: "peer", content: String(describing: pairing.peer))
                        buildDataCell(title: "expiryDate", content: String(describing: pairing.expiryDate))
                    }
                    Divider()
                }
                Button(action: action) {
                    Image(systemName: "xmark.circle.fill") // << base !!
                        .resizable()
                        .frame(width: 24, height: 24) // << for demo
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            .padding([.top, .bottom], 4)
            .padding(.trailing, 8)
        }

        func buildDataCell(
            title: String,
            content: String
        ) -> some View {
            HStack(alignment: .top) {
                Text(title)
                    .font(.footnote)
                    .frame(width: 75)
                    .font(.custom("Courier New", fixedSize: 14))
                    .textSelection(.enabled)
                Divider()
                Text(content)
            }
            .padding(4)
        }
    }
}

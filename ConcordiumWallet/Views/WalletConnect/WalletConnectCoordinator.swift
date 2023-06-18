import Combine
import SwiftUI
import UIKit
import Web3Wallet

struct CreateAccountTransactionInput: Codable {
    var expiry: UInt64?
    var from: String?
//    var keys: AccountData
//    var nonce: Int
//    var payload: Payload
    var type: String?
}

class WalletConnectCoordinator: Coordinator {
    typealias DependencyProvider = AccountsFlowCoordinatorDependencyProvider
    
    private var cancellables: Set<AnyCancellable> = []
    private var dependencyProvider: DependencyProvider
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController, dependencyProvider: DependencyProvider, parentCoodinator: Coordinator) {
        self.dependencyProvider = dependencyProvider
        self.navigationController = navigationController

        let metadata = AppMetadata(
            name: "Concordium",
            description: "Concordium - Blockchain Wallet",
            url: "wallet.connect",
            icons: [],
            verifyUrl: "verify.walletconnect.com"
        )
        Pair.configure(metadata: metadata)
        Networking.configure(projectId: "76324905a70fe5c388bab46d3e0564dc", socketFactory: SocketFactory())

        setupWalletConnectRequestBinding()
        setupWalletConnectProposalBinding()
        setupWalletConnectSettleBinding()
    }

    func start() {
        showWalletConnectScanner()
    }
}

// MARK: - WalletConnect

private extension WalletConnectCoordinator {
    func setupWalletConnectProposalBinding() {
        // TODO: Define a service for WalletConnect that tracks the currently open sessions (similarly to what dapp-libraries do on the client side...).

        // TODO: Don't allow going back to views corresponding to previous states.

        // Register handlers for WalletConnect events.

        // Handler for session proposals, i.e. requests for connections to be established.
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { failure in
                print(failure) // TODO: should we handle error?
            }, receiveValue: { [weak self] proposal, _ in

                guard let self = self else { return }
                print("DEBUG: \(self) Session \(proposal) proposed")

                // TODO: Auto-reject proposal if namespaces doesn't exactly match expected chain/method/event.
                //      And show user appropriate error...

                let viewModel = WalletConnectAccountSelectViewModel(
                    storageManager: self.dependencyProvider.storageManager(),
                    proposal: proposal
                )

                viewModel.didSelect = { account in
                    self.navigationController.pushViewController(
                        UIHostingController(
                            rootView: WalletConnectApprovalView(
                                title: "walletconnect.connect.approve.title".localized,
                                subtitle: "walletconnect.connect.approve.subtitle".localizedNonempty,
                                contentView: WalletConnectProposalApprovalView(
                                    accountName: account.address,
                                    proposal: proposal.proposalData
                                ),
                                viewModel: .init(
                                    didAccept: {
                                        Task {
                                            do {
                                                try await Sign.instance.approve(
                                                    proposalId: proposal.id,
                                                    namespaces: [ // TODO: un-hardcode
                                                        "ccd": SessionNamespace(
                                                            chains: [Blockchain("ccd:testnet")!],
                                                            accounts: [Account("ccd:testnet:\(account.address)")!],
                                                            methods: ["sign_and_send_transaction", "sign_message"],
                                                            events: ["chain_changed", "accounts_changed"]
                                                        ),
                                                    ])
                                            } catch {
                                                print("ERROR: approval of connection failed: \(error)")
                                            }
                                        }
                                    },
                                    didDecline: {
                                        // User declined the request to connect: Reject it.
                                        Task {
                                            do {
                                                try await Sign.instance.reject(proposalId: proposal.id, reason: .userRejected)
                                                //                                                try await Sign.instance.disconnect(topic: proposal)
                                            } catch let error {
                                                print("ERROR: rejection of connection failed: \(error)")
                                            }
                                        }

                                        // Pop the VC without waiting for rejection to complete.
                                        self.navigationController.setNavigationBarHidden(false, animated: false)
                                        self.navigationController.popToRootViewController(animated: true)
                                    }
                                )
                            )
                        ),
                        animated: true
                    )
                }
                let viewController = WalletConnectAccountSelectViewController(viewModel: viewModel)
                self.navigationController.setNavigationBarHidden(true, animated: false)
                self.navigationController.pushViewController(viewController, animated: true)

            })
            .store(in: &cancellables)
    }

    private func setupWalletConnectSettleBinding() {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { session in
                print("DEBUG: Session \(session.pairingTopic) settled")

                // Connection established: Open "connected" screen.
                self.navigationController.pushViewController(
                    UIHostingController(
                        rootView: WalletConnectConnectedView(
                            dappName: "TODO", accountName: "TODO", didDisconnect: {
                                // User clicked the disconnect button.
                                Task {
                                    do {
                                        try await Sign.instance.disconnect(topic: session.topic)
                                    } catch let error {
                                        print("ERROR: cannot disconnect: \(error)")
                                    }
                                }
                                // Pop the VC without waiting for disconnect to complete.
                                self.navigationController.setNavigationBarHidden(false, animated: false)
                                self.navigationController.popToRootViewController(animated: true)
                            }
                        )
                    ),
                    animated: true
                )
            }
            .store(in: &cancellables)
    }

    func authorize(request: Request) {
//        var encryptedAccountDataKey 
        // var encryptionKeyKey = account.encryptedPrivateKey
        // let accountKeys = try? dependencyProvider.storageManager().getPrivateAccountKeys(key: encryptedAccountDataKey, pwHash: pwHash).get(),
        var params = request.params.value as? [String: Any]
//                            var keys = dependencyProvider.storageManager().getPrivateAccountKeys(key: String, pwHash: T##String)
        var input = CreateAccountTransactionInput(
            expiry: request.expiry,
            from: params?["sender"] as? String,
            type: params?["type"] as? String
        )
        print(input)
//                            let response = dependencyProvider.mobileWallet().createAccountTransfer(input: )
//                            Sign.instance.respond(topic: request.topic, requestId: request.id, response: response)
    }

    func setupWalletConnectRequestBinding() {
        // Handler for incoming requests on established connection.
        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] request, _ in
                print("DEBUG: Incoming request: \(request)")
                self?.navigationController.pushViewController(UIHostingController(
                    rootView: WalletConnectActionRequestView(
                        didAccept: { [weak self] in
                            self?.authorize(request: request)
                        }, didReject: {
//                            Sign.instance.respond(topic: request.topic, requestId: request.id, response: )
                        },
                        request: request
                    )
                ), animated: true)
            }
            .store(in: &cancellables)
    }
}


extension WalletConnectCoordinator: WalletConnectDelegate {
    fileprivate func setupBindings() {
        // For now we just print the following events.
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { sessionId, reason in
                // Called when the dApp disconnects - not when we do ourselves!
                print("DEBUG: Session \(sessionId) deleted with reason \(reason)")
                
                // Connection lost or disconnected: Pop "connected" screen.
                // TODO: Only do this if we're actually on that screen (i.e. the deleted session matches the currently connected one).
                self.navigationController.setNavigationBarHidden(false, animated: false)
                self.navigationController.popToRootViewController(animated: true)
            }
            .store(in: &cancellables)
        
        Sign.instance.sessionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                print("DEBUG: Session event: \(event)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionExtendPublisher
            .receive(on: DispatchQueue.main)
            .sink { sessionTopic, date in
                print("DEBUG: Session \(sessionTopic) extended until \(date)")
            }
            .store(in: &cancellables)
        
        Sign.instance.sessionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { sessionTopic, _ in
                print("DEBUG: Session \(sessionTopic) updated")
            }
            .store(in: &cancellables)
        Sign.instance.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { status in
                print("DEBUG: Socket connection status update: \(status)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("DEBUG: Response: \(response)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { proposal, reason in
                print("DEBUG: Proposal \(proposal) rejected with reason \(reason)")
            }
            .store(in: &cancellables)
        
        Sign.instance.pingResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { ping in
                print("DEBUG: Ping: \(ping)")
            }
            .store(in: &cancellables)
    }
    
    func showWalletConnectScanner() {
//        // Temporarily use hardcoded connection string rather than scanning QR code.
//        // Unsure why, but if we clear pairings and instantiate this one, it seems to connect without the proposal thing...
//        let wc = "wc:39e17f8223d80748d56e528c6715f211afd3b4e0dee4ac887a79d644308d157a@2?relay-protocol=irn&symKey=c370924b1dd87b047fc8726f33d80adecc41f350635979bfbe597c58fcf5f2bd"


        // Show QR code scanner.
        let vc = ScanQRViewControllerFactory.create(
            with: ScanQRPresenter(
                didScanQrCode: { [weak self] value in
                    // TODO: Can do more detailed check?
                    if !value.hasPrefix("wc:") {
                        return false
                    }
                    // Successfully scanner WalletConnect QR.
                    Task {
                        do {
                            try await Pair.instance.pair(uri: WalletConnectURI(string: value)!)
                        } catch let error {
                            print("ERROR: cannot pair: \(error)")
                        }
                    }
                    self?.navigationController.popViewController(animated: true)
                    return true
                }
            )
        )
        navigationController.pushViewController(vc, animated: true)
    }
}

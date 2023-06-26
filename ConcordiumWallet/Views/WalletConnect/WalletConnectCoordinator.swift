import Combine
import SwiftUI
import UIKit
import Web3Wallet

enum SchemaType: String, Decodable {
    case moduleSchema = "module"
    case parameterSchema = "parameter"
}

enum SchemaVersion: Int, Decodable {
    case v0 = 0
    case v1 = 1
    case v2 = 2
}

enum Schema: Decodable {
    case moduleSchema(value: String, version: SchemaVersion?)
    case typeSchema(value: String)

    enum CodingKeys: String, CodingKey {
        case type, value, version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SchemaType.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)
        switch type {
        case .moduleSchema:
            let version = try container.decode(SchemaVersion.self, forKey: .version)
            self = .moduleSchema(value: value, version: version)
        case .parameterSchema:
            self = .typeSchema(value: value)
        }
    }
}

// MARK: - Payload

struct ContractUpdatePayload: Codable {
    let amount: String
    let address: Address
    let receiveName: String
    let maxContractExecutionEnergy: Int
    let message: String
}

// MARK: - Address

struct Address: Codable {
    let index, subindex: Int
}

struct ContractUpdateParams: Decodable {
    let schema: Schema
    let type: TransferType
    let sender: String
    let payload: ContractUpdatePayload
    enum CodingKeys: String, CodingKey {
        case schema, type, sender, payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(TransferType.self, forKey: .type)
        sender = try container.decode(String.self, forKey: .sender)
        let payloadData = try Data(container.decode(String.self, forKey: .payload).utf8)
        payload = try JSONDecoder().decode(ContractUpdatePayload.self, from: payloadData)
        // TODO: Check what the version should be if that's a string
        if let schema = try? container.decode(Schema.self, forKey: .schema) {
            self.schema = schema
        } else {
            schema = .moduleSchema(value: try container.decode(String.self, forKey: .schema), version: nil)
        }
    }
}

enum WalletConenctError: Error {
    case unknownError
}

protocol WalletConnectCoordiantorDelegate: AnyObject {
    func dismissWalletConnectCoordinator()
}

class WalletConnectCoordinator: Coordinator {
    typealias DependencyProvider = AccountsFlowCoordinatorDependencyProvider

    private var cancellables: Set<AnyCancellable> = []
    private var dependencyProvider: DependencyProvider
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: WalletConnectCoordiantorDelegate?
    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        dependencyProvider: DependencyProvider,
        parentCoordiantor: WalletConnectCoordiantorDelegate
    ) {
        self.dependencyProvider = dependencyProvider
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordiantor

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

    deinit {
        Sign.instance.getSessions().forEach { session in
            Task {
                do {
                    try await Sign.instance.disconnect(topic: session.topic)
                } catch let error {
                    print("WalletConnect: Deinitializing WalletConnectCoordinator: Error disconnecting session with topic '\(session.topic)': \(error)")
                }
            }
        }
        Pair.instance.getPairings().forEach { pairing in
            Task {
                do {
                    try await Pair.instance.disconnect(topic: pairing.topic)
                } catch let error {
                    print("WalletConnect: Deinitializing WalletConnectCoordinator: Error disconnecting pairing with topic '\(pairing.topic)': \(error)")
                }
            }
        }
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
                                            } catch let error {
                                                self.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
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
                                                self.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
                                            }
                                        }

                                        // Pop the VC without waiting for rejection to complete.
                                        self.navigationController.popToRootViewController(animated: true)
                                    }
                                )
                            )
                        ),
                        animated: true
                    )
                }
                let viewController = WalletConnectAccountSelectViewController(viewModel: viewModel)
                self.navigationController.pushViewController(viewController, animated: true)

            })
            .store(in: &cancellables)
    }

    private func setupWalletConnectSettleBinding() {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                print("DEBUG: Session \(session.pairingTopic) settled")
                guard let ccdNamespace = session.namespaces["ccd"], session.namespaces.count == 1 else {
                    self?.navigationController.popToRootViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Unexpected namespaces")
                    self?.parentCoordinator?.dismissWalletConnectCoordinator()
                    return
                }

                guard ccdNamespace.accounts.first?.address != nil, ccdNamespace.accounts.count == 1 else {
                    self?.navigationController.popToRootViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Unexpected number of accounts")
                    self?.parentCoordinator?.dismissWalletConnectCoordinator()
                    return
                }

                // Connection established: Open "connected" screen.
                self?.navigationController.pushViewController(
                    UIHostingController(
                        rootView: WalletConnectConnectedView(
                            dappName: "TODO",
                            accountName: "TODO",
                            didDisconnect: {
                                // User clicked the disconnect button.
                                Task {
                                    do {
                                        try await Sign.instance.disconnect(topic: session.topic)
                                    } catch let error {
                                        self?.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
                                    }
                                }
                                // Pop the VC without waiting for disconnect to complete.
                                self?.navigationController.popToRootViewController(animated: true)
                                self?.parentCoordinator?.dismissWalletConnectCoordinator()
                            }
                        )
                    ),
                    animated: true
                )
            }
            .store(in: &cancellables)
    }

    func authorize(request: Request) {
        guard let session = Sign.instance.getSessions().first(where: { $0.topic == request.topic }) else {
            self.navigationController.popViewController(animated: true)
            self.presentError(with: "errorAlert.title".localized, message: "Session not found")
            return
        }

        guard session.namespaces.count == 1 else {
            self.navigationController.popViewController(animated: true)
            self.presentError(with: "errorAlert.title".localized, message: "Incorect number of namespaces")
            return
        }

        guard let ccdNamespace = session.namespaces["ccd"]  else {
            self.navigationController.popViewController(animated: true)
            self.presentError(with: "errorAlert.title".localized, message: "ccd namespace not found")
            return
        }

        guard let accountAddress = ccdNamespace.accounts.first?.address, ccdNamespace.accounts.count == 1 else {
            self.navigationController.popViewController(animated: true)
            self.presentError(with: "errorAlert.title".localized, message: "Incorect number of namespaces")
            return
        }
        
        guard let account = dependencyProvider.storageManager().getAccount(withAddress: accountAddress) else {
            guard session.namespaces.count == 1 else {
                self.navigationController.popViewController(animated: true)
                self.presentError(with: "errorAlert.title".localized, message: "Account with address \(accountAddress) not found")
                return
            }
            return
        }
        var transfer = TransferDataTypeFactory.create()

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: request.params.value, options: [])
            let params = try JSONDecoder().decode(ContractUpdateParams.self, from: jsonData)

            guard case TransferType.contractUpdate = params.type else {
                self.navigationController.popViewController(animated: true)
                self.presentError(with: "errorAlert.title".localized, message: "Unsupported transaction type (only Update is supported)")
                return
            }
            guard !params.sender.isEmpty else {
                self.navigationController.popViewController(animated: true)
                self.presentError(with: "errorAlert.title".localized, message: "Empty sender")
                return
            }
            transfer.transferType = params.type
            transfer.fromAddress = params.sender
            transfer.nonce = account.accountNonce
            transfer.payload = .contractUpdatePayload(params.payload)
            transfer.energy = params.payload.maxContractExecutionEnergy

            let result = dependencyProvider.transactionsService().performTransfer(transfer, from: account, requestPasswordDelegate: self)
            result.sink(receiveError: { [weak self] error in
                print("WC->error \(error)")
                Task {
                    do {
                        try await Sign.instance.respond(topic: session.topic, requestId: request.id, response: .error(.init(code: 1337, message: error.localizedDescription)))
                    } catch let error {
                        self?.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
                    }
                }
                self?.navigationController.popViewController(animated: true)
            }, receiveValue: { [weak self] success in
                print("WC->success \(success)")
                Task {
                    do {
                        try await Sign.instance.respond(topic: session.topic, requestId: request.id, response: .response(AnyCodable(success.submissionId)))
                    } catch let error {
                        self?.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
                    }
                }
                self?.navigationController.popViewController(animated: true)
            })
            .store(in: &cancellables)

        } catch let exepction {
            print("WC-exception \(exepction)")
            self.navigationController.popViewController(animated: true)
            self.presentError(with: "errorAlert.title".localized, message: exepction.localizedDescription)
        }
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
                            print("WC->info request rejected")
                            Task {
                                do {
                                    try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .error(.init(code: 5000, message: "User rejected")))
                                } catch let error {
                                    self?.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
                                }
                            }
                            self?.navigationController.popViewController(animated: true)
                        },
                        request: request
                    )
                ), animated: true)
            }
            .store(in: &cancellables)
    }
}

extension WalletConnectCoordinator: WalletConnectDelegate {
    private func setupBindings() {
        // For now we just print the following events.
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionId, reason in
                // Called when the dApp disconnects - not when we do ourselves!
                print("DEBUG: Session \(sessionId) deleted with reason \(reason)")

                // Connection lost or disconnected: Pop "connected" screen.
                // TODO: Only do this if we're actually on that screen (i.e. the deleted session matches the currently connected one).
                self?.navigationController.popToRootViewController(animated: true)
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
        let vc = ScanQRViewControllerFactory.create(
            with: ScanQRPresenter(
                didScanQrCode: { [weak self] value in
                    // TODO: Can do more detailed check?
                    if !value.hasPrefix("wc:") {
                        return false
                    }
                    Task {
                        do {
                            try await Pair.instance.pair(uri: WalletConnectURI(string: value)!)

                        } catch let error {
                            self?.presentError(with: "errorAlert.title".localized, message: error.localizedDescription)
                        }
                    }
                    self?.navigationController.popViewController(animated: true)
                    return true
                }
            )
        )
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentError(with title: String, message: String)  {
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "errorAlert.okButton".localized, style: .default))
        self.navigationController.present(ac, animated: true)
    }
}

extension WalletConnectCoordinator: RequestPasswordDelegate {}

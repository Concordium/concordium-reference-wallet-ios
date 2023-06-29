import Combine
import SwiftUI
import UIKit
import Web3Wallet

let CONCORDIUM_WALLET_CONNECT_PROJECT_ID = "76324905a70fe5c388bab46d3e0564dc"

// See https://docs.walletconnect.com/2.0/specs/clients/sign/error-codes for official error codes.
struct WalletConnectErrors {
    static func userRejected() -> JSONRPCError {
        JSONRPCError(code: 5000, message: "User rejected")
    }

    
    static func transactionFailed(_ data: AnyCodable) -> JSONRPCError {
        JSONRPCError(code: 10000, message: "Transaction failed", data: data)
    }
    
    static func noSessionForTopic(with request: Request) -> JSONRPCError {
        JSONRPCError(code: 7001, message: "No session for topic \(request.topic)")
    }

    static func unsupportedNamespaceKey() -> JSONRPCError {
        JSONRPCError(code: 5104, message: "Unsupported namespace key")
    }
    
    static func unsupportedAccounts() -> JSONRPCError {
        JSONRPCError(code: 5103, message: "Unsupported accounts")
    }
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
        parentCoordinator = parentCoordiantor

        let metadata = AppMetadata(
            name: "Concordium",
            description: "Concordium - Blockchain Wallet",
            url: "wallet.connect",
            icons: [],
            verifyUrl: "verify.walletconnect.com"
        )
        Pair.configure(metadata: metadata)
        Networking.configure(projectId: CONCORDIUM_WALLET_CONNECT_PROJECT_ID, socketFactory: SocketFactory())
        setupWalletConnectRequestBinding()
        setupWalletConnectProposalBinding()
        setupWalletConnectSettleBinding()
        setupDebugBindings()
    }

    func start() {
        showWalletConnectScanner()
    }
    
    deinit {
        // TODO Extract the following into "nuke" function that may also be called from here (as a safeguard).
        Sign.instance.getSessions().forEach { session in
            Task {
                do {
                    try await Sign.instance.disconnect(topic: session.topic)
                } catch let err {
                    print("ERROR: WalletConnect: Deinitializing WalletConnectCoordinator: Cannot disconnect session with topic '\(session.topic)': \(err)")
                }
            }
        }
        Pair.instance.getPairings().forEach { pairing in
            Task {
                do {
                    try await Pair.instance.disconnect(topic: pairing.topic)
                } catch let err {
                    print("ERROR: WalletConnect: Deinitializing WalletConnectCoordinator: Cannot disconnect pairing with topic '\(pairing.topic)': \(err)")
                }
            }
        }
    }
}

// MARK: - WalletConnect

private extension WalletConnectCoordinator {
    func setupWalletConnectProposalBinding() {
        // TODO: Define a service for WalletConnect that tracks the currently open sessions (similarly to what dapp-libraries do on the client side...).

        // Register handlers for WalletConnect events.

        // Handler for session proposals, i.e. requests for connections to be established.
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] proposal, _ in

                guard let self = self else { return }
                print("DEBUG: WalletConnect: \(self) Session \(proposal) proposed")

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
                                    accountName: account.displayName,
                                    proposal: proposal.proposalData
                                ),
                                viewModel: .init(
                                    didAccept: {
                                        Task {
                                            do {
                                                try await Sign.instance.approve(
                                                    proposalId: proposal.id,
                                                    namespaces: [
                                                        // TODO: un-hardcode
                                                        "ccd": SessionNamespace(
                                                            chains: [Blockchain("ccd:testnet")!],
                                                            accounts: [Account("ccd:testnet:\(account.address)")!],
                                                            methods: ["sign_and_send_transaction", "sign_message"],
                                                            events: ["chain_changed", "accounts_changed"]
                                                        ),
                                                    ])
                                            } catch let err {
                                                self.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                                            }
                                        }
                                    },
                                    didDecline: {
                                        // User declined the request to connect: Reject it.
                                        Task {
                                            do {
                                                try await Sign.instance.reject(proposalId: proposal.id, reason: .userRejected)
                                            } catch let err {
                                                self.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
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
                
                self.navigationController.pushViewController(
                    UIHostingController(rootView: WalletConnectAccountSelectView(viewModel: viewModel)),
                    animated: true
                )
            }
            .store(in: &cancellables)
    }

    private func setupWalletConnectSettleBinding() {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                print("DEBUG: WalletConnect: Session \(session.pairingTopic) settled")
                guard session.namespaces.count == 1, let ccdNamespace = session.namespaces["ccd"] else {
                    self?.navigationController.popToRootViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Unexpected namespaces")
                    self?.parentCoordinator?.dismissWalletConnectCoordinator()
                    return
                }

                guard ccdNamespace.accounts.count == 1, let accountAddress = ccdNamespace.accounts.first?.address else {
                    self?.navigationController.popToRootViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Unexpected number of accounts")
                    self?.parentCoordinator?.dismissWalletConnectCoordinator()
                    // TODO Reject proposal.
                    return
                }
                
                guard let account = self?.dependencyProvider.storageManager().getAccount(withAddress: accountAddress) else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Account with address '\(accountAddress)' not found")
                    // TODO Reject proposal.
                    return
                }

                // Connection established: Open "connected" screen.
                self?.navigationController.pushViewController(
                    UIHostingController(
                        rootView: WalletConnectConnectedView(
                            dappName: session.peer.name,
                            accountName: account.displayName,
                            didDisconnect: {
                                // User clicked the disconnect button.
                                Task {
                                    do {
                                        try await Sign.instance.disconnect(topic: session.topic)
                                    } catch let err {
                                        self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
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

    func setupWalletConnectRequestBinding() {
        // Handler for incoming requests on established connection.
        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] request, _ in
                print("DEBUG: WalletConnect: Incoming request: \(request)")

                // TODO: Propagate errors back to the dApp.

                // Look up session for request topic for finding connected account and dApp name.
                // TODO: We should not just trust the information from the WC client, but just check it against our own connection state.
                guard let session = Sign.instance.getSessions().first(where: { $0.topic == request.topic }) else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Session not found")
                    Task(priority: .background) {
                        try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .error(WalletConnectErrors.noSessionForTopic(with: request)))
                    }
                    return
                }
                // Look up namespace "ccd" in the session.
                guard session.namespaces.count == 1, let ccdNamespace = session.namespaces["ccd"] else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Expected single namespace with key 'ccd' but got \(session.namespaces.keys)")
                    Task(priority: .background) {
                        try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .error(WalletConnectErrors.unsupportedNamespaceKey()))
                    }
                    return
                }
                // Look up single account address in "ccd" namespace.
                guard ccdNamespace.accounts.count == 1, let accountAddress = ccdNamespace.accounts.first?.address else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Expected single address but got '\(ccdNamespace.accounts)'")
                    Task(priority: .background) {
                        try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .error(WalletConnectErrors.unsupportedAccounts()))
                    }
                    return
                }
                // Get account object by address.
                guard let account = self?.dependencyProvider.storageManager().getAccount(withAddress: accountAddress) else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Account with address '\(accountAddress)' not found")
                    Task(priority: .background) {
                        try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .error(WalletConnectErrors.unsupportedAccounts()))
                    }
                    return
                }

                var params: ContractUpdateParams
                do {
                    // Converting from dict to ContractUpdateParams struct by serializing it as JSON and immediately
                    // decoding it again.
                    let jsonData = try JSONSerialization.data(withJSONObject: request.params.value, options: [])
                    params = try JSONDecoder().decode(ContractUpdateParams.self, from: jsonData)
                } catch let err {
                    print("ERROR: WalletConnect: Cannot JSON encode/decode contract update parameters: \(err)")
                    self?.navigationController.popToRootViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                    return
                }
                
                let inputParams = ContractUpdateParameterToJsonInput(
                    parameter: params.payload.message,
                    receiveName: params.payload.receiveName,
                    schema: params.schema,
                    schemaVersion: params.schema.version?.rawValue
                )
                var message = ContractUpdateParameterRepresentation.raw(params.payload.message)
                if let decoded = try? self?.dependencyProvider.transactionsService().decodeContractParameter(with: inputParams).data(using: .utf8)?.prettyPrintedJSONString {
                    message = .decoded(decoded as String)
                }
                
                // Check that request transaction is a contract update as that's the only type we support.
                guard case TransferType.contractUpdate = params.type else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Unsupported transaction type '\(params.type)' (only 'Update' is supported).")
                    return
                }
                // Check that sender account address isn't empty as that would result in a meaningless error when trying to look up its nonce.
                guard !params.sender.isEmpty else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Invalid payload: Sender address is empty.")
                    return
                }

                guard let amount = Int(params.payload.amount) else {
                    self?.navigationController.popViewController(animated: true)
                    self?.presentError(with: "errorAlert.title".localized, message: "Invalid payload: Invalid amount.")
                    return
                }

                var transfer = TransferDataTypeFactory.create()
                transfer.transferType = params.type
                transfer.fromAddress = params.sender
                transfer.nonce = account.accountNonce
                transfer.payload = .contractUpdatePayload(params.payload)
                transfer.energy = params.payload.maxContractExecutionEnergy

                self?.navigationController.pushViewController(
                    UIHostingController(
                        rootView: WalletConnectApprovalView(
                            title: "Transaction Approval",
                            subtitle: "\(session.peer.name) requests your signature on the following transaction:",
                            contentView: WalletConnectActionRequestView(
                                amount: GTU(intValue: amount),
                                balanceAtDisposal: GTU(intValue: account.forecastAtDisposalBalance),
                                contractAddress: params.payload.address,
                                transactionType: params.type.rawValue,
                                params: message,
                                request: request
                            ),
                            viewModel: WalletConnectApprovalViewModel(
                                didAccept: { [weak self] in
                                    guard let self else {
                                        return
                                    }
                                    self.dependencyProvider.transactionsService()
                                        .performTransfer(transfer, from: account, requestPasswordDelegate: self)
                                        .sink(receiveError: { [weak self] err in
                                            print("ERROR: WalletConnect: Cannot submit transaction: \(err)")
                                            Task {
                                                do {
                                                    try await Sign.instance.respond(
                                                        topic: request.topic,
                                                        requestId: request.id,
                                                        response: .error(WalletConnectErrors.transactionFailed(AnyCodable(err.localizedDescription)))
                                                    )
                                                } catch let err {
                                                    self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                                                }
                                            }
                                            self?.navigationController.popViewController(animated: true)
                                        }, receiveValue: { [weak self] val in
                                            print("DEBUG: WalletConnect: Transaction submitted: \(val)")
                                            Task {
                                                do {
                                                    print("WalletConnect: RESPONDING \(RPCResult.response(AnyCodable(val.submissionId)))")
                                                    try await Sign.instance.respond(
                                                        topic: request.topic,
                                                        requestId: request.id,
                                                        response: .response(AnyCodable(["hash": val.submissionId]))
                                                    )
                                                } catch let err {
                                                    self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                                                }
                                            }
                                            self?.navigationController.popViewController(animated: true)
                                        })
                                        .store(in: &cancellables)
                                }, didDecline: { [weak self] in
                                    print("DEBUG: WalletConnect: Rejecting request")
                                    Task {
                                        do {
                                            try await Sign.instance.respond(
                                                topic: request.topic,
                                                requestId: request.id,
                                                response: .error(WalletConnectErrors.userRejected())
                                            )
                                        } catch let err {
                                            print("ERROR: WalletConnect: Cannot reject request: \(err)")
                                            self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                                        }
                                    }
                                    self?.navigationController.popViewController(animated: true)
                                }
                            ),
                            isAcceptButtonDisabled: account.forecastAtDisposalBalance < amount
                        )
                    ),
                    animated: true
                )
            }
            .store(in: &cancellables)

        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionId, reason in
                // Called when the dApp disconnects - not when we do ourselves!
                print("DEBUG: dApp disconnected session '\(sessionId)' with reason '\(reason)'")
                if self?.navigationController.topViewController is UIHostingController<WalletConnectConnectedView> {
                    self?.navigationController.popToRootViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
}

extension WalletConnectCoordinator: WalletConnectDelegate {
    private func setupDebugBindings() {
        // For now we just print the following events.
        Sign.instance.sessionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                print("DEBUG: WalletConnect: Session event: \(event)")
            }
            .store(in: &cancellables)

        Sign.instance.sessionExtendPublisher
            .receive(on: DispatchQueue.main)
            .sink { sessionTopic, date in
                print("DEBUG: WalletConnect: Session \(sessionTopic) extended until \(date)")
            }
            .store(in: &cancellables)

        Sign.instance.sessionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { sessionTopic, _ in
                print("DEBUG: WalletConnect: Session \(sessionTopic) updated")
            }
            .store(in: &cancellables)
        Sign.instance.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { status in
                print("DEBUG: WalletConnect: Socket connection status update: \(status)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("DEBUG: WalletConnect: Response: \(response)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { proposal, reason in
                print("DEBUG: WalletConnect: Proposal \(proposal) rejected with reason \(reason)")
            }
            .store(in: &cancellables)

        Sign.instance.pingResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { ping in
                print("DEBUG: WalletConnect: Ping: \(ping)")
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
                        } catch let err {
                            self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                        }
                    }
                    self?.navigationController.popViewController(animated: true)
                    return true
                }, viewWillDisappear:
                    { self.parentCoordinator?.dismissWalletConnectCoordinator() }
                
            )
        )
        navigationController.pushViewController(vc, animated: true)
    }

    func presentError(with title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "errorAlert.okButton".localized, style: .default))
        navigationController.present(ac, animated: true)
    }
}

extension WalletConnectCoordinator: RequestPasswordDelegate {}

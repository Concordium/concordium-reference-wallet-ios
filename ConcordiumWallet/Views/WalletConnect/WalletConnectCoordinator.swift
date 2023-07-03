import Combine
import SwiftUI
import UIKit
import Web3Wallet

let CONCORDIUM_WALLET_CONNECT_PROJECT_ID = "76324905a70fe5c388bab46d3e0564dc"

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

let expectedNamespaceKey = "ccd"
let expectedChain = "ccd:testnet"
let expectedBlockchains = Set([Blockchain(expectedChain)!])
let expectedEvents = Set(["accounts_changed", "chain_changed"])
let expectedMethods = Set(["sign_and_send_transaction", "sign_message"])

private extension WalletConnectCoordinator {
    func setupWalletConnectProposalBinding() {
        // TODO: Define a service for WalletConnect that tracks the currently open sessions (similarly to what dapp-libraries do on the client side...).

        // Register handlers for WalletConnect events.

        // Handler for session proposals, i.e. requests for connections to be established.
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] proposal, _ in
                guard let self else { return }
                print("DEBUG: WalletConnect: \(self) Session \(proposal) proposed")

                // TODO: Auto-reject proposal if namespaces doesn't exactly match expected chain/method/event.
                //      And show user appropriate error...
                
                let proposalData = proposal.proposalData
                
                // Check chain, methods and events. Reject if they don't match (fixed) expectations.
                // We only check required namespaces, not the optional ones.
                guard proposal.requiredNamespaces.count == 1, let ccdNamespace = proposal.requiredNamespaces[expectedNamespaceKey] else {
                    self.reject(proposal: proposal, reason: .userRejected, msg: "Unexpected namespaces: \(proposal.requiredNamespaces.keys)", shouldPresent: true)
                    return
                }
                if let chains = ccdNamespace.chains, chains != expectedBlockchains {
                    self.reject(proposal: proposal, reason: .userRejectedChains, msg: "Expected chain \"\(expectedBlockchains)\" bot got \(chains)", shouldPresent: true)
                    return
                }
                if ccdNamespace.events != expectedEvents {
                    self.reject(proposal: proposal, reason: .userRejectedEvents, msg: "Expected events \(expectedEvents) but got \(ccdNamespace.events)", shouldPresent: true)
                    return
                }
                if ccdNamespace.methods != expectedMethods {
                    self.reject(proposal: proposal, reason: .userRejectedMethods, msg: "Expected methods \(expectedMethods) but got \(ccdNamespace.methods)", shouldPresent: true)
                    return
                }

                let viewModel = WalletConnectAccountSelectViewModel(
                    storageManager: self.dependencyProvider.storageManager(),
                    didSelect: { [weak self] account in
                        self?.navigationController.pushViewController(
                            UIHostingController(
                                rootView: WalletConnectApprovalView(
                                    title: "walletconnect.connect.approve.title".localized,
                                    subtitle: "walletconnect.connect.approve.subtitle".localizedNonempty,
                                    contentView: WalletConnectProposalApprovalView(
                                        accountName: account.displayName,
                                        proposal: proposalData
                                    ),
                                    viewModel: .init(
                                        didAccept: {
                                            Task {
                                                do {
                                                    try await Sign.instance.approve(
                                                        proposalId: proposal.id,
                                                        namespaces: [
                                                            expectedNamespaceKey: SessionNamespace(
                                                                chains: expectedBlockchains,
                                                                accounts: [Account("\(expectedChain):\(account.address)")!],
                                                                methods: expectedMethods,
                                                                events: expectedEvents
                                                            ),
                                                        ]
                                                    )
                                                } catch let err {
                                                    self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                                                }
                                            }
                                        },
                                        didDecline: {
                                            // User declined the request to connect: Reject it.
                                            Task {
                                                do {
                                                    try await Sign.instance.reject(proposalId: proposal.id, reason: .userRejected)
                                                } catch let err {
                                                    self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                                                }
                                            }

                                            // Pop the VC without waiting for rejection to complete.
                                            self?.navigationController.popToRootViewController(animated: true)
                                        }
                                    )
                                )
                        ),
                        animated: true
                    )
                }
                )
                
                self.navigationController.pushViewController(
                    UIHostingController(rootView: WalletConnectAccountSelectView(viewModel: viewModel)),
                    animated: true
                )
            }
            .store(in: &cancellables)
    }
    
    func respondResult(request: Request, msg: AnyCodable) {
        Task { [weak self] in
            do {
                try await Sign.instance.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .response(msg)
                )
            } catch let err {
                self?.presentError(with: "errorAlert.title".localized, message: "Cannot respond status to the dApp: \(err.localizedDescription)")
            }
        }
    }
    
    private func setupWalletConnectSettleBinding() {
        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                print("DEBUG: WalletConnect: Session \(session.pairingTopic) settled")
                
                guard session.namespaces.count == 1, let ccdNamespace = session.namespaces["ccd"] else {
                    self?.disconnectAndPresentError(.sessionError(.unexpectedNamespaces(namespaces: Array(session.namespaces.keys))))
                    return
                }

                guard ccdNamespace.accounts.count == 1, let accountAddress = ccdNamespace.accounts.first?.address else {
                    self?.disconnectAndPresentError(.sessionError(.unexpectedAccountCount(addresses: Array(ccdNamespace.accounts.map { $0.address }))))
                    return
                }
                
                guard let account = self?.dependencyProvider.storageManager().getAccount(withAddress: accountAddress) else {
                    self?.disconnectAndPresentError(.sessionError(.accountNotFound(address: accountAddress)))
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

                // Look up session for request topic for finding connected account and dApp name.
                // TODO: We should not just trust the information from the WC client, but just check it against our own connection state.
                guard let session = Sign.instance.getSessions().first(where: { $0.topic == request.topic }) else {
                    self?.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.sessionNotFound(topic: request.topic)),
                        shouldPresent: true
                    )
                    return
                }
                // Look up namespace "ccd" in the session.
                guard session.namespaces.count == 1, let ccdNamespace = session.namespaces["ccd"] else {
                    self?.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.unexpectedNamespaces(namespaces: Array(session.namespaces.keys))),
                        shouldPresent: true
                    )
                    return
                }
                // Look up single account address in "ccd" namespace.
                guard ccdNamespace.accounts.count == 1, let accountAddress = ccdNamespace.accounts.first?.address else {
                    self?.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.unexpectedAccountCount(addresses: Array(ccdNamespace.accounts.map { $0.address }))),
                        shouldPresent: true
                    )
                    return
                }
                // Get account object by address.
                guard let account = self?.dependencyProvider.storageManager().getAccount(withAddress: accountAddress) else {
                    self?.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.accountNotFound(address: accountAddress)),
                        shouldPresent: true
                    )
                    return
                }

                var params: ContractUpdateParams
                do {
                    // Converting from dict to ContractUpdateParams struct by serializing it to JSON
                    // and immediately decode it again.
                    let jsonData = try JSONSerialization.data(withJSONObject: request.params.value, options: [])
                    params = try JSONDecoder().decode(ContractUpdateParams.self, from: jsonData)
                } catch let err {
                    self?.reject(
                        request: request,
                        err: WalletConnectError.internalError("Converting contract update parameters failed: \(err)"),
                        shouldPresent: true
                    )
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
                    self?.reject(
                        request: request,
                        err: .requestError(.unsupportedTransactionType(params.type)),
                        shouldPresent: true
                    )
                    return
                }
                // Check that sender account address isn't empty as that would result in a meaningless error when trying to look up its nonce.
                guard !params.sender.isEmpty else {
                    self?.reject(
                        request: request,
                        err: .requestError(.invalidPayload("Sender address is empty")),
                        shouldPresent: true
                    )
                    return
                }

                guard let amount = Int(params.payload.amount) else {
                    self?.reject(
                        request: request,
                        err: .requestError(.invalidPayload("Invalid amount")),
                        shouldPresent: true
                    )
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
                            subtitle: "\(session.peer.name) requires your approval to send the following transaction:",
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
                                    dependencyProvider.transactionsService()
                                        .performTransfer(transfer, from: account, requestPasswordDelegate: self)
                                        .sink(receiveError: { [weak self] err in
                                            self?.reject(
                                                request: request,
                                                err: .transactionError(err.localizedDescription),
                                                shouldPresent: true
                                            )
                                        }, receiveValue: { [weak self] val in
                                            print("DEBUG: WalletConnect: Transaction submitted: \(val)")
                                            self?.respondResult(request: request, msg: AnyCodable(["hash": val.submissionId]))
                                            
                                            Task {
                                                do {
                                                    try await Sign.instance.respond(
                                                        topic: request.topic,
                                                        requestId: request.id,
                                                        response: .response(AnyCodable(["hash": val.submissionId]))
                                                    )
                                                } catch let err {
                                                    self?.presentError(with: "errorAlert.title".localized, message: "Transaction submitted but cannot tell the dApp: \(err.localizedDescription)")
                                                }
                                            }
                                            
                                        })
                                        .store(in: &cancellables)
                                    self.navigationController.popViewController(animated: true)
                                }, didDecline: { [weak self] in
                                    print("DEBUG: WalletConnect: Rejecting request")
                                    self?.reject(request: request, err: .userRejected, shouldPresent: false)
                                    self?.navigationController.popViewController(animated: true)
                                }
                            )
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
                // TODO: We should also check the session topic to ensure that it's the currently active session.
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
                }
            )
        )
        navigationController.pushViewController(vc, animated: true)
    }

    func presentError(with title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "errorAlert.okButton".localized, style: .default))
        navigationController.present(ac, animated: true)
    }

    func reject(request: Request, err: WalletConnectError, shouldPresent: Bool) {
        let (code, msg) = err.codeAndMsg
        Task { [weak self] in
            do {
                try await Sign.instance.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .error(JSONRPCError(code: code, message: msg))
                )
            } catch let err {
                self?.presentError(with: "errorAlert.title".localized, message: "Cannot respond status to the dApp: \(err.localizedDescription)")
            }
        }
        if shouldPresent {
            presentError(with: "errorAlert.title".localized, message: msg)
        }
    }
    
    func reject(proposal: Session.Proposal, reason: RejectionReason, msg: String, shouldPresent: Bool) {
        Task { [weak self] in
            do {
                try await Sign.instance.reject(
                    proposalId: proposal.id,
                    reason: reason
                )
            } catch let err {
                self?.presentError(
                    with: "errorAlert.title".localized,
                    message: "Cannot repsond status to the dApp: \(err.localizedDescription)"
                )
            }
        }
        if shouldPresent {
            presentError(with: "errorAlert.title".localized, message: msg)
        }
    }
    
    func disconnectAndPresentError(_ err: WalletConnectError) {
        let (_, msg) = err.codeAndMsg
        navigationController.popToRootViewController(animated: true)
        parentCoordinator?.dismissWalletConnectCoordinator() // disconnects all sessions
        presentError(with: "errorAlert.title".localized, message: msg)
    }

}

extension WalletConnectCoordinator: RequestPasswordDelegate {}

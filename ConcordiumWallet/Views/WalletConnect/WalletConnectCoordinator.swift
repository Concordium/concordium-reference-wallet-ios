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
    private var isHandlingRequest = false
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: WalletConnectCoordiantorDelegate?
    var navigationController: UINavigationController

    init(
        navigationController: UINavigationController,
        dependencyProvider: DependencyProvider,
        parentCoordinator: WalletConnectCoordiantorDelegate
    ) {
        self.dependencyProvider = dependencyProvider
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator

        let metadata = AppMetadata(
            name: "Concordium",
            description: "Concordium - Blockchain Wallet",
            url: "wallet.connect",
            icons: [],
            verifyUrl: "verify.walletconnect.com"
        )
        Pair.configure(metadata: metadata)
        Networking.configure(projectId: CONCORDIUM_WALLET_CONNECT_PROJECT_ID, socketFactory: SocketFactory())
        
        nukeWalletConnectSessionsAndPairings()
        
        setupWalletConnectRequestBinding()
        setupWalletConnectProposalBinding()
        setupWalletConnectSettleBinding()
        setupDebugBindings()
    }

    func start() {
        showWalletConnectScanner()
    }

    func start(with uri: String) {
        pairWalletConnect(with: uri)
    }

    func nukeWalletConnectSessionsAndPairings() {
        Sign.instance.nuke()
        Pair.instance.nuke()
    }
}

// MARK: - WalletConnect

let expectedNetwork = { network in
    switch network {
    case .main:
        return "mainnet"
    case .test:
        return "testnet"
    }
}(Net.current)

let expectedNamespaceKey = "ccd"
let expectedChain = "\(expectedNamespaceKey):\(expectedNetwork)"
let signAndSendTransactionMethod = "sign_and_send_transaction"
let signMessageMethod = "sign_message"
let supportedChains = Set([Blockchain(expectedChain)!])
let supportedEvents = Set(["accounts_changed", "chain_changed"])
let supportedMethods = Set([signAndSendTransactionMethod, signMessageMethod])

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

                // Check chain, methods and events. Reject if they don't match (fixed) expectations.
                // We only check required namespaces, not the optional ones.
                guard proposal.requiredNamespaces.count == 1, let ccdNamespace = proposal.requiredNamespaces[expectedNamespaceKey] else {
                    self.reject(proposal: proposal, reason: .userRejected, msg: "Unexpected namespaces: \(proposal.requiredNamespaces.keys)")
                    return
                }
                if let chains = ccdNamespace.chains, chains != supportedChains {
                    self.reject(proposal: proposal, reason: .userRejectedChains, msg: "Expected chain \"\(supportedChains)\" but got \(chains)")
                    return
                }
                if !ccdNamespace.events.isSubset(of: supportedEvents) {
                    self.reject(proposal: proposal, reason: .userRejectedEvents, msg: "Expected subset of events \(supportedEvents) but got \(ccdNamespace.events)")
                    return
                }
                if !ccdNamespace.methods.isSubset(of: supportedMethods) {
                    self.reject(proposal: proposal, reason: .userRejectedMethods, msg: "Expected subset of methods \(supportedMethods) but got \(ccdNamespace.methods)")
                    return
                }

                let viewModel = WalletConnectAccountSelectViewModel(
                    storageManager: self.dependencyProvider.storageManager(),
                    
                    didSelect: { [weak self] account in
                        self?.navigationController.pushViewController(
                            UIHostingController(
                                rootView: WalletConnectApprovalView(
                                    title: "walletconnect.connect.approve.title".localized,
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
                                                            expectedNamespaceKey: SessionNamespace(
                                                                chains: supportedChains,
                                                                accounts: [Account("\(expectedChain):\(account.address)")!],
                                                                methods: supportedMethods, // approve all methods, not just requested ones
                                                                events: supportedEvents // approve all events, not just requested ones
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
                                        },
                                        shouldAllowAccept: .just(true)
                                    )
                                )
                            ),
                            animated: true
                        )
                    }, dismissView: { [weak self] in
                        self?.navigationController.popViewController(animated: true)
                        self?.parentCoordinator?.dismissWalletConnectCoordinator()
                        self?.nukeWalletConnectSessionsAndPairings()
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
        self.isHandlingRequest = false
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
                    self?.parentCoordinator?.dismissWalletConnectCoordinator()
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
                guard let self else { return }
                
                print("DEBUG: WalletConnect: Incoming request: \(request)")

                // Prevents displaying multiple requests at once
                if self.isHandlingRequest {
                    self.reject(request: request, err: WalletConnectError.userRejected, shouldPresent: false, shouldUnsetRequestFlag: false)
                    return
                }
                self.isHandlingRequest = true

                // Look up session for request topic for finding connected account and dApp name.
                // TODO: We should not just trust the information from the WC client, but just check it against our own connection state.
                guard let session = Sign.instance.getSessions().first(where: { $0.topic == request.topic }) else {
                    self.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.sessionNotFound(topic: request.topic)),
                        shouldPresent: true
                    )
                    return
                }
                // Look up namespace "ccd" in the session.
                guard session.namespaces.count == 1, let ccdNamespace = session.namespaces["ccd"] else {
                    self.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.unexpectedNamespaces(namespaces: Array(session.namespaces.keys))),
                        shouldPresent: true
                    )
                    return
                }
                // Look up single account address in "ccd" namespace.
                guard ccdNamespace.accounts.count == 1, let accountAddress = ccdNamespace.accounts.first?.address else {
                    self.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.unexpectedAccountCount(addresses: Array(ccdNamespace.accounts.map { $0.address }))),
                        shouldPresent: true
                    )
                    return
                }
                // Get account object by address.
                guard let account = self.dependencyProvider.storageManager().getAccount(withAddress: accountAddress) else {
                    self.reject(
                        request: request,
                        err: WalletConnectError.sessionError(SessionError.accountNotFound(address: accountAddress)),
                        shouldPresent: true
                    )
                    return
                }
                
                // TODO: Extract functions.
                switch request.method {
                case signAndSendTransactionMethod:
                    break // continue below (done like this to ensure that PR only adds implementation of "sign_message" without changing any existing code)
                case signMessageMethod:
                    // Handle method "sign_message".
                    
                    var payload: SignMessagePayload
                    do {
                        // Converting from dict to ContractUpdateParams struct by serializing it to JSON
                        // and immediately decode it again.
                        let jsonData = try JSONSerialization.data(withJSONObject: request.params.value, options: [])
                        payload = try JSONDecoder().decode(SignMessagePayload.self, from: jsonData)
                    } catch let err {
                        self.reject(
                            request: request,
                            err: WalletConnectError.internalError("Converting message parameters failed: \(err)"),
                            shouldPresent: true
                        )
                        return
                    }
                    
                    self.navigationController.pushViewController(
                        UIHostingController(
                            rootView: WalletConnectApprovalView(
                                title: "Sign Message",
                                contentView: WalletConnectSignMessageView(
                                    dappName: session.peer.name,
                                    accountName: account.displayName,
                                    message: .decoded(payload.message)
                                ),
                                viewModel: WalletConnectApprovalViewModel(
                                    didAccept: { [weak self] in
                                        guard let self else {
                                            return
                                        }
                                        
                                        // Sign message and return signatures.
                                        dependencyProvider.mobileWallet()
                                            .signMessage(for: account, message: payload.message, requestPasswordDelegate: self)
                                            .sink(receiveError: { [weak self] err in
                                                self?.reject(
                                                    request: request,
                                                    err: .transactionError(err.localizedDescription),
                                                    shouldPresent: true
                                                )
                                            }, receiveValue: { [weak self] res in
                                                print("DEBUG: WalletConnect: Message signed: \(res)")
                                                self?.respondResult(request: request, msg: AnyCodable(res))
                                            })
                                            .store(in: &cancellables)
                                        self.navigationController.popViewController(animated: true)
                                    }, didDecline: { [weak self] in
                                        print("DEBUG: WalletConnect: Rejecting request")
                                        self?.reject(request: request, err: .userRejected, shouldPresent: false)
                                        self?.navigationController.popViewController(animated: true)
                                    },
                                    shouldAllowAccept: .just(true)
                                )
                            )
                        ),
                        animated: true
                    )
                    return
                default:
                    // This should never happen as WalletConnect checks that you only invoke approved methods.
                    self.reject(
                        request: request,
                        err: WalletConnectError.requestError(.unsupportedMethod(request.method)),
                        shouldPresent: true
                    )
                    return
                }
                
                // Handle method "sign_and_send_transaction".

                var params: ContractUpdateParams
                do {
                    // Converting from dict to ContractUpdateParams struct by serializing it to JSON
                    // and immediately decode it again.
                    let jsonData = try JSONSerialization.data(withJSONObject: request.params.value, options: [])
                    params = try JSONDecoder().decode(ContractUpdateParams.self, from: jsonData)
                } catch let err {
                    self.reject(
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

                if params.sender != account.address {
                    self.reject(
                        request: request,
                        err: WalletConnectError.internalError("Sender address '\(params.sender)' differs from connected account '\(account.address)'"),
                        shouldPresent: true
                    )
                    return
                }
                
                var message: SignableValueRepresentation?
                if !inputParams.parameter.isEmpty {
                    if let decoded = try? self.dependencyProvider.transactionsService().decodeContractParameter(with: inputParams).data(using: .utf8)?.prettyPrintedJSONString {
                        message = .decoded(decoded as String)
                    } else {
                        message = SignableValueRepresentation.raw(params.payload.message)
                    }
                }

                // Check that request transaction is a contract update as that's the only type we support.
                guard case TransferType.contractUpdate = params.type else {
                    self.reject(
                        request: request,
                        err: .requestError(.unsupportedTransactionType(params.type)),
                        shouldPresent: true
                    )
                    return
                }
                // Check that sender account address isn't empty as that would result in a meaningless error when trying to look up its nonce.
                guard !params.sender.isEmpty else {
                    self.reject(
                        request: request,
                        err: .requestError(.invalidPayload("Sender address is empty")),
                        shouldPresent: true
                    )
                    return
                }

                guard let amount = Int(params.payload.amount) else {
                    self.reject(
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
                transfer.energy = params.payload.maxContractExecutionEnergy // may get overwritten by result from WP's cost estimation.

                let info = TransferInfo() // initialize info with no cost estimation
                
                let isAccountBalanceSufficient = account.forecastAtDisposalBalance > amount

                // Estimate cost of transaction.
                self.dependencyProvider.transactionsService().getTransferCost(
                    transferType: transfer.transferType.toWalletProxyTransferType(),
                    costParameters: [
                        .amount(params.payload.amount),
                        .sender(params.sender),
                        .contractIndex(params.payload.address.index),
                        .contractSubindex(params.payload.address.subindex),
                        .receiveName(params.payload.receiveName),
                        .parameter(params.payload.message),
                    ]
                )
                .sink(receiveError: { _ in
                    // Fall back to using the value provided by the dApp.
                    // TODO: Print error to user along with explanation that the dApp value is being used.
                    info.estimatedCost = .init(
                        nrg: transfer.energy,
                        ccd: nil
                    )
                }, receiveValue: { cost in
                    // Set max energy adjusted by configured buffer factor.
                    // The CCD estimate is not adjusted.
                    let energy = Int(cost.energy)
                    info.estimatedCost = .init(
                        nrg: energy,
                        ccd: GTU(intValue: Int(cost.cost))
                    )
                    transfer.energy = energy
                }).store(in: &self.cancellables)

                let viewModel = WalletConnectApprovalViewModel(
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
                            })
                            .store(in: &cancellables)
                        self.navigationController.popViewController(animated: true)
                    }, didDecline: { [weak self] in
                        print("DEBUG: WalletConnect: Rejecting request")
                        self?.reject(request: request, err: .userRejected, shouldPresent: false)
                        self?.navigationController.popViewController(animated: true)
                    },
                    shouldAllowAccept: info.$estimatedCost.map { $0 != nil && isAccountBalanceSufficient }.eraseToAnyPublisher()
                )
                
                self.navigationController.pushViewController(
                    UIHostingController(
                        // TODO: Only enable "Accept" button after cost estimation has been resolved.
                        rootView: WalletConnectApprovalView(
                            title: "Transaction Approval",
                            contentView: WalletConnectActionRequestView(
                                service: self.dependencyProvider.accountsService(),
                                dappName: session.peer.name,
                                account: account,
                                amount: GTU(intValue: amount),
                                contractAddress: params.payload.address,
                                transactionType: params.type.rawValue,
                                receiveName: params.payload.receiveName,
                                maxExecutionEnergy: params.payload.maxContractExecutionEnergy,
                                params: message,
                                request: request,
                                info: info,
                                isAccountBalanceSufficient: isAccountBalanceSufficient
                            ),
                            viewModel: viewModel
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
                    self?.pairWalletConnect(with: value)
                    return true
                }, viewDidDisappear: { [weak self] in
                    self?.nukeWalletConnectSessionsAndPairings()
                    self?.parentCoordinator?.dismissWalletConnectCoordinator()
                }
            )
        )
        navigationController.pushViewController(vc, animated: true)
    }

    private func pairWalletConnect(with uri: String) {
        Task { [weak self] in
            do {
                guard let uri = WalletConnectURI(string: uri) else {
                    self?.presentError(with: "errorAlert.title".localized, message: "Unable to initialize WalletConnectURI.")
                    return
                }
                try await Pair.instance.pair(uri: uri)
            } catch let err {
                self?.navigationController.popViewController(animated: true)
                self?.presentError(with: "errorAlert.title".localized, message: err.localizedDescription)
                self?.parentCoordinator?.dismissWalletConnectCoordinator()
            }
        }
    }

    func presentError(with title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "errorAlert.okButton".localized, style: .default))
        navigationController.present(ac, animated: true)
    }

    func reject(request: Request, err: WalletConnectError, shouldPresent: Bool, shouldUnsetRequestFlag: Bool = true) {
        if shouldUnsetRequestFlag {
            self.isHandlingRequest = false
        }
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
                self?.parentCoordinator?.dismissWalletConnectCoordinator()
            }
        }
        if shouldPresent {
            presentError(with: "errorAlert.title".localized, message: msg)
        }
    }

    func reject(proposal: Session.Proposal, reason: RejectionReason, msg: String) {
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
                self?.parentCoordinator?.dismissWalletConnectCoordinator()
            }
        }
        
        navigationController.popToRootViewController(animated: true)
        parentCoordinator?.dismissWalletConnectCoordinator() // disconnects any sessions
        presentError(with: "errorAlert.title".localized, message: msg)
    }

    func disconnectAndPresentError(_ err: WalletConnectError) {
        let (_, msg) = err.codeAndMsg
        navigationController.popToRootViewController(animated: true)
        parentCoordinator?.dismissWalletConnectCoordinator() // disconnects all sessions
        presentError(with: "errorAlert.title".localized, message: msg)
    }
}

extension WalletConnectCoordinator: RequestPasswordDelegate {}

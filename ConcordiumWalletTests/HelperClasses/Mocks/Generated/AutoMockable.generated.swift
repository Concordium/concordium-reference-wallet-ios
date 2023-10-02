// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import Combine

@testable import Mock

class AppSettingsServiceProtocolMock: AppSettingsServiceProtocol {
    // MARK: - getAppSettings

    var getAppSettingsCallsCount = 0
    var getAppSettingsCalled: Bool {
        return getAppSettingsCallsCount > 0
    }

    var getAppSettingsReturnValue: AnyPublisher<AppSettingsResponse, Error>!
    var getAppSettingsClosure: (() -> AnyPublisher<AppSettingsResponse, Error>)?

    func getAppSettings() -> AnyPublisher<AppSettingsResponse, Error> {
        getAppSettingsCallsCount += 1
        if let getAppSettingsClosure = getAppSettingsClosure {
            return getAppSettingsClosure()
        } else {
            return getAppSettingsReturnValue
        }
    }

    // MARK: - getTermsAndConditionsVersion

    var getTermsAndConditionsVersionCallsCount = 0
    var getTermsAndConditionsVersionCalled: Bool {
        return getTermsAndConditionsVersionCallsCount > 0
    }

    var getTermsAndConditionsVersionReturnValue: AnyPublisher<TermsAndConditionsResponse, Error>!
    var getTermsAndConditionsVersionClosure: (() -> AnyPublisher<TermsAndConditionsResponse, Error>)?

    func getTermsAndConditionsVersion() -> AnyPublisher<TermsAndConditionsResponse, Error> {
        getTermsAndConditionsVersionCallsCount += 1
        if let getTermsAndConditionsVersionClosure = getTermsAndConditionsVersionClosure {
            return getTermsAndConditionsVersionClosure()
        } else {
            return getTermsAndConditionsVersionReturnValue
        }
    }
}

class CIS2TokensCoordinatorDependencyProviderMock: CIS2TokensCoordinatorDependencyProvider {
    // MARK: - transactionsService

    var transactionsServiceCallsCount = 0
    var transactionsServiceCalled: Bool {
        return transactionsServiceCallsCount > 0
    }

    var transactionsServiceReturnValue: TransactionsServiceProtocol!
    var transactionsServiceClosure: (() -> TransactionsServiceProtocol)?

    func transactionsService() -> TransactionsServiceProtocol {
        transactionsServiceCallsCount += 1
        if let transactionsServiceClosure = transactionsServiceClosure {
            return transactionsServiceClosure()
        } else {
            return transactionsServiceReturnValue
        }
    }

    // MARK: - accountsService

    var accountsServiceCallsCount = 0
    var accountsServiceCalled: Bool {
        return accountsServiceCallsCount > 0
    }

    var accountsServiceReturnValue: AccountsServiceProtocol!
    var accountsServiceClosure: (() -> AccountsServiceProtocol)?

    func accountsService() -> AccountsServiceProtocol {
        accountsServiceCallsCount += 1
        if let accountsServiceClosure = accountsServiceClosure {
            return accountsServiceClosure()
        } else {
            return accountsServiceReturnValue
        }
    }

    // MARK: - identitiesService

    var identitiesServiceCallsCount = 0
    var identitiesServiceCalled: Bool {
        return identitiesServiceCallsCount > 0
    }

    var identitiesServiceReturnValue: IdentitiesService!
    var identitiesServiceClosure: (() -> IdentitiesService)?

    func identitiesService() -> IdentitiesService {
        identitiesServiceCallsCount += 1
        if let identitiesServiceClosure = identitiesServiceClosure {
            return identitiesServiceClosure()
        } else {
            return identitiesServiceReturnValue
        }
    }

    // MARK: - cis2Service

    var cis2ServiceCallsCount = 0
    var cis2ServiceCalled: Bool {
        return cis2ServiceCallsCount > 0
    }

    var cis2ServiceReturnValue: CIS2ServiceProtocol!
    var cis2ServiceClosure: (() -> CIS2ServiceProtocol)?

    func cis2Service() -> CIS2ServiceProtocol {
        cis2ServiceCallsCount += 1
        if let cis2ServiceClosure = cis2ServiceClosure {
            return cis2ServiceClosure()
        } else {
            return cis2ServiceReturnValue
        }
    }

    // MARK: - appSettingsService

    var appSettingsServiceCallsCount = 0
    var appSettingsServiceCalled: Bool {
        return appSettingsServiceCallsCount > 0
    }

    var appSettingsServiceReturnValue: AppSettingsServiceProtocol!
    var appSettingsServiceClosure: (() -> AppSettingsServiceProtocol)?

    func appSettingsService() -> AppSettingsServiceProtocol {
        appSettingsServiceCallsCount += 1
        if let appSettingsServiceClosure = appSettingsServiceClosure {
            return appSettingsServiceClosure()
        } else {
            return appSettingsServiceReturnValue
        }
    }

    // MARK: - mobileWallet

    var mobileWalletCallsCount = 0
    var mobileWalletCalled: Bool {
        return mobileWalletCallsCount > 0
    }

    var mobileWalletReturnValue: MobileWalletProtocol!
    var mobileWalletClosure: (() -> MobileWalletProtocol)?

    func mobileWallet() -> MobileWalletProtocol {
        mobileWalletCallsCount += 1
        if let mobileWalletClosure = mobileWalletClosure {
            return mobileWalletClosure()
        } else {
            return mobileWalletReturnValue
        }
    }

    // MARK: - seedMobileWallet

    var seedMobileWalletCallsCount = 0
    var seedMobileWalletCalled: Bool {
        return seedMobileWalletCallsCount > 0
    }

    var seedMobileWalletReturnValue: SeedMobileWalletProtocol!
    var seedMobileWalletClosure: (() -> SeedMobileWalletProtocol)?

    func seedMobileWallet() -> SeedMobileWalletProtocol {
        seedMobileWalletCallsCount += 1
        if let seedMobileWalletClosure = seedMobileWalletClosure {
            return seedMobileWalletClosure()
        } else {
            return seedMobileWalletReturnValue
        }
    }

    // MARK: - storageManager

    var storageManagerCallsCount = 0
    var storageManagerCalled: Bool {
        return storageManagerCallsCount > 0
    }

    var storageManagerReturnValue: StorageManagerProtocol!
    var storageManagerClosure: (() -> StorageManagerProtocol)?

    func storageManager() -> StorageManagerProtocol {
        storageManagerCallsCount += 1
        if let storageManagerClosure = storageManagerClosure {
            return storageManagerClosure()
        } else {
            return storageManagerReturnValue
        }
    }
}

class CoordinatorMock: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController {
        get { return underlyingNavigationController }
        set(value) { underlyingNavigationController = value }
    }

    var underlyingNavigationController: UINavigationController!

    // MARK: - start

    var startCallsCount = 0
    var startCalled: Bool {
        return startCallsCount > 0
    }

    var startClosure: (() -> Void)?

    func start() {
        startCallsCount += 1
        startClosure?()
    }

    // MARK: - showModally

    var showModallyFromCallsCount = 0
    var showModallyFromCalled: Bool {
        return showModallyFromCallsCount > 0
    }

    var showModallyFromReceivedArguments: (vc: UIViewController, navContrller: UINavigationController)?
    var showModallyFromReceivedInvocations: [(vc: UIViewController, navContrller: UINavigationController)] = []
    var showModallyFromClosure: ((UIViewController, UINavigationController) -> Void)?

    func showModally(_ vc: UIViewController, from navContrller: UINavigationController) {
        showModallyFromCallsCount += 1
        showModallyFromReceivedArguments = (vc: vc, navContrller: navContrller)
        showModallyFromReceivedInvocations.append((vc: vc, navContrller: navContrller))
        showModallyFromClosure?(vc, navContrller)
    }
}

class LoginCoordinatorDelegateMock: LoginCoordinatorDelegate {
    // MARK: - loginDone

    var loginDoneCallsCount = 0
    var loginDoneCalled: Bool {
        return loginDoneCallsCount > 0
    }

    var loginDoneClosure: (() -> Void)?

    func loginDone() {
        loginDoneCallsCount += 1
        loginDoneClosure?()
    }

    // MARK: - passwordSelectionDone

    var passwordSelectionDoneCallsCount = 0
    var passwordSelectionDoneCalled: Bool {
        return passwordSelectionDoneCallsCount > 0
    }

    var passwordSelectionDoneClosure: (() -> Void)?

    func passwordSelectionDone() {
        passwordSelectionDoneCallsCount += 1
        passwordSelectionDoneClosure?()
    }

    // MARK: - checkForAppSettings

    var checkForAppSettingsCallsCount = 0
    var checkForAppSettingsCalled: Bool {
        return checkForAppSettingsCallsCount > 0
    }

    var checkForAppSettingsClosure: (() -> Void)?

    func checkForAppSettings() {
        checkForAppSettingsCallsCount += 1
        checkForAppSettingsClosure?()
    }
}

class LoginDependencyProviderMock: LoginDependencyProvider {
    // MARK: - keychainWrapper

    var keychainWrapperCallsCount = 0
    var keychainWrapperCalled: Bool {
        return keychainWrapperCallsCount > 0
    }

    var keychainWrapperReturnValue: KeychainWrapperProtocol!
    var keychainWrapperClosure: (() -> KeychainWrapperProtocol)?

    func keychainWrapper() -> KeychainWrapperProtocol {
        keychainWrapperCallsCount += 1
        if let keychainWrapperClosure = keychainWrapperClosure {
            return keychainWrapperClosure()
        } else {
            return keychainWrapperReturnValue
        }
    }

    // MARK: - appSettingsService

    var appSettingsServiceCallsCount = 0
    var appSettingsServiceCalled: Bool {
        return appSettingsServiceCallsCount > 0
    }

    var appSettingsServiceReturnValue: AppSettingsServiceProtocol!
    var appSettingsServiceClosure: (() -> AppSettingsServiceProtocol)?

    func appSettingsService() -> AppSettingsServiceProtocol {
        appSettingsServiceCallsCount += 1
        if let appSettingsServiceClosure = appSettingsServiceClosure {
            return appSettingsServiceClosure()
        } else {
            return appSettingsServiceReturnValue
        }
    }

    // MARK: - recoveryPhraseService

    var recoveryPhraseServiceCallsCount = 0
    var recoveryPhraseServiceCalled: Bool {
        return recoveryPhraseServiceCallsCount > 0
    }

    var recoveryPhraseServiceReturnValue: RecoveryPhraseService!
    var recoveryPhraseServiceClosure: (() -> RecoveryPhraseService)?

    func recoveryPhraseService() -> RecoveryPhraseService {
        recoveryPhraseServiceCallsCount += 1
        if let recoveryPhraseServiceClosure = recoveryPhraseServiceClosure {
            return recoveryPhraseServiceClosure()
        } else {
            return recoveryPhraseServiceReturnValue
        }
    }

    // MARK: - seedMobileWallet

    var seedMobileWalletCallsCount = 0
    var seedMobileWalletCalled: Bool {
        return seedMobileWalletCallsCount > 0
    }

    var seedMobileWalletReturnValue: SeedMobileWalletProtocol!
    var seedMobileWalletClosure: (() -> SeedMobileWalletProtocol)?

    func seedMobileWallet() -> SeedMobileWalletProtocol {
        seedMobileWalletCallsCount += 1
        if let seedMobileWalletClosure = seedMobileWalletClosure {
            return seedMobileWalletClosure()
        } else {
            return seedMobileWalletReturnValue
        }
    }

    // MARK: - seedIdentitiesService

    var seedIdentitiesServiceCallsCount = 0
    var seedIdentitiesServiceCalled: Bool {
        return seedIdentitiesServiceCallsCount > 0
    }

    var seedIdentitiesServiceReturnValue: SeedIdentitiesService!
    var seedIdentitiesServiceClosure: (() -> SeedIdentitiesService)?

    func seedIdentitiesService() -> SeedIdentitiesService {
        seedIdentitiesServiceCallsCount += 1
        if let seedIdentitiesServiceClosure = seedIdentitiesServiceClosure {
            return seedIdentitiesServiceClosure()
        } else {
            return seedIdentitiesServiceReturnValue
        }
    }

    // MARK: - seedAccountsService

    var seedAccountsServiceCallsCount = 0
    var seedAccountsServiceCalled: Bool {
        return seedAccountsServiceCallsCount > 0
    }

    var seedAccountsServiceReturnValue: SeedAccountsService!
    var seedAccountsServiceClosure: (() -> SeedAccountsService)?

    func seedAccountsService() -> SeedAccountsService {
        seedAccountsServiceCallsCount += 1
        if let seedAccountsServiceClosure = seedAccountsServiceClosure {
            return seedAccountsServiceClosure()
        } else {
            return seedAccountsServiceReturnValue
        }
    }

    // MARK: - mobileWallet

    var mobileWalletCallsCount = 0
    var mobileWalletCalled: Bool {
        return mobileWalletCallsCount > 0
    }

    var mobileWalletReturnValue: MobileWalletProtocol!
    var mobileWalletClosure: (() -> MobileWalletProtocol)?

    func mobileWallet() -> MobileWalletProtocol {
        mobileWalletCallsCount += 1
        if let mobileWalletClosure = mobileWalletClosure {
            return mobileWalletClosure()
        } else {
            return mobileWalletReturnValue
        }
    }

    // MARK: - storageManager

    var storageManagerCallsCount = 0
    var storageManagerCalled: Bool {
        return storageManagerCallsCount > 0
    }

    var storageManagerReturnValue: StorageManagerProtocol!
    var storageManagerClosure: (() -> StorageManagerProtocol)?

    func storageManager() -> StorageManagerProtocol {
        storageManagerCallsCount += 1
        if let storageManagerClosure = storageManagerClosure {
            return storageManagerClosure()
        } else {
            return storageManagerReturnValue
        }
    }
}

class MobileWalletProtocolMock: MobileWalletProtocol {
    // MARK: - check

    var checkAccountAddressCallsCount = 0
    var checkAccountAddressCalled: Bool {
        return checkAccountAddressCallsCount > 0
    }

    var checkAccountAddressReceivedAccountAddress: String?
    var checkAccountAddressReceivedInvocations: [String] = []
    var checkAccountAddressReturnValue: Bool!
    var checkAccountAddressClosure: ((String) -> Bool)?

    func check(accountAddress: String) -> Bool {
        checkAccountAddressCallsCount += 1
        checkAccountAddressReceivedAccountAddress = accountAddress
        checkAccountAddressReceivedInvocations.append(accountAddress)
        if let checkAccountAddressClosure = checkAccountAddressClosure {
            return checkAccountAddressClosure(accountAddress)
        } else {
            return checkAccountAddressReturnValue
        }
    }

    // MARK: - createIdRequestAndPrivateData

    var createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateCallsCount = 0
    var createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateCalled: Bool {
        return createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateCallsCount > 0
    }

    var createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateReceivedArguments: (initialAccountName: String, identityName: String, identityProvider: IdentityProviderDataType, global: GlobalWrapper, requestPasswordDelegate: RequestPasswordDelegate)?
    var createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateReceivedInvocations: [(initialAccountName: String, identityName: String, identityProvider: IdentityProviderDataType, global: GlobalWrapper, requestPasswordDelegate: RequestPasswordDelegate)] = []
    var createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateReturnValue: AnyPublisher<(IDObjectRequestWrapper, IdentityCreation), Error>!
    var createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateClosure: ((String, String, IdentityProviderDataType, GlobalWrapper, RequestPasswordDelegate) -> AnyPublisher<(IDObjectRequestWrapper, IdentityCreation), Error>)?

    func createIdRequestAndPrivateData(initialAccountName: String, identityName: String, identityProvider: IdentityProviderDataType, global: GlobalWrapper, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<(IDObjectRequestWrapper, IdentityCreation), Error> {
        createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateCallsCount += 1
        createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateReceivedArguments = (initialAccountName: initialAccountName, identityName: identityName, identityProvider: identityProvider, global: global, requestPasswordDelegate: requestPasswordDelegate)
        createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateReceivedInvocations.append((initialAccountName: initialAccountName, identityName: identityName, identityProvider: identityProvider, global: global, requestPasswordDelegate: requestPasswordDelegate))
        if let createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateClosure = createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateClosure {
            return createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateClosure(initialAccountName, identityName, identityProvider, global, requestPasswordDelegate)
        } else {
            return createIdRequestAndPrivateDataInitialAccountNameIdentityNameIdentityProviderGlobalRequestPasswordDelegateReturnValue
        }
    }

    // MARK: - createCredential

    var createCredentialGlobalAccountPwHashExpiryCallsCount = 0
    var createCredentialGlobalAccountPwHashExpiryCalled: Bool {
        return createCredentialGlobalAccountPwHashExpiryCallsCount > 0
    }

    var createCredentialGlobalAccountPwHashExpiryReceivedArguments: (global: GlobalWrapper, account: AccountDataType, pwHash: String, expiry: Date)?
    var createCredentialGlobalAccountPwHashExpiryReceivedInvocations: [(global: GlobalWrapper, account: AccountDataType, pwHash: String, expiry: Date)] = []
    var createCredentialGlobalAccountPwHashExpiryReturnValue: AnyPublisher<CreateCredentialRequest, Error>!
    var createCredentialGlobalAccountPwHashExpiryClosure: ((GlobalWrapper, AccountDataType, String, Date) -> AnyPublisher<CreateCredentialRequest, Error>)?

    func createCredential(global: GlobalWrapper, account: AccountDataType, pwHash: String, expiry: Date) -> AnyPublisher<CreateCredentialRequest, Error> {
        createCredentialGlobalAccountPwHashExpiryCallsCount += 1
        createCredentialGlobalAccountPwHashExpiryReceivedArguments = (global: global, account: account, pwHash: pwHash, expiry: expiry)
        createCredentialGlobalAccountPwHashExpiryReceivedInvocations.append((global: global, account: account, pwHash: pwHash, expiry: expiry))
        if let createCredentialGlobalAccountPwHashExpiryClosure = createCredentialGlobalAccountPwHashExpiryClosure {
            return createCredentialGlobalAccountPwHashExpiryClosure(global, account, pwHash, expiry)
        } else {
            return createCredentialGlobalAccountPwHashExpiryReturnValue
        }
    }

    // MARK: - createTransfer

    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadCallsCount = 0
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadCalled: Bool {
        return createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadCallsCount > 0
    }

    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadReceivedArguments: (fromAccount: AccountDataType, toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: TransferType, requestPasswordDelegate: RequestPasswordDelegate, global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?, receiverPublicKey: String?, payload: Payload?)?
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadReceivedInvocations: [(fromAccount: AccountDataType, toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: TransferType, requestPasswordDelegate: RequestPasswordDelegate, global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?, receiverPublicKey: String?, payload: Payload?)] = []
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadReturnValue: AnyPublisher<CreateTransferRequest, Error>!
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadClosure: ((AccountDataType, String?, String?, Int, String?, String?, Bool?, DelegationTarget?, String?, String?, Double?, Double?, Double?, GeneratedBakerKeys?, Date, Int, TransferType, RequestPasswordDelegate, GlobalWrapper?, InputEncryptedAmount?, String?, Payload?) -> AnyPublisher<CreateTransferRequest, Error>)?

    func createTransfer(from fromAccount: AccountDataType, to toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: TransferType, requestPasswordDelegate: RequestPasswordDelegate, global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?, receiverPublicKey: String?, payload: Payload?) -> AnyPublisher<CreateTransferRequest, Error> {
        createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadCallsCount += 1
        createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadReceivedArguments = (fromAccount: fromAccount, toAccount: toAccount, amount: amount, nonce: nonce, memo: memo, capital: capital, restakeEarnings: restakeEarnings, delegationTarget: delegationTarget, openStatus: openStatus, metadataURL: metadataURL, transactionFeeCommission: transactionFeeCommission, bakingRewardCommission: bakingRewardCommission, finalizationRewardCommission: finalizationRewardCommission, bakerKeys: bakerKeys, expiry: expiry, energy: energy, transferType: transferType, requestPasswordDelegate: requestPasswordDelegate, global: global, inputEncryptedAmount: inputEncryptedAmount, receiverPublicKey: receiverPublicKey, payload: payload)
        createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadReceivedInvocations.append((fromAccount: fromAccount, toAccount: toAccount, amount: amount, nonce: nonce, memo: memo, capital: capital, restakeEarnings: restakeEarnings, delegationTarget: delegationTarget, openStatus: openStatus, metadataURL: metadataURL, transactionFeeCommission: transactionFeeCommission, bakingRewardCommission: bakingRewardCommission, finalizationRewardCommission: finalizationRewardCommission, bakerKeys: bakerKeys, expiry: expiry, energy: energy, transferType: transferType, requestPasswordDelegate: requestPasswordDelegate, global: global, inputEncryptedAmount: inputEncryptedAmount, receiverPublicKey: receiverPublicKey, payload: payload))
        if let createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadClosure = createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadClosure {
            return createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadClosure(fromAccount, toAccount, amount, nonce, memo, capital, restakeEarnings, delegationTarget, openStatus, metadataURL, transactionFeeCommission, bakingRewardCommission, finalizationRewardCommission, bakerKeys, expiry, energy, transferType, requestPasswordDelegate, global, inputEncryptedAmount, receiverPublicKey, payload)
        } else {
            return createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyPayloadReturnValue
        }
    }

    // MARK: - parameterToJson

    var parameterToJsonWithThrowableError: Error?
    var parameterToJsonWithCallsCount = 0
    var parameterToJsonWithCalled: Bool {
        return parameterToJsonWithCallsCount > 0
    }

    var parameterToJsonWithReceivedContractParams: ContractUpdateParameterToJsonInput?
    var parameterToJsonWithReceivedInvocations: [ContractUpdateParameterToJsonInput] = []
    var parameterToJsonWithReturnValue: String!
    var parameterToJsonWithClosure: ((ContractUpdateParameterToJsonInput) throws -> String)?

    func parameterToJson(with contractParams: ContractUpdateParameterToJsonInput) throws -> String {
        if let error = parameterToJsonWithThrowableError {
            throw error
        }
        parameterToJsonWithCallsCount += 1
        parameterToJsonWithReceivedContractParams = contractParams
        parameterToJsonWithReceivedInvocations.append(contractParams)
        if let parameterToJsonWithClosure = parameterToJsonWithClosure {
            return try parameterToJsonWithClosure(contractParams)
        } else {
            return parameterToJsonWithReturnValue
        }
    }

    // MARK: - decryptEncryptedAmounts

    var decryptEncryptedAmountsFromRequestPasswordDelegateCallsCount = 0
    var decryptEncryptedAmountsFromRequestPasswordDelegateCalled: Bool {
        return decryptEncryptedAmountsFromRequestPasswordDelegateCallsCount > 0
    }

    var decryptEncryptedAmountsFromRequestPasswordDelegateReceivedArguments: (fromAccount: AccountDataType, encryptedAmounts: [String], requestPasswordDelegate: RequestPasswordDelegate)?
    var decryptEncryptedAmountsFromRequestPasswordDelegateReceivedInvocations: [(fromAccount: AccountDataType, encryptedAmounts: [String], requestPasswordDelegate: RequestPasswordDelegate)] = []
    var decryptEncryptedAmountsFromRequestPasswordDelegateReturnValue: AnyPublisher<[(String, Int)], Error>!
    var decryptEncryptedAmountsFromRequestPasswordDelegateClosure: ((AccountDataType, [String], RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error>)?

    func decryptEncryptedAmounts(from fromAccount: AccountDataType, _ encryptedAmounts: [String], requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<[(String, Int)], Error> {
        decryptEncryptedAmountsFromRequestPasswordDelegateCallsCount += 1
        decryptEncryptedAmountsFromRequestPasswordDelegateReceivedArguments = (fromAccount: fromAccount, encryptedAmounts: encryptedAmounts, requestPasswordDelegate: requestPasswordDelegate)
        decryptEncryptedAmountsFromRequestPasswordDelegateReceivedInvocations.append((fromAccount: fromAccount, encryptedAmounts: encryptedAmounts, requestPasswordDelegate: requestPasswordDelegate))
        if let decryptEncryptedAmountsFromRequestPasswordDelegateClosure = decryptEncryptedAmountsFromRequestPasswordDelegateClosure {
            return decryptEncryptedAmountsFromRequestPasswordDelegateClosure(fromAccount, encryptedAmounts, requestPasswordDelegate)
        } else {
            return decryptEncryptedAmountsFromRequestPasswordDelegateReturnValue
        }
    }

    // MARK: - combineEncryptedAmount

    var combineEncryptedAmountCallsCount = 0
    var combineEncryptedAmountCalled: Bool {
        return combineEncryptedAmountCallsCount > 0
    }

    var combineEncryptedAmountReceivedArguments: (encryptedAmount1: String, encryptedAmount2: String)?
    var combineEncryptedAmountReceivedInvocations: [(encryptedAmount1: String, encryptedAmount2: String)] = []
    var combineEncryptedAmountReturnValue: Result<String, Error>!
    var combineEncryptedAmountClosure: ((String, String) -> Result<String, Error>)?

    func combineEncryptedAmount(_ encryptedAmount1: String, _ encryptedAmount2: String) -> Result<String, Error> {
        combineEncryptedAmountCallsCount += 1
        combineEncryptedAmountReceivedArguments = (encryptedAmount1: encryptedAmount1, encryptedAmount2: encryptedAmount2)
        combineEncryptedAmountReceivedInvocations.append((encryptedAmount1: encryptedAmount1, encryptedAmount2: encryptedAmount2))
        if let combineEncryptedAmountClosure = combineEncryptedAmountClosure {
            return combineEncryptedAmountClosure(encryptedAmount1, encryptedAmount2)
        } else {
            return combineEncryptedAmountReturnValue
        }
    }

    // MARK: - createAccountTransfer

    var createAccountTransferInputThrowableError: Error?
    var createAccountTransferInputCallsCount = 0
    var createAccountTransferInputCalled: Bool {
        return createAccountTransferInputCallsCount > 0
    }

    var createAccountTransferInputReceivedInput: String?
    var createAccountTransferInputReceivedInvocations: [String] = []
    var createAccountTransferInputReturnValue: String!
    var createAccountTransferInputClosure: ((String) throws -> String)?

    func createAccountTransfer(input: String) throws -> String {
        if let error = createAccountTransferInputThrowableError {
            throw error
        }
        createAccountTransferInputCallsCount += 1
        createAccountTransferInputReceivedInput = input
        createAccountTransferInputReceivedInvocations.append(input)
        if let createAccountTransferInputClosure = createAccountTransferInputClosure {
            return try createAccountTransferInputClosure(input)
        } else {
            return createAccountTransferInputReturnValue
        }
    }

    // MARK: - getAccountAddressesForIdentity

    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashThrowableError: Error?
    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashCallsCount = 0
    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashCalled: Bool {
        return getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashCallsCount > 0
    }

    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashReceivedArguments: (global: GlobalWrapper, identityObject: IdentityObject, privateIDObjectData: PrivateIDObjectData, startingFrom: Int, pwHash: String)?
    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashReceivedInvocations: [(global: GlobalWrapper, identityObject: IdentityObject, privateIDObjectData: PrivateIDObjectData, startingFrom: Int, pwHash: String)] = []
    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashReturnValue: Result<[MakeGenerateAccountsResponseElement], Error>!
    var getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashClosure: ((GlobalWrapper, IdentityObject, PrivateIDObjectData, Int, String) throws -> Result<[MakeGenerateAccountsResponseElement], Error>)?

    func getAccountAddressesForIdentity(global: GlobalWrapper, identityObject: IdentityObject, privateIDObjectData: PrivateIDObjectData, startingFrom: Int, pwHash: String) throws -> Result<[MakeGenerateAccountsResponseElement], Error> {
        if let error = getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashThrowableError {
            throw error
        }
        getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashCallsCount += 1
        getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashReceivedArguments = (global: global, identityObject: identityObject, privateIDObjectData: privateIDObjectData, startingFrom: startingFrom, pwHash: pwHash)
        getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashReceivedInvocations.append((global: global, identityObject: identityObject, privateIDObjectData: privateIDObjectData, startingFrom: startingFrom, pwHash: pwHash))
        if let getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashClosure = getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashClosure {
            return try getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashClosure(global, identityObject, privateIDObjectData, startingFrom, pwHash)
        } else {
            return getAccountAddressesForIdentityGlobalIdentityObjectPrivateIDObjectDataStartingFromPwHashReturnValue
        }
    }

    // MARK: - generateBakerKeys

    var generateBakerKeysCallsCount = 0
    var generateBakerKeysCalled: Bool {
        return generateBakerKeysCallsCount > 0
    }

    var generateBakerKeysReturnValue: Result<GeneratedBakerKeys, Error>!
    var generateBakerKeysClosure: (() -> Result<GeneratedBakerKeys, Error>)?

    func generateBakerKeys() -> Result<GeneratedBakerKeys, Error> {
        generateBakerKeysCallsCount += 1
        if let generateBakerKeysClosure = generateBakerKeysClosure {
            return generateBakerKeysClosure()
        } else {
            return generateBakerKeysReturnValue
        }
    }

    // MARK: - updatePasscode

    var updatePasscodeForOldPwHashNewPwHashCallsCount = 0
    var updatePasscodeForOldPwHashNewPwHashCalled: Bool {
        return updatePasscodeForOldPwHashNewPwHashCallsCount > 0
    }

    var updatePasscodeForOldPwHashNewPwHashReceivedArguments: (account: AccountDataType, oldPwHash: String, newPwHash: String)?
    var updatePasscodeForOldPwHashNewPwHashReceivedInvocations: [(account: AccountDataType, oldPwHash: String, newPwHash: String)] = []
    var updatePasscodeForOldPwHashNewPwHashReturnValue: Result<Void, Error>!
    var updatePasscodeForOldPwHashNewPwHashClosure: ((AccountDataType, String, String) -> Result<Void, Error>)?

    func updatePasscode(for account: AccountDataType, oldPwHash: String, newPwHash: String) -> Result<Void, Error> {
        updatePasscodeForOldPwHashNewPwHashCallsCount += 1
        updatePasscodeForOldPwHashNewPwHashReceivedArguments = (account: account, oldPwHash: oldPwHash, newPwHash: newPwHash)
        updatePasscodeForOldPwHashNewPwHashReceivedInvocations.append((account: account, oldPwHash: oldPwHash, newPwHash: newPwHash))
        if let updatePasscodeForOldPwHashNewPwHashClosure = updatePasscodeForOldPwHashNewPwHashClosure {
            return updatePasscodeForOldPwHashNewPwHashClosure(account, oldPwHash, newPwHash)
        } else {
            return updatePasscodeForOldPwHashNewPwHashReturnValue
        }
    }

    // MARK: - verifyPasscode

    var verifyPasscodeForPwHashCallsCount = 0
    var verifyPasscodeForPwHashCalled: Bool {
        return verifyPasscodeForPwHashCallsCount > 0
    }

    var verifyPasscodeForPwHashReceivedArguments: (account: AccountDataType, pwHash: String)?
    var verifyPasscodeForPwHashReceivedInvocations: [(account: AccountDataType, pwHash: String)] = []
    var verifyPasscodeForPwHashReturnValue: Result<Void, Error>!
    var verifyPasscodeForPwHashClosure: ((AccountDataType, String) -> Result<Void, Error>)?

    func verifyPasscode(for account: AccountDataType, pwHash: String) -> Result<Void, Error> {
        verifyPasscodeForPwHashCallsCount += 1
        verifyPasscodeForPwHashReceivedArguments = (account: account, pwHash: pwHash)
        verifyPasscodeForPwHashReceivedInvocations.append((account: account, pwHash: pwHash))
        if let verifyPasscodeForPwHashClosure = verifyPasscodeForPwHashClosure {
            return verifyPasscodeForPwHashClosure(account, pwHash)
        } else {
            return verifyPasscodeForPwHashReturnValue
        }
    }

    // MARK: - verifyIdentitiesAndAccounts

    var verifyIdentitiesAndAccountsPwHashCallsCount = 0
    var verifyIdentitiesAndAccountsPwHashCalled: Bool {
        return verifyIdentitiesAndAccountsPwHashCallsCount > 0
    }

    var verifyIdentitiesAndAccountsPwHashReceivedPwHash: String?
    var verifyIdentitiesAndAccountsPwHashReceivedInvocations: [String] = []
    var verifyIdentitiesAndAccountsPwHashReturnValue: [(IdentityDataType?, [AccountDataType])]!
    var verifyIdentitiesAndAccountsPwHashClosure: ((String) -> [(IdentityDataType?, [AccountDataType])])?

    func verifyIdentitiesAndAccounts(pwHash: String) -> [(IdentityDataType?, [AccountDataType])] {
        verifyIdentitiesAndAccountsPwHashCallsCount += 1
        verifyIdentitiesAndAccountsPwHashReceivedPwHash = pwHash
        verifyIdentitiesAndAccountsPwHashReceivedInvocations.append(pwHash)
        if let verifyIdentitiesAndAccountsPwHashClosure = verifyIdentitiesAndAccountsPwHashClosure {
            return verifyIdentitiesAndAccountsPwHashClosure(pwHash)
        } else {
            return verifyIdentitiesAndAccountsPwHashReturnValue
        }
    }

    // MARK: - signMessage

    var signMessageForMessageRequestPasswordDelegateCallsCount = 0
    var signMessageForMessageRequestPasswordDelegateCalled: Bool {
        return signMessageForMessageRequestPasswordDelegateCallsCount > 0
    }

    var signMessageForMessageRequestPasswordDelegateReceivedArguments: (account: AccountDataType, message: String, requestPasswordDelegate: RequestPasswordDelegate)?
    var signMessageForMessageRequestPasswordDelegateReceivedInvocations: [(account: AccountDataType, message: String, requestPasswordDelegate: RequestPasswordDelegate)] = []
    var signMessageForMessageRequestPasswordDelegateReturnValue: AnyPublisher<StringMessageSignatures, Error>!
    var signMessageForMessageRequestPasswordDelegateClosure: ((AccountDataType, String, RequestPasswordDelegate) -> AnyPublisher<StringMessageSignatures, Error>)?

    func signMessage(for account: AccountDataType, message: String, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<StringMessageSignatures, Error> {
        signMessageForMessageRequestPasswordDelegateCallsCount += 1
        signMessageForMessageRequestPasswordDelegateReceivedArguments = (account: account, message: message, requestPasswordDelegate: requestPasswordDelegate)
        signMessageForMessageRequestPasswordDelegateReceivedInvocations.append((account: account, message: message, requestPasswordDelegate: requestPasswordDelegate))
        if let signMessageForMessageRequestPasswordDelegateClosure = signMessageForMessageRequestPasswordDelegateClosure {
            return signMessageForMessageRequestPasswordDelegateClosure(account, message, requestPasswordDelegate)
        } else {
            return signMessageForMessageRequestPasswordDelegateReturnValue
        }
    }

    // MARK: - serializeTokenTransferParameters

    var serializeTokenTransferParametersInputThrowableError: Error?
    var serializeTokenTransferParametersInputCallsCount = 0
    var serializeTokenTransferParametersInputCalled: Bool {
        return serializeTokenTransferParametersInputCallsCount > 0
    }

    var serializeTokenTransferParametersInputReceivedInput: SerializeTokenTransferParametersInput?
    var serializeTokenTransferParametersInputReceivedInvocations: [SerializeTokenTransferParametersInput] = []
    var serializeTokenTransferParametersInputReturnValue: SerializeTokenTransferParametersOutput!
    var serializeTokenTransferParametersInputClosure: ((SerializeTokenTransferParametersInput) throws -> SerializeTokenTransferParametersOutput)?

    func serializeTokenTransferParameters(input: SerializeTokenTransferParametersInput) throws -> SerializeTokenTransferParametersOutput {
        if let error = serializeTokenTransferParametersInputThrowableError {
            throw error
        }
        serializeTokenTransferParametersInputCallsCount += 1
        serializeTokenTransferParametersInputReceivedInput = input
        serializeTokenTransferParametersInputReceivedInvocations.append(input)
        if let serializeTokenTransferParametersInputClosure = serializeTokenTransferParametersInputClosure {
            return try serializeTokenTransferParametersInputClosure(input)
        } else {
            return serializeTokenTransferParametersInputReturnValue
        }
    }
}

class ScanQRViewProtocolMock: ScanQRViewProtocol {
    // MARK: - showQrValid

    var showQrValidCallsCount = 0
    var showQrValidCalled: Bool {
        return showQrValidCallsCount > 0
    }

    var showQrValidClosure: (() -> Void)?

    func showQrValid() {
        showQrValidCallsCount += 1
        showQrValidClosure?()
    }

    // MARK: - showQrInvalid

    var showQrInvalidCallsCount = 0
    var showQrInvalidCalled: Bool {
        return showQrInvalidCallsCount > 0
    }

    var showQrInvalidClosure: (() -> Void)?

    func showQrInvalid() {
        showQrInvalidCallsCount += 1
        showQrInvalidClosure?()
    }
}

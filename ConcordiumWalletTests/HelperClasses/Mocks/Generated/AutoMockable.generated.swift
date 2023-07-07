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

    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyCallsCount = 0
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyCalled: Bool {
        return createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyCallsCount > 0
    }

    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyReceivedArguments: (fromAccount: AccountDataType, toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: TransferType, requestPasswordDelegate: RequestPasswordDelegate, global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?, receiverPublicKey: String?)?
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyReceivedInvocations: [(fromAccount: AccountDataType, toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: TransferType, requestPasswordDelegate: RequestPasswordDelegate, global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?, receiverPublicKey: String?)] = []
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyReturnValue: AnyPublisher<CreateTransferRequest, Error>!
    var createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyClosure: ((AccountDataType, String?, String?, Int, String?, String?, Bool?, DelegationTarget?, String?, String?, Double?, Double?, Double?, GeneratedBakerKeys?, Date, Int, TransferType, RequestPasswordDelegate, GlobalWrapper?, InputEncryptedAmount?, String?) -> AnyPublisher<CreateTransferRequest, Error>)?

    func createTransfer(from fromAccount: AccountDataType, to toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: TransferType, requestPasswordDelegate: RequestPasswordDelegate, global: GlobalWrapper?, inputEncryptedAmount: InputEncryptedAmount?, receiverPublicKey: String?) -> AnyPublisher<CreateTransferRequest, Error> {
        createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyCallsCount += 1
        createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyReceivedArguments = (fromAccount: fromAccount, toAccount: toAccount, amount: amount, nonce: nonce, memo: memo, capital: capital, restakeEarnings: restakeEarnings, delegationTarget: delegationTarget, openStatus: openStatus, metadataURL: metadataURL, transactionFeeCommission: transactionFeeCommission, bakingRewardCommission: bakingRewardCommission, finalizationRewardCommission: finalizationRewardCommission, bakerKeys: bakerKeys, expiry: expiry, energy: energy, transferType: transferType, requestPasswordDelegate: requestPasswordDelegate, global: global, inputEncryptedAmount: inputEncryptedAmount, receiverPublicKey: receiverPublicKey)
        createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyReceivedInvocations.append((fromAccount: fromAccount, toAccount: toAccount, amount: amount, nonce: nonce, memo: memo, capital: capital, restakeEarnings: restakeEarnings, delegationTarget: delegationTarget, openStatus: openStatus, metadataURL: metadataURL, transactionFeeCommission: transactionFeeCommission, bakingRewardCommission: bakingRewardCommission, finalizationRewardCommission: finalizationRewardCommission, bakerKeys: bakerKeys, expiry: expiry, energy: energy, transferType: transferType, requestPasswordDelegate: requestPasswordDelegate, global: global, inputEncryptedAmount: inputEncryptedAmount, receiverPublicKey: receiverPublicKey))
        if let createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyClosure = createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyClosure {
            return createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyClosure(fromAccount, toAccount, amount, nonce, memo, capital, restakeEarnings, delegationTarget, openStatus, metadataURL, transactionFeeCommission, bakingRewardCommission, finalizationRewardCommission, bakerKeys, expiry, energy, transferType, requestPasswordDelegate, global, inputEncryptedAmount, receiverPublicKey)
        } else {
            return createTransferFromToAmountNonceMemoCapitalRestakeEarningsDelegationTargetOpenStatusMetadataURLTransactionFeeCommissionBakingRewardCommissionFinalizationRewardCommissionBakerKeysExpiryEnergyTransferTypeRequestPasswordDelegateGlobalInputEncryptedAmountReceiverPublicKeyReturnValue
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
    
    func createTransfer(from fromAccount: Mock.AccountDataType, to toAccount: String?, amount: String?, nonce: Int, memo: String?, capital: String?, restakeEarnings: Bool?, delegationTarget: Mock.DelegationTarget?, openStatus: String?, metadataURL: String?, transactionFeeCommission: Double?, bakingRewardCommission: Double?, finalizationRewardCommission: Double?, bakerKeys: Mock.GeneratedBakerKeys?, expiry: Date, energy: Int, transferType: Mock.TransferType, requestPasswordDelegate: Mock.RequestPasswordDelegate, global: Mock.GlobalWrapper?, inputEncryptedAmount: Mock.InputEncryptedAmount?, receiverPublicKey: String?, payload: Mock.Payload?) -> AnyPublisher<Mock.CreateTransferRequest, Error> {
        NYI()
    }
    
    func parameterToJson(with contractParams: Mock.ContractUpdateParameterToJsonInput) throws -> String {
        NYI()
    }
    
    func createAccountTransfer(input: String) throws -> String {
        NYI()
    }
    
    func signMessage(for account: AccountDataType, message: String, requestPasswordDelegate: RequestPasswordDelegate) -> AnyPublisher<StringMessageSignatures, Error> {
        NYI()
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

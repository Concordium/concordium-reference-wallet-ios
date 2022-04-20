rm ../ConcordiumWallet/Model/AutoGenerated/*

DEST="../ConcordiumWallet/Model/AutoGenerated"

GET_IP_INFO_RESPONSE_JSON="../ConcordiumWallet/mock/1.1.2.RX-backend_identity_provider_info.json"
CREATE_ID_REQUEST_AND_PRIVATE_DATA_JSON="../ConcordiumWallet/mock/1.2.1.TX-lib_create_id_request_and_private_data.json"
CREATE_ID_REQUEST_AND_PRIVATE_DATA_RESPONSE_JSON="../ConcordiumWallet/mock/1.2.2.RX-lib_create_id_request_and_private_data.json"
GET_REQUEST_ID_JSON="../ConcordiumWallet/mock/1.3.1.TX-backend_request_identity.json"
GET_REQUEST_ID_RESPONSE_JSON="../ConcordiumWallet/mock/1.3.2.RX-backend_request_identity.json"
CREATE_CREDENTIAL_JSON="../ConcordiumWallet/mock/2.2.1.TX-lib_create_credential.json"
CREATE_CREDENTIAL_RESPONSE_JSON="../ConcordiumWallet/mock/2.2.2.RX-lib_create_credential.json"
GLOBAL_JSON="../ConcordiumWallet/mock/2.1.2.RX-backend_global.json"
SUBMIT_CREDENTIAL_JSON="../ConcordiumWallet/mock/2.3.1.TX_backend_submitCredential.json"
SUBMIT_CREDENTIAL_RESPONSE_JSON="../ConcordiumWallet/mock/2.3.2.RX_backend_submitCredential.json"
SUBMISSION_STATUS_JSON="../ConcordiumWallet/mock/2.4.2.RX_backend_submissionStatus.json"
ACC_NONCE_JSON="../ConcordiumWallet/mock/3.1.2.RX_backend_accNonce.json"
CREATE_TRANSFER_JSON="../ConcordiumWallet/mock/3.2.1.TX-lib_create_transfer.json"
CREATE_TRANSFER_RESPONSE_JSON="../ConcordiumWallet/mock/3.2.2.RX-lib_create_transfer.json"
SUBMIT_TRANSFER_JSON="../ConcordiumWallet/mock/3.3.1.TX_backend_submitTransfer.json"
SUBMIT_TRANSFER_RESPONSE_JSON="../ConcordiumWallet/mock/3.3.2.RX_backend_submitTransfer.json"
SUBMISSION_STATUS_JSON="../ConcordiumWallet/mock/3.4.2.RX_backend_submissionStatus.json"
TRANSFER_COST="../ConcordiumWallet/mock/2.5.2.RX_backend_transferCost.json"
ACCOUNT_BALANCE="../ConcordiumWallet/mock/4.1.2.RX_backend_accBalance.json"
ACCOUNT_TRANSACTIONS="../ConcordiumWallet/mock/4.2.2.RX_backend_accTransactions.json"
ACCOUNT_PUBLIC_KEY="../ConcordiumWallet/mock/4.3.2.RX_backend_accEncryptionKey.json"
SERVER_ERROR="../ConcordiumWallet/mock/backend_server_error.json"
DECRYPT_AMOUNT_JSON="../ConcordiumWallet/mock/4.4.1.TX_lib_decrypt_encrypted_amount.json"
BAKER_POOL_JSON="../ConcordiumWallet/mock/5.1.2.RX_backend_baker_pool.json"
POOL_PARAMETERS_JSON="../ConcordiumWallet/mock/5.2.2.RX_backend_pool_parameters.json"
GENERATED_BAKER_KEYS_JSON="../ConcordiumWallet/mock/5.3.2.RX_generate_baker_keys.json"

GENERATE_ACCOUNTS_JSON="../ConcordiumWallet/mock/4.5.1.TX_lib_generate_accounts.json"
GENERATE_ACCOUNTS_RESPONSE_JSON="../ConcordiumWallet/mock/4.5.2.RX_lib_generate_accounts.json"
set -x


#Replace properties interpreted incorrectly
replaceType()
{
    REPLACE_IN_FILE=$(echo $1 | cut -d'.' -f1)
    REPLACE_CLASS=$(echo $1 | cut -d'.' -f2)
    REPLACE_WITH=$2
    sed -i '' "s/$REPLACE_CLASS/$REPLACE_WITH/g" $DEST/$REPLACE_IN_FILE.swift
    #replace the property class that is no longer used
    rm $DEST/$REPLACE_CLASS.swift
}

renameType()
{
    REPLACE_IN_FILE=$(echo $1 | cut -d'.' -f1)
    REPLACE_CLASS=$(echo $1 | cut -d'.' -f2)
    REPLACE_WITH=$2
    sed -i '' "s/$REPLACE_CLASS/$REPLACE_WITH/g" $DEST/$REPLACE_IN_FILE.swift
    #rename the property class
    sed -i '' "s/$REPLACE_CLASS/$REPLACE_WITH/g" $DEST/$REPLACE_CLASS.swift
    mv $DEST/$REPLACE_CLASS.swift $DEST/$REPLACE_WITH.swift
}

cat $GENERATE_ACCOUNTS_JSON | quicktype --multi-file-output --density normal -o $DEST/MakeGenerateAaccountsRequest.swift
cat $GENERATE_ACCOUNTS_RESPONSE_JSON | quicktype --multi-file-output --density normal -o $DEST/MakeGenerateAccountsResponse.swift


#convert to model objects
cat $GET_IP_INFO_RESPONSE_JSON | quicktype --multi-file-output -o $DEST/IpInfoResponse.swift

cat $CREATE_CREDENTIAL_RESPONSE_JSON | quicktype --multi-file-output -o $DEST/create_credential_request.swift
renameType "Credential.Value" "CredentialValue"
renameType "CredentialValue.CredentialValueCredential" "ValueCredential"
#replaceType "CredentialValue.Contents" "JSONObject"
replaceType "ValueCredential.Contents" "JSONObject"
replaceType "CredentialPublicKeys.keysTEMP" "keys"
renameType "CredentialPublicKeys.KeysTEMP" "\[Int: SchemeVerifyKey\]"


#Lib: create_id_request_and_private_data REQUEST
cat $CREATE_ID_REQUEST_AND_PRIVATE_DATA_JSON | quicktype --multi-file-output -o $DEST/CreateIdRequest.swift

#Lib: create_id_request_and_private_data RESPONSE
cat $CREATE_ID_REQUEST_AND_PRIVATE_DATA_RESPONSE_JSON | quicktype --multi-file-output -o $DEST/IdRequestAndPrivateData.swift
renameType "IDObjectRequest.IDObjectRequestValue" "TEMPVALUE"
renameType "IDRequestAndPrivateData.IDObjectRequest" "IDObjectRequestWrapper"
renameType "IDObjectRequestWrapper.TEMPVALUE" "PreIdentityObject"

renameType "PrivateIDObjectData.PrivateIDObjectDataValue" "TEMPVALUE"
renameType "IDRequestAndPrivateData.PrivateIDObjectData" "PrivateIDObjectDataWrapper"
renameType "PrivateIDObjectDataWrapper.TEMPVALUE" "PrivateIDObjectData"

#GET request_id
cat $GET_REQUEST_ID_JSON | quicktype --multi-file-output -o $DEST/IdRequest.swift
replaceType "IDObjectRequest.Value" "PreIdentityObject"
renameType "IdRequest.IDObjectRequest" "IDObjectRequestWrapper"

cat $GET_REQUEST_ID_RESPONSE_JSON | quicktype --multi-file-output -o $DEST/IdentityObjectWrapper.swift
renameType "IdentityObjectWrapper.Value" "IdentityObject"

cat $GLOBAL_JSON | quicktype --multi-file-output -o $DEST/globalWrapper.swift
renameType "GlobalWrapper.Value" "Global"
cat $CREATE_CREDENTIAL_JSON | quicktype --multi-file-output -o $DEST/make_create_credential_request.swift
renameType "CreateCredentialRequestCredential.Value" "CredentialValue"
renameType "CreateCredentialRequestCredential" "Credential"
renameType "CreateCredentialRequest.CreateCredentialRequestCredential" "Credential"
renameType "AccountKeys.AccountKeysKeys" "\[Int: KeyList\]"

#cat $SUBMIT_CREDENTIAL_JSON | quicktype --multi-file-output -o $DEST/credential.swift
cat $SUBMIT_CREDENTIAL_RESPONSE_JSON | quicktype --multi-file-output --density normal -o $DEST/submission_response.swift
cat $SUBMISSION_STATUS_JSON | quicktype --multi-file-output --density normal  -o $DEST/submission_status.swift
cat $SERVER_ERROR | quicktype --multi-file-output --density normal -o $DEST/ServerErrorMessage.swift
cat $ACC_NONCE_JSON | quicktype --multi-file-output --density normal -o $DEST/acc_nonce.swift
cat $CREATE_TRANSFER_JSON | quicktype --multi-file-output --all-properties-optional --density normal -o $DEST/make_create_transfer_request.swift
replaceType "MakeCreateTransferRequest.MakeCreateTransferRequestKeys" "AccountKeys"
#renameType "MakeCreateTransferRequest.DelegationTarget" "TransferRequestDelegationTarget"
cat $DECRYPT_AMOUNT_JSON | quicktype --multi-file-output --all-properties-optional --density normal -o $DEST/make_decrypt_amount_request.swift
cat $CREATE_TRANSFER_RESPONSE_JSON | quicktype --multi-file-output --density normal -o $DEST/create_transfer_request.swift
renameType "CreateTransferRequest.Signatures" "[Int: [Int: String]]"
#cat $SUBMIT_TRANSFER_JSON | quicktype --multi-file-output -o $DEST/transfer_response.swift
cat $SUBMIT_TRANSFER_RESPONSE_JSON | quicktype --multi-file-output --density normal -o $DEST/submission_response.swift
cat $SUBMISSION_STATUS_JSON | quicktype --multi-file-output  --all-properties-optional --density normal -o $DEST/submission_status.swift
cat $TRANSFER_COST | quicktype --multi-file-output --density normal -o $DEST/TransferCost.swift
cat $ACCOUNT_BALANCE | quicktype --multi-file-output --all-properties-optional --density normal -o $DEST/AccountBalance.swift
replaceType "AccountEncryptedAmount.JSONAny" "JSONObject"
replaceType "DelegationTarget.JSONNull" "Int"
replaceType "AccountBaker.: String?" ": String"
replaceType "AccountBaker.Int?" "Int"
replaceType "AccountBaker.Bool?" "Bool"

replaceType "AccountDelegation.Bool?" "Bool"
replaceType "AccountDelegation.: String?" ": String"
replaceType "AccountDelegation.DelegationTarget?" "DelegationTarget"
replaceType "DelegationTarget.: String?" ": String"
replaceType "PendingChange.: Int?" ": Int"
replaceType "PendingChange.change: String?" "change: String"
replaceType "Balance.accountIndex: Int?" "accountIndex: Int"

cat $ACCOUNT_TRANSACTIONS | quicktype --multi-file-output --all-properties-optional --density normal -o $DEST/RemoteTransactions.swift
cat $ACCOUNT_PUBLIC_KEY | quicktype --multi-file-output --all-properties-optional --density normal -o $DEST/PublicEncriptionKey.swift
cat $BAKER_POOL_JSON | quicktype --multi-file-output --density normal -o $DEST/baker_pool_response.swift
cat $POOL_PARAMETERS_JSON | quicktype --multi-file-output --density normal -o $DEST/pool_parameters_response.swift
cat $GENERATED_BAKER_KEYS_JSON | quicktype --multi-file-output --density normal -o $DEST/GeneratedBakerKeys.swift
replaceType "BakerStakePendingChange.bakerEquityCapital: String" "bakerEquityCapital: String?"
replaceType "EuroPerEnergy.Int" "UInt64"
replaceType "BakerStakePendingChange.effectiveTime: String" "effectiveTime: String?"

replacePropertyName()
{
    REPLACE_IN_FILE=$(echo $1 | cut -d'.' -f1)
    REPLACE_PROPERTY=$(echo $1 | cut -d'.' -f2)
    REPLACE_WITH=$2

    sed -i '' "s/$REPLACE_PROPERTY/$REPLACE_WITH/g" $DEST/$REPLACE_IN_FILE.swift
}

searchReplace()
{
    REPLACE_IN_FILE=$1
    REPLACE_VALUE=$2
    REPLACE_WITH=$3

    sed -i '' "s/$REPLACE_VALUE/$REPLACE_WITH/g" $DEST/$REPLACE_IN_FILE.swift
}

replaceType "AttributeList.ChosenAttributes" "\[String: String\]"
replaceType "Policy.RevealedAttributes" "\[String: String\]"
replaceType "CommitmentsRandomness.AttributesRand" "\[String: String\]"
#replaceType "AccountKeys.keys" "Key"
#replaceType "AccountData.KeyValue" "Key"
#replaceType "Details.Outcome" "OutcomeEnum"

#renameType "Origin.TypeEnum" "OriginTypeEnum"

replacePropertyName "Description.descriptionDescription" "desc"

#make property optional
searchReplace "SubmissionStatus" "status: String\?" "status: SubmissionStatusEnum"
searchReplace "SubmissionStatus" "outcome: String\?" "outcome: OutcomeEnum?"

#searchReplace "Details" "outcome: OutcomeEnum\?" "outcome: OutcomeEnum"

searchReplace "Transaction" "blockTime: Int\?" "blockTime: Int"
searchReplace "Transaction" "blockHash: String\?" "blockHash: String"
searchReplace "Transaction" "details: Details\?" "details: Details"
searchReplace "Details" "outcome: String\?" "outcome: OutcomeEnum"
searchReplace "Origin" "type: String\?" "type: OriginTypeEnum?"
searchReplace "CreateTransferRequest" "let remaining: String" "let remaining: String?"
searchReplace "CreateTransferRequest" "let addedSelfEncryptedAmount: String" "let addedSelfEncryptedAmount: String?"
searchReplace "PublicKeys" "Key]" "SchemeVerifyKey]"
searchReplace "CredentialPublicKeys" "keys_TEMP" "keys"
#searchReplace "SubmissionStatus" "let outcomes: \[String: Outcome\]" "let outcomes: \[String: Outcome\]\?"


# TODO: prevent these types from being generated..
rm ${DEST}/Fluffy0.swift
rm ${DEST}/AccountKeysKey.swift
rm ${DEST}/AccountKeysKeys.swift
rm ${DEST}/KeyKey.swift
rm ${DEST}/KeysKeys.swift
rm ${DEST}/Purple0.swift
rm ${DEST}/PublicKeysKeys.swift
rm ${DEST}/Tentacled0.swift
rm ${DEST}/The0_Keys.swift
rm ${DEST}/The0.swift
rm ${DEST}/Signatures.swift


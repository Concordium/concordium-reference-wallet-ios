CONCORDIUM_SOURCES="../../crypto/rust-bins/wallet-notes"

GET_IP_INFO_RESPONSE_JSON="../ConcordiumWallet/mock/1.1.2.RX-backend_identity_provider_info.json"
CREATE_ID_REQUEST_AND_PRIVATE_DATA_JSON="../ConcordiumWallet/mock/1.2.1.TX-lib_create_id_request_and_private_data.json"
CREATE_ID_REQUEST_AND_PRIVATE_DATA_RESPONSE_JSON="../ConcordiumWallet/mock/1.2.2.RX-lib_create_id_request_and_private_data.json"
GET_REQUEST_ID_JSON="../ConcordiumWallet/mock/1.3.1.TX-backend_request_identity.json"
GET_REQUEST_ID_RESPONSE_JSON="../ConcordiumWallet/mock/1.3.2.RX-backend_request_identity.json"
CREATE_CREDENTIAL_JSON="../ConcordiumWallet/mock/2.2.1.TX-lib_create_credential.json"
CREATE_CREDENTIAL_RESPONSE_JSON="../ConcordiumWallet/mock/2.2.2.RX-lib_create_credential.json"


cp $CONCORDIUM_SOURCES/input.json $CREATE_ID_REQUEST_AND_PRIVATE_DATA_JSON
cp $CONCORDIUM_SOURCES/example-id-object-data.json $CREATE_ID_REQUEST_AND_PRIVATE_DATA_RESPONSE_JSON
#cp $CONCORDIUM_SOURCES/id-request.json $GET_REQUEST_ID_JSON
cp $CONCORDIUM_SOURCES/example-id-object-response.json $GET_REQUEST_ID_RESPONSE_JSON
cp $CONCORDIUM_SOURCES/credential-input.json $CREATE_CREDENTIAL_JSON
cp $CONCORDIUM_SOURCES/credential-response.json $CREATE_CREDENTIAL_RESPONSE_JSON


#Try to get data from server to get newest version

echo "GET ip_info"
#GET IP Info and save response in mock data
curl -XGET http://localhost:13000/ip_info | python -m json.tool >  $GET_IP_INFO_RESPONSE_JSON

echo "GET request_id"
#GET request_id by sending mock data and save response in mock data
#id_request@<filename> is converted to a URL parameter with key id_request and value is the content of filename
#curl -G --data-urlencode "id_request@$GET_REQUEST_ID_JSON" -X GET http://localhost:13000/request_id | python -m json.tool > $GET_REQUEST_ID_RESPONSE_JSON


import SwiftUI
import Web3Wallet

struct WalletConnectConnectedView: View {
    let dappName: String
    let accountName: String
    let didDisconnect: () -> Void;
    init(
        dappName: String,
        accountName: String,
        didDisconnect: @escaping () -> Void
    ) {
        self.dappName = dappName
        self.accountName = accountName
        self.didDisconnect = didDisconnect
    }
    
    var body: some View {
        VStack {
            Text("WalletConnect Session")
                .bold()
                .font(.system(size: 20))
            HStack {
                Image("checkmark 1")
                    .padding()
                VStack(alignment: .leading) {
                    Text("Connection open between:")
                    Text(accountName)
                    Text(dappName)
                }
                .padding([.top, .trailing, .bottom], 16)
                .foregroundColor(.white)
            }
            .background(.black)
            .cornerRadius(10)
            .padding(16)
            Spacer()
            Text("Waiting for actions...")
            Spacer()
            Button {
                didDisconnect()
            } label: {
                Text("Disconnect")
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Pallette.primary)
            .cornerRadius(10)
        }
        .navigationBarBackButtonHidden()
    }
}

struct WalletConnectConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectConnectedView(dappName: "My dApp", accountName: "My Account", didDisconnect: {})
    }
}

import SwiftUI
import Web3Wallet

struct WalletConnectConnectedView: View {
    let dappName: String
    let accountName: String
    let didDisconnect: () -> Void
    
    init(
        dappName: String,
        accountName: String,
        didDisconnect: @escaping () -> Void
    ) {
        self.dappName = dappName
        self.accountName = accountName
        self.didDisconnect = didDisconnect
    }
    
    var boxText: AttributedString {
        var d = AttributedString(dappName)
        var a = AttributedString(accountName)
        d.font = .body.bold()
        a.font = .body.bold()
        return "Application " + d + " connected to account " + a
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
                    Text(boxText)
                }
                .padding([.top, .trailing, .bottom], 16)
                .foregroundColor(.white)
            }
            .background(.black)
            .cornerRadius(10)
            Spacer()
            Text("Waiting for actions...")
            Spacer()
            Button(action: didDisconnect) {
                Text("Disconnect")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Pallette.whiteText)
                    .background(Pallette.error)
            }
            .background(Pallette.primary)
            .cornerRadius(10)
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct WalletConnectConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectConnectedView(dappName: "My dApp", accountName: "My Account", didDisconnect: {})
    }
}

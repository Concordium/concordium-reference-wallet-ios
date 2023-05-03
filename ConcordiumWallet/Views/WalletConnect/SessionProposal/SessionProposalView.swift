import SwiftUI
import Web3Wallet

struct SessionProposalView: View {
    @EnvironmentObject var presenter: SessionProposalPresenter
    
    @State var text = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Image("header")
                        .resizable()
                        .scaledToFit()
                    
                    Text(presenter.sessionProposal.proposer.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(.top, 10)
                    
                    Text("Connect")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                    
                    Text(presenter.sessionProposal.proposer.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 8)
                    
                    Divider()
                        .padding(.top, 12)
                        .padding(.horizontal, -18)
                    
                    ScrollView {
                        Text("Required namespaces".uppercased())
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.vertical, 12)
                        
                        ForEach(presenter.sessionProposal.requiredNamespaces.keys.sorted(), id: \.self) { chain in
                            if let namespaces = presenter.sessionProposal.requiredNamespaces[chain] {
                                sessionProposalView(namespaces: namespaces)
                            }
                        }
                        
                        if let optionalNamespaces = presenter.sessionProposal.optionalNamespaces {
                            if !optionalNamespaces.isEmpty {
                                Text("Optional namespaces".uppercased())
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.vertical, 12)
                            }
                            
                            ForEach(optionalNamespaces.keys.sorted(), id: \.self) { chain in
                                if let namespaces = optionalNamespaces[chain] {
                                    sessionProposalView(namespaces: namespaces)
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    .padding(.top, 12)
                    
                    HStack(spacing: 20) {
                        Button {
                            Task(priority: .userInitiated) { try await
                                presenter.onReject()
                            }
                        } label: {
                            Text("Decline")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.vertical, 11)
                                .cornerRadius(20)
                        }
                        .shadow(color: .white.opacity(0.25), radius: 8, y: 2)
                        
                        Button {
                            Task(priority: .userInitiated) { try await
                                presenter.onApprove()
                            }
                        } label: {
                            Text("Allow")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.vertical, 11)
                        }
                        .shadow(color: .white.opacity(0.25), radius: 8, y: 2)
                    }
                    .padding(.top, 25)
                }
                .padding(20)
                .cornerRadius(34)
                .padding(.horizontal, 10)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    //private func sessionProposalView(chain: String) -> some View {
    private func sessionProposalView(namespaces: ProposalNamespace) -> some View {
        VStack {
            VStack(alignment: .leading) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Methods")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 5)
                
                if !namespaces.events.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Events")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 5)
                    .padding(.bottom, 5)
                } else {
                    Spacer(minLength: 5)
                }
            }
        }
        .padding(.bottom, 15)
    }
}

#if DEBUG
struct SessionProposalView_Previews: PreviewProvider {
    static var previews: some View {
        SessionProposalView()
    }
}
#endif

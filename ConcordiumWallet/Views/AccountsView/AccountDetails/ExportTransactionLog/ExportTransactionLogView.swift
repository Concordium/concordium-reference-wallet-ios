//
//  ExportTransactionLogView.swift
//  Mock
//
//  Created by Lars Christensen on 19/12/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct ExportTransactionLogView: Page {
    @ObservedObject var viewModel: ExportTransactionLogViewModel
    
    @State private var dataTask: URLSessionDataTask?
    @State private var observation: NSKeyValueObservation?
    @State private var progress = Progress(totalUnitCount: 100)
    @State private var saveVisible = true
    @State private var doneVisible = false
    @State private var doneDisabled = true
    @State private var pendingIconVisible = false
    @State private var progressVisible = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var pageBody: some View {
        VStack {
            Text(.init(viewModel.descriptionText))
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(16)

            if pendingIconVisible {
                Image("import_pending")
                    .resizable()
                    .frame(width: 110, height: 110)
                    .foregroundColor(Pallette.primary)
            }

            if progressVisible {
                ProgressBar(progress)
            }
            
            Spacer()

            if saveVisible {
                Button("exporttransactionlog.save".localized) {
                    saveVisible = false
                    doneVisible = true
                    viewModel.descriptionText = "exporttransactionlog.generating".localized
                    pendingIconVisible = true
                    downloadLog(toUrl: viewModel.getTempFileUrl())
                }
                .applyStandardButtonStyle()
            }

            if doneVisible {
                Button("exporttransactionlog.done".localized) {
                    self.viewModel.send(.done)
                }
                .applyStandardButtonStyle(disabled: doneDisabled)
            }
        }
        .padding(16)
        .onAppear(perform: {
            viewModel.descriptionText = String(format: "exporttransactionlog.description".localized, getCCDScanLink(), getCCDScanLink())
        })
        .onDisappear(perform: {
            dataTask?.cancel()
        })
    }
    
    private func getCCDScanLink() -> String {
        #if TESTNET
            return "[testnet.CCDScan.io](https://testnet.ccdscan.io)"
        #elseif MAINNET
        if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == true {
            return "[testnet.CCDScan.io](https://testnet.ccdscan.io)"
        }
            return "[CCDScan.io](https://ccdscan.io)"
        #else
            return "[stagenet.CCDScan.io](https://stagenet.ccdscan.io)"
        #endif
    }

    private func downloadLog(toUrl: URL) {
        guard let url = viewModel.getDownloadUrl()
        else {
            viewModel.descriptionText = "exporttransactionlog.failed".localized
            pendingIconVisible = false
            doneDisabled = false
            return
        }
        dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    try data.write(to: toUrl, options: .completeFileProtection)
                    viewModel.descriptionText = "exporttransactionlog.saved".localized
                    self.viewModel.send(.save)
                } catch {
                    viewModel.descriptionText = "exporttransactionlog.failed".localized
                }
                doneDisabled = false
                progressVisible = false
            }
        }
        observation = dataTask?.progress.observe(\.fractionCompleted) { observationProgress, _ in
            pendingIconVisible = false
            progressVisible = true
            progress = observationProgress
            DispatchQueue.main.async {
                viewModel.descriptionText = "exporttransactionlog.downloading".localized
            }
        }
        dataTask?.resume()
      }
}

class ProgressBarViewModel: ObservableObject {
    let progress: Progress
    private var observer: NSKeyValueObservation!
    @Published var fractionCompleted: Double
    init(_ progress: Progress) {
        self.progress = progress
        self.fractionCompleted = progress.fractionCompleted
        observer = progress.observe(\.fractionCompleted) { [weak self] (sender, _) in
            DispatchQueue.main.async {
                self?.fractionCompleted = sender.fractionCompleted
            }
        }
    }
}

struct ProgressBar: View {
    @ObservedObject private var vm: ProgressBarViewModel
    
    init(_ progress: Progress) {
        self.vm = ProgressBarViewModel(progress)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundColor(Color(UIColor.systemGray5))
                    .frame(height: 4)
                GeometryReader { metrics in
                    RoundedRectangle(cornerRadius: 2)
                        .foregroundColor(.blue)
                        .frame(width: metrics.size.width * CGFloat(vm.fractionCompleted))
                }
            }.frame(height: 4)
            Text("\(getProgressText())")
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private func getProgressText() -> String {
        let percent = vm.fractionCompleted * 100.0
        let text = "exporttransactionlog.downloaded".localized
        return "\(String(format: "%.2f", percent))% \(text)"
    }
}

struct ExportTransactionLogView_Previews: PreviewProvider {
    static var previews: some View {
        ExportTransactionLogView(
            viewModel: .init(account: AccountDataTypeFactory.create())
        )
    }
}

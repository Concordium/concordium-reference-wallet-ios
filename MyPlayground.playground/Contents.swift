import Combine
import PlaygroundSupport
import SwiftUI
import UIKit

enum SendFundsAmount {
    case one, two
}

class ViewModel: ObservableObject {
    @Published var enteredAmount: SendFundsAmount = .one
    var view: ContentView!
    func viewDidLoad() {
    }

    func testy() throws {
        throw SomeError.error
    }
}

var viewModel = ViewModel()
enum SomeError: LocalizedError {
    case error
}

struct ContentView: View {
    var viewModel = ViewModel()   
    var cancellables: [AnyCancellable] = []

    var amountSubject = PassthroughSubject<String, Never>()
    var body: some View {
        Text("Hello, SwiftUI in Playground!")
            .padding()

        Button(action: {
            amountSubject.send("Hello")
        }) {
            Text("Tap me!")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .onAppear {
            viewModel.view = self
            viewModel.viewDidLoad()
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
print("Hello")

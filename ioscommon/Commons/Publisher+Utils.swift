import Foundation
import Combine

extension Publisher {

//    The flatMapLatest operator behaves much like the standard FlatMap operator, except that whenever
//    a new item is emitted by the source Publisher, it will unsubscribe to and stop mirroring the Publisher
//    that was generated from the previously-emitted item, and begin only mirroring the current one.
    func flatMapLatest<T: Publisher>(_ transform: @escaping (Self.Output) -> T) ->
            Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }

    func performInBackground() -> Publishers.ReceiveOn<Publishers.SubscribeOn<Self, OperationQueue>, RunLoop> {
        let backgroundQueue = OperationQueue()
        backgroundQueue.maxConcurrentOperationCount = 5
        backgroundQueue.qualityOfService = QualityOfService.userInitiated
        return subscribe(on: backgroundQueue).receive(on: RunLoop.main)
    }

    public func sink(receiveError: @escaping ((Self.Failure) -> Void), receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: { (completion: Subscribers.Completion<Failure>) in
            switch completion {
            case .failure(let error):
                receiveError(error)
            case .finished: break
            }
        }, receiveValue: receiveValue)
    }

    /// Automatically shows a loadingIndicator immediately after being called, and hides it when the publisher completes
    func showLoadingIndicator(in loadingIndicatorView: Loadable?) -> Publishers.HandleEvents<Self> {
        loadingIndicatorView?.showLoading()
        return handleEvents(receiveCompletion: { _ in loadingIndicatorView?.hideLoading() })
    }
}

extension Publisher {

    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output)
                .catch { _ in AnyPublisher<Output, Failure>.empty() }
                .eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}

extension Publisher where Self.Failure == Never {
    public func assignNoRetain<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root)
        -> AnyCancellable where Root: AnyObject {
            sink { [weak object] (value) in
                object?[keyPath: keyPath] = value
            }
    }
}

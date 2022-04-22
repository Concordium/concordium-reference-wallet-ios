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
    
    func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        scan((Output?, Output)?.none) { ($0?.1, $1) }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// Converts the output to a result, catching errors and emitting them as a result.
    /// Keep in mind the upstream will still be completed on error, this will however prevent downstream publishers from being completed.
    func asResult() -> ResultPublisher<Self> {
        ResultPublisher(upstream: self)
    }
    
    func onlySuccess<O, E>() -> Publishers.CompactMap<Self, O> where Self.Output == Result<O, E>, Self.Failure == Never {
        compactMap { result -> O? in
            switch result {
            case .failure:
                return nil
            case let .success(value):
                return value
            }
        }
    }
}

struct ResultPublisher<Upstream>: Publisher where Upstream: Publisher {
    typealias Output = Result<Upstream.Output, Upstream.Failure>
    typealias Failure = Never
    
    private let upstream: Upstream
    
    init(upstream: Upstream) {
        self.upstream = upstream
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Result<Upstream.Output, Upstream.Failure> == S.Input {
        upstream
            .map { .success($0) }
            .catch { AnyPublisher.just(.failure($0)) }
            .receive(subscriber: subscriber)
    }
}

extension Publisher {

    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }

    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output)
            	.setFailureType(to: Failure.self)
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
    
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output?>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}

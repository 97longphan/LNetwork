//
//  HTTPBody.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 22/8/25.
//

import Alamofire
import Foundation
import RxSwift

/// Internal placeholder type used when no deep error mapping is needed.
struct _NoDeepError: Decodable {}

open class ServiceClient<ResProcessor: ResponseProcessor>: ServiceClientType {
    public typealias ErrorType = ResProcessor.ErrorType

    private let worker: ServiceWorker
    private let resProcessor: ResProcessor
    private let interceptors: [LNetworkInterceptor]

    public init(
        sessionConfiguration: URLSessionConfiguration? = nil,
        resProcessor: ResProcessor,
        interceptors: [LNetworkInterceptor] = []
    ) {
        self.worker = SessionWorker(sessionConfiguration: sessionConfiguration)
        self.resProcessor = resProcessor
        self.interceptors = interceptors
    }

    public func performObservable<T: Decodable, E>(
        request: any NetworkRequest,
        decodeTo type: T.Type,
        deepErrorType: E.Type
    ) -> Observable<T> {
        let observable = Observable<T>.create { observer in
            let task = self.performDataTask(
                request: request,
                decodeTo: type,
                deepErrorType: deepErrorType
            ) { result in
                switch result {
                case .success(let model):
                    observer.onNext(model)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
        return observable
    }

    public func performObservable<T: Decodable>(
        request: any NetworkRequest,
        decodeTo type: T.Type
    ) -> Observable<T> {
        let observable = Observable<T>.create { observer in
            let task = self.performDataTask(
                request: request,
                decodeTo: type,
                deepErrorType: _NoDeepError.self
            ) { result in
                switch result {
                case .success(let model):
                    observer.onNext(model)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
        return observable
    }

    public func performObservable(
        request: any NetworkRequest
    ) -> Observable<Void> {
        let observable = Observable<Void>.create { observer in
            let task = self.performDataTask(
                request: request,
                decodeTo: EmptyResponse.self,
                deepErrorType: _NoDeepError.self
            ) { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
        return observable
    }

    public func performObservable<E>(
        request: any NetworkRequest,
        deepErrorType: E.Type
    ) -> Observable<Void> {
        let observable = Observable<Void>.create { observer in
            let task = self.performDataTask(
                request: request,
                decodeTo: EmptyResponse.self,
                deepErrorType: deepErrorType
            ) { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create { task?.cancel() }
        }
        return observable
    }

}

// MARK: - Private Helpers

extension ServiceClient {

    @discardableResult
    private func performDataTask<T: Decodable, E>(
        request: any NetworkRequest,
        decodeTo type: T.Type,
        deepErrorType: E.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> (any RequestHandler)? {
        worker.execute(request: request, interceptors: interceptors) { raw in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try self.resProcessor.processResponse(
                        raw: raw,
                        deepErrorType: deepErrorType
                    )
                    let decoded = try JSONDecoder().decode(type, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}

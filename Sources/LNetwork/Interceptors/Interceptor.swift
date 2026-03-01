//
//  Interceptor.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 17/10/25.
//
import Alamofire
import Foundation

public struct RetryRequestInfo {
    public let retryCount: Int
    public let httpResponse: HTTPURLResponse?
    public let error: Error
    public let data: Data?

    public init(retryCount: Int, httpResponse: HTTPURLResponse?, error: Error, data: Data?) {
        self.retryCount = retryCount
        self.httpResponse = httpResponse
        self.error = error
        self.data = data
    }
}

public protocol LNetworkInterceptor {
    func adapt(
        request: any NetworkRequest,
        completion: @escaping (Result<any NetworkRequest, Error>) -> Void
    )

    func retry(
        request: any NetworkRequest,
        retryInfo: RetryRequestInfo,
        completion: @escaping (RetryResult) -> Void
    )

    func didReceive(
        response: RawResponse,
        for request: any NetworkRequest,
        completion: @escaping (RawResponse) -> Void
    )
}

public extension LNetworkInterceptor {
    func adapt(
        request: any NetworkRequest,
        completion: @escaping (Result<any NetworkRequest, Error>) -> Void
    ) {
        completion(.success(request))
    }

    func retry(
        request _: any NetworkRequest,
        retryInfo _: RetryRequestInfo,
        completion: @escaping (RetryResult) -> Void
    ) {
        completion(.doNotRetry)
    }

    func didReceive(
        response: RawResponse,
        for request: any NetworkRequest,
        completion: @escaping (RawResponse) -> Void
    ) {
        completion(response)
    }
}

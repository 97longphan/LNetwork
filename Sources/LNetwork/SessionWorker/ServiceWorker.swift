//
//  ServiceWorker.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 17/10/25.
//

import Alamofire
import Foundation

public protocol ServiceWorker {
    @discardableResult
    func execute(
        request target: any NetworkRequest,
        interceptors: [any LNetworkInterceptor],
        handler: @escaping (RawResponse) -> Void
    ) -> (any RequestHandler)?
}

open class SessionWorker: ServiceWorker {
    private let session: Session

    public init(
        sessionConfiguration: URLSessionConfiguration? = nil
    ) {
        let config = sessionConfiguration ?? SessionWorker.defaultConfiguration()
        self.session = Session(configuration: config)
    }

    public static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return config
    }

    @discardableResult
    open func execute(
        request target: any NetworkRequest,
        interceptors: [any LNetworkInterceptor],
        handler: @escaping (RawResponse) -> Void
    ) -> (any RequestHandler)? {
        guard let urlRequest = target.urlRequest else {
            handler(RawResponse(
                data: nil,
                statusCode: nil,
                error: nil,
                urlRequest: nil,
                httpResponse: nil
            ))
            return nil
        }

        // ✅ Dùng map() có cả adapter + retrier
        let interceptor = InterceptorMapper.map(
            networkRequest: target,
            interceptors: interceptors,
            maxRetries: 3
        )

        let afRequest = session.request(urlRequest, interceptor: interceptor)

        afRequest.validate().responseData { afResponse in
            let rawError: Error? = afResponse.error?.unwrapAdaptationError()

            let raw = RawResponse(
                data: afResponse.data,
                statusCode: afResponse.response?.statusCode,
                error: rawError,
                urlRequest: afResponse.request,
                httpResponse: afResponse.response
            )

            self.didReceiveAll(
                response: raw,
                for: target,
                interceptors: interceptors,
                handler: handler
            )
        }

        return afRequest
    }

    private func didReceiveAll(
        response: RawResponse,
        for request: any NetworkRequest,
        interceptors: [any LNetworkInterceptor],
        handler: @escaping (RawResponse) -> Void
    ) {
        guard let first = interceptors.first else {
            handler(response)
            return
        }

        let remaining = Array(interceptors.dropFirst())

        first.didReceive(response: response, for: request) { response in
            if remaining.isEmpty {
                handler(response)
            } else {
                self.didReceiveAll(
                    response: response,
                    for: request,
                    interceptors: remaining,
                    handler: handler
                )
            }
        }
    }

}

extension AFError {
    /// Extracts the underlying error from `.requestAdaptationFailed`.
    /// For other AFError cases, returns self.
    func unwrapAdaptationError() -> Error {
        if case let .requestAdaptationFailed(inner) = self {
            return inner
        }
        return self
    }
}

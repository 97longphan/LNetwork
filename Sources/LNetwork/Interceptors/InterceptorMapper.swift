//
//  InterceptorMapper.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 17/10/25.
//
import Alamofire

public struct InterceptorMapper {
    public static func map(
        networkRequest: any NetworkRequest,
        interceptors: [any LNetworkInterceptor],
        maxRetries: Int = 3
    ) -> Alamofire.Interceptor? {
        guard !interceptors.isEmpty else { return nil }

        // ✅ CHAIN toàn bộ interceptor adapt
        let adapter = Adapter { urlRequest, _, completion in
            adaptAll(request: networkRequest, interceptors: interceptors) { result in
                switch result {
                case let .success(finalRequest):
                    guard let adaptedURLRequest = finalRequest.urlRequest else {
                        completion(.failure(AFError.invalidURL(url: networkRequest.baseUrlString)))
                        return
                    }
                    completion(.success(adaptedURLRequest))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }

        // ✅ Retry chain vẫn giữ nguyên
        let retriers = interceptors.map { interceptor -> RequestRetrier in
            Retrier { req, _, error, completion in
                guard req.retryCount < maxRetries else {
                    completion(.doNotRetry)
                    return
                }
                let retryInfo = RetryRequestInfo(
                    retryCount: req.retryCount,
                    httpResponse: req.response,
                    error: error,
                    data: (req as? DataRequest)?.data
                )
                interceptor.retry(
                    request: networkRequest,
                    retryInfo: retryInfo,
                    completion: completion
                )
            }
        }

        return Alamofire.Interceptor(adapters: [adapter], retriers: retriers)
    }

    // 🔁 chạy từng interceptor adapt tuần tự
    private static func adaptAll(
        request: any NetworkRequest,
        interceptors: [any LNetworkInterceptor],
        completion: @escaping (Result<any NetworkRequest, Error>) -> Void
    ) {
        guard let first = interceptors.first else {
            completion(.success(request))
            return
        }

        let  remaining = Array(interceptors.dropFirst())
        first.adapt(request: request) { result in
            switch result {
            case let .success(modified):
                if remaining.isEmpty {
                    completion(.success(modified))
                } else {
                    adaptAll(
                        request: modified,
                        interceptors: remaining,
                        completion: completion
                    )
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

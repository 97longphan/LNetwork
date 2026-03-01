//
//  LoggingInterceptor.swift
//  TCB-SoftPOS
//
//  Created by LONGPHAN on 11/11/25.
//

public struct LoggingInterceptor: LNetworkInterceptor {
    public init() {}

    public func adapt(
        request: any NetworkRequest,
        completion: @escaping (Result<any NetworkRequest, Error>) -> Void
    ) {
        request.logRequest()
        completion(.success(request))
    }

    public func didReceive(
        response: RawResponse,
        for request: any NetworkRequest,
        completion: @escaping (RawResponse) -> Void
    ) {
        response.logResponse()
        completion(response)
    }

}

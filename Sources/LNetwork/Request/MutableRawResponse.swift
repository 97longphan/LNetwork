//
//  MutableRawResponse.swift
//  TCB-SoftPOS
//
//  Created by LONGPHAN on 31/10/25.
//
import Foundation

public struct MutableRawResponse {
    public var data: Data?
    public var statusCode: Int?
    public var error: Error?
    public var urlRequest: URLRequest?
    public var httpResponse: HTTPURLResponse?

    public init(from response: RawResponse) {
        self.data = response.data
        self.statusCode = response.statusCode
        self.error = response.error
        self.urlRequest = response.urlRequest
        self.httpResponse = response.httpResponse
    }

    public func asRaw() -> RawResponse {
        RawResponse(
            data: data,
            statusCode: statusCode,
            error: error,
            urlRequest: urlRequest,
            httpResponse: httpResponse
        )
    }
}

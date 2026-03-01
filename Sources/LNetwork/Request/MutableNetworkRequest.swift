//
//  MutableNetworkRequest.swift
//  TCB-SoftPOS
//
//  Created by UPP-LONGPHAN-M on 30/10/25.
//

import Foundation

public struct MutableNetworkRequest: NetworkRequest {
    public var httpMethod: HTTPMethod
    public var baseUrlString: String
    public var path: String
    public var headers: [HTTPHeader]?
    public var body: HTTPBody?
    public var timeoutInterval: TimeInterval
    public var cachePolicy: URLRequest.CachePolicy
    public var queryParams: [String: String]?

    // ✅ init copy từ NetworkRequest
    public init(from request: any NetworkRequest) {
        self.httpMethod = request.httpMethod
        self.baseUrlString = request.baseUrlString
        self.path = request.path
        self.headers = request.headers
        self.body = request.body
        self.timeoutInterval = request.timeoutInterval
        self.cachePolicy = request.cachePolicy
        self.queryParams = request.queryParams
    }
}

public extension NetworkRequest {
    func asMutable() -> MutableNetworkRequest {
        MutableNetworkRequest(from: self)
    }
}

public extension MutableNetworkRequest {
    mutating func addHeader(_ header: HTTPHeader) {
        if headers == nil {
            headers = []
        }
        headers?.removeAll {
            $0.key.caseInsensitiveCompare(header.key) == .orderedSame
        }
        headers?.append(header)
    }

    mutating func removeHeader(for key: String) {
        headers?.removeAll {
            $0.key.caseInsensitiveCompare(key) == .orderedSame
        }
    }

    mutating func mergeHeaders(_ newHeaders: [HTTPHeader]) {
        newHeaders.forEach { addHeader($0) }
    }
}

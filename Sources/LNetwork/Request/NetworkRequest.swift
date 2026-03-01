//
//  NetworkRequest.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 22/8/25.
//

import Foundation

public protocol NetworkRequest {
    var httpMethod: HTTPMethod { get }
    var baseUrlString: String { get }
    var path: String { get }
    var headers: [HTTPHeader]? { get }
    var body: HTTPBody? { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var queryParams: [String: String]? { get }
}

// default values
public extension NetworkRequest {
    var headers: [HTTPHeader]? { [] }
    var body: HTTPBody? { nil }
    var timeoutInterval: TimeInterval { 60 }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var queryParams: [String: String]? { nil }
}

// MARK: - URLRequest builder

public extension NetworkRequest {
    var urlRequest: URLRequest? {
        guard var components = URLComponents(string: baseUrlString) else {
            return nil
        }

        let cleanPath = path.hasPrefix("/") ? path : "/" + path
        components.path = components.path + cleanPath

        if let queryParams = queryParams, !queryParams.isEmpty {
            components.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy

        if let data = body?.data {
            request.httpBody = data
        }

        headers?.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }
}

// MARK: - NetworkRequest Debug Log

public extension NetworkRequest {
    func logRequest(tag: String = "📡 Network Request") {
        #if DEBUG
            print("\n\(tag)")

            guard let request = urlRequest else {
                print("❌ urlRequest = nil")
                return
            }

            // URL chính xác đã build qua URLComponents
            let urlString = request.url?.absoluteString ?? "nil"
            print("➡️ [\(request.httpMethod ?? httpMethod.rawValue)] \(urlString)")

            // Headers
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                print("🧩 Headers:")
                headers.forEach { key, value in
                    print("   \(key): \(value)")
                }
            } else {
                print("🧩 Headers: none")
            }

            // Body
            if let data = request.httpBody {
                if
                    let jsonString = String(data: data, encoding: .utf8),
                    let pretty = jsonString.prettyPrintedJSON
                {
                    print("📦 Body:")
                    print(pretty)
                } else {
                    print("📦 Body: binary (\(data.count) bytes)")
                }
            } else {
                print("📦 Body: nil")
            }

            // Timeout + Cache policy
            print("⏱ Timeout: \(request.timeoutInterval)s | CachePolicy: \(request.cachePolicy)")
            print("———————————————————————————————————————\n")
        #endif
    }
}

extension String {
    var prettyPrintedJSON: String? {
        guard
            let data = self.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(
                with: data,
                options: []
            ),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted]
            ),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            return nil
        }
        return prettyString
    }
}

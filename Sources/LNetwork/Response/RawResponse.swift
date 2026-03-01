//
//  RawResponse.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 17/10/25.
//

import Foundation

public struct RawResponse {
    public let data: Data?
    public let statusCode: Int?
    public let error: Error?
    public let urlRequest: URLRequest?
    public let httpResponse: HTTPURLResponse?

    public init(
        data: Data?,
        statusCode: Int?,
        error: Error?,
        urlRequest: URLRequest?,
        httpResponse: HTTPURLResponse?
    ) {
        self.data = data
        self.statusCode = statusCode
        self.error = error
        self.urlRequest = urlRequest
        self.httpResponse = httpResponse
    }
}

// MARK: - NetworkResponse Debug Log

public extension RawResponse {
    func logResponse(tag: String = "📬 Network Response") {
        #if DEBUG
            print("\n\(tag)")

            if let url = httpResponse?.url?.absoluteString ?? urlRequest?.url?.absoluteString {
                print("⬅️ URL: \(url)")
            }

            if let status = statusCode {
                print("📊 Status Code: \(status)")
            }

            if let headers = httpResponse?.allHeaderFields as? [String: Any], !headers.isEmpty {
                print("🧩 Headers:")
                headers.forEach { key, value in
                    print("   \(key): \(value)")
                }
            }

            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            }

            // 🧾 Body / Data
            if let data = data, !data.isEmpty {
                if
                    let jsonString = String(data: data, encoding: .utf8),
                    let prettyJSON = jsonString.prettyPrintedJSON
                {
                    print("📦 Body:")
                    print(prettyJSON)
                } else if let text = String(data: data, encoding: .utf8) {
                    print("📦 Body (raw string):")
                    print(text)
                } else {
                    print("📦 Body: (binary data \(data.count) bytes)")
                }
            } else {
                print("📦 Body: nil")
            }

            print("———————————————————————————————————————\n")
        #endif
    }
}

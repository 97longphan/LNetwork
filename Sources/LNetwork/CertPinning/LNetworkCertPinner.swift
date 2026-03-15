//
//  LNetworkCertPinner.swift
//  LNetwork
//

import Foundation

/// Holds certificate pinning configuration for a specific host.
/// Parallel to `LNetworkInterceptor` — pass an array to `ServiceClient.init`.
///
/// `pinnedHashes`: base64-encoded SHA-256 of SubjectPublicKeyInfo (SPKI).
/// Format matches Android OkHttp CertificatePinner `sha256/` values (strip the prefix).
public struct LNetworkCertPinner {

    public let domain: String
    public let pinnedHashes: [String]

    public init(domain: String, pinnedHashes: [String]) {
        self.domain = domain
        self.pinnedHashes = pinnedHashes
    }
}

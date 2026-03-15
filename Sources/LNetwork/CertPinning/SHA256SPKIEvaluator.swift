//
//  SHA256SPKIEvaluator.swift
//  LNetwork
//

import Alamofire
import CryptoKit
import Foundation

/// If any cert in the chain matches a pinned hash, the connection succeeds.
final class SHA256SPKIEvaluator: ServerTrustEvaluating {

    private let pinnedHashes: Set<String>

    init(pinnedHashes: [String]) {
        self.pinnedHashes = Set(pinnedHashes)
    }

    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        // Standard OS chain validation + hostname check first
        try trust.af.performDefaultValidation(forHost: host)
        try trust.af.performValidation(forHost: host)

        // Walk the cert chain, compute SPKI hash for each cert
        let certCount = SecTrustGetCertificateCount(trust)
        for i in 0..<certCount {
            guard let cert = SecTrustGetCertificateAtIndex(trust, i),
                  let spki = spkiData(for: cert) else { continue }

            let hash = Data(SHA256.hash(data: spki)).base64EncodedString()
            if pinnedHashes.contains(hash) {
                return
            }
        }

        throw AFError.serverTrustEvaluationFailed(
            reason: .customEvaluationFailed(
                error: NSError(
                    domain: "LNetworkCertPinning",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Certificate pinning failed for host: \(host). No matching SPKI hash found."]
                )
            )
        )
    }

    // MARK: - SPKI Extraction

    /// Builds the full SubjectPublicKeyInfo DER bytes by prepending the appropriate
    /// ASN.1 AlgorithmIdentifier header to the raw public key bytes.
    /// This is what Android CertificatePinner hashes for its `sha256/` values.
    private func spkiData(for cert: SecCertificate) -> Data? {
        guard let key = SecCertificateCopyKey(cert),
              let keyData = SecKeyCopyExternalRepresentation(key, nil) as Data?,
              let attrs = SecKeyCopyAttributes(key) as? [String: Any],
              let keyType = attrs[kSecAttrKeyType as String] as? String
        else { return nil }

        let header: [UInt8]
        if keyType == (kSecAttrKeyTypeRSA as String) {
            header = keyData.count > 400 ? rsa4096Header : rsa2048Header
        } else if keyType == (kSecAttrKeyTypeEC as String) {
            header = keyData.count > 80 ? ecP384Header : ecP256Header
        } else {
            return nil // Unsupported key type
        }

        return Data(header) + keyData
    }

    // MARK: - ASN.1 SPKI Headers (stable RFC constants)

    // rsaEncryption OID (1.2.840.113549.1.1.1), RSA-2048
    private let rsa2048Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
        0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    // rsaEncryption OID, RSA-4096
    private let rsa4096Header: [UInt8] = [
        0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09,
        0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
    ]

    // id-ecPublicKey OID (1.2.840.10045.2.1) + prime256v1 (P-256)
    private let ecP256Header: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86,
        0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a,
        0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]

    // id-ecPublicKey OID + secp384r1 (P-384)
    private let ecP384Header: [UInt8] = [
        0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86,
        0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x05, 0x2b,
        0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
    ]
}

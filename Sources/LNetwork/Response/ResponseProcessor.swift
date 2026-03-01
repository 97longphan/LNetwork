//
//  ResponseProcessor.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 17/10/25.
//

import Foundation

public protocol ResponseProcessor {
    associatedtype ErrorType: Decodable

    func processResponse<E>(
        raw: RawResponse,
        deepErrorType: E.Type?
    ) throws -> Data
}

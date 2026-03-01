//
//  RequestHandler.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 17/10/25.
//

import Alamofire
import Foundation

public protocol RequestHandler {
    func cancel()
}

extension DataRequest: RequestHandler {
    public func cancel() {
        if let url = self.request?.url?.absoluteString {
            print("🛑 Cancel called for: \(url) at \(Date())")
        }
        _ = self.cancel() as DataRequest
    }
}

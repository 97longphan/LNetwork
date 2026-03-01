//
//  ServiceClientType.swift
//  CoreNetwork
//
//  Created by LONGPHAN on 22/8/25.
//

import Foundation
import RxSwift

public protocol ServiceClientType {
    func performObservable<T: Decodable, E>(
        request: any NetworkRequest,
        decodeTo type: T.Type,
        deepErrorType: E.Type
    ) -> Observable<T>

    func performObservable<T: Decodable>(
        request: any NetworkRequest,
        decodeTo type: T.Type
    ) -> Observable<T>

    func performObservable(
        request: any NetworkRequest
    ) -> Observable<Void>

    func performObservable<E>(
        request: any NetworkRequest,
        deepErrorType: E.Type
    ) -> Observable<Void>
}

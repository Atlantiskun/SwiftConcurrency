//
//  CustomAsyncPublisher.swift
//  SwiftConcurrency
//
//  Created by Дмитрий Болучевских on 15.09.2022.
//

import Combine

struct CustomAsyncPublisher<P>: AsyncSequence where P: Publisher, P.Failure == Never {
    
    typealias Element = P.Output
    typealias AsyncIterator = AsyncStream<Element>.AsyncIterator
    
    var upstream: AnyPublisher<Element, Never>
    
    init(_ upstream: AnyPublisher<Element, Never>) {
        self.upstream = upstream
    }
    
    func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        var subscription: Subscription?
        
        let stream = AsyncStream<Element> { continuation in
            let mySubscriber = AnySubscriber<Element, Never>(
                receiveSubscription: { s in
                    subscription = s
                    s.request(.max(1))
                },
                receiveValue: {
                    continuation.yield($0)
                    return .max(1)
                },
                receiveCompletion: { _ in
                    continuation.finish()
                    subscription?.cancel()
                }
            )
            self.upstream.receive(subscriber: mySubscriber)
        }
        return stream.makeAsyncIterator()
    }
}

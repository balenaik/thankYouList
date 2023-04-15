//
//  TestScheduler+Observer.swift
//  ThankYouListTests
//
//  Created by Aika Yamada on 2023/04/01.
//  Copyright © 2023 Aika Yamada. All rights reserved.
//

import Combine
import EntwineTest

extension TestScheduler {
    func createObserver<Input, Failure>(from: any Publisher<Input, Failure>) -> TestableSubscriber<Input, Failure> {
        let observer = createTestableSubscriber(Input.self, Failure.self)
        from.eraseToAnyPublisher().receive(subscriber: observer)
        return observer
    }

    func createObserver<Input>(from: Published<Input>) -> TestableSubscriber<Input, Never> {
        var published = from
        let observer = createTestableSubscriber(Input.self, Never.self)
        published.projectedValue.receive(subscriber: observer)
        return observer
    }
}

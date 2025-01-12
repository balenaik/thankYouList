//
//  PositiveStatementProvider.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import WidgetKit

// Using a class instead of a struct to store AnyCancellable instances, which
// cannot be managed in a struct due to value semantics.
class PositiveStatementProvider: TimelineProvider {
    private let positiveStatementManager = PositiveStatementWidgetManager()
    private var cancellables = Set<AnyCancellable>()

    func placeholder(in context: Context) -> PositiveStatementEntry {
        PositiveStatementEntry(date: Date(), positiveStatement: "Placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (PositiveStatementEntry) -> ()) {
        let entry = PositiveStatementEntry(date: Date(), positiveStatement: "from getSnapshot")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        positiveStatementManager
            .getPositiveStatementEntries()
            .sink(receiveCompletion: { _ in }, receiveValue: { entries in
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            })
            .store(in: &cancellables)
    }
}

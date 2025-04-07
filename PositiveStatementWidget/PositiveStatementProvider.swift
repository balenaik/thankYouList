//
//  PositiveStatementProvider.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2024/09/22.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import WidgetKit

private let statementRefreshIntervalInHours = 4

// Using a class instead of a struct to store AnyCancellable instances, which
// cannot be managed in a struct due to value semantics.
class PositiveStatementProvider: TimelineProvider {
    private let positiveStatementManager = PositiveStatementWidgetManager()
    private var cancellables = Set<AnyCancellable>()

    func placeholder(in context: Context) -> PositiveStatementEntry {
        PositiveStatementEntry(date: Date(), content: .positiveStatement("Placeholder"))
    }

    func getSnapshot(in context: Context, completion: @escaping (PositiveStatementEntry) -> ()) {
        let entry = PositiveStatementEntry(date: Date(), content: .positiveStatement("from getSnapshot"))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        positiveStatementManager
            .getPositiveStatements()
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        let errorType = error as? PositiveStatementWidgetError ?? .dataNotFound
                        let timeline = Timeline(
                            entries: [PositiveStatementEntry(date: Date(), content: .errorMessage(errorType.errorMessage))],
                            policy: .never
                        )
                        completion(timeline)
                    case .finished:
                        return
                    }
                },
                receiveValue: { [weak self] statements in
                    let entries = self?.createTimelineEntries(positiveStatements: statements) ?? []
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                }
            )
            .store(in: &cancellables)
    }
}

private extension PositiveStatementProvider {
    func createTimelineEntries(positiveStatements: [String]) -> [PositiveStatementEntry] {
        var entries = [PositiveStatementEntry]()
        var displayDate = Date()

        for statement in positiveStatements {
            let entry = PositiveStatementEntry(
                date: displayDate,
                content: .positiveStatement(statement)
            )

            entries.append(entry)

            displayDate = Calendar.current.date(
                byAdding: .hour,
                value: statementRefreshIntervalInHours,
                to: displayDate
            ) ?? displayDate
        }

        return entries
    }
}

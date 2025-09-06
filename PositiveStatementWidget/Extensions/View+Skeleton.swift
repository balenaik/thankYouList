//
//  View+Skeleton.swift
//  PositiveStatementWidget
//
//  Created by Aika Yamada on 2025/04/10.
//  Copyright © 2025 Aika Yamada. All rights reserved.
//

import SwiftUI

extension View {
    func showsSkeleton(_ shows: Bool) -> some View {
        self.redacted(reason: shows ? .placeholder : .init())
    }
}

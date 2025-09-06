//
//  ViewLifecycleAwareHostingController.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2024/06/23.
//  Copyright © 2024 Aika Yamada. All rights reserved.
//

import Combine
import SwiftUI

class ViewLifecycleAwareHostingController<Content>: UIHostingController<Content> where Content: View {
    let viewWillAppearRelay = PassthroughSubject<Void, Never>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearRelay.send()
    }
}

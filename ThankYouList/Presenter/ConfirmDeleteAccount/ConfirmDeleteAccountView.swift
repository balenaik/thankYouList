//
//  ConfirmDeleteAccountView.swift
//  ThankYouList
//
//  Created by Aika Yamada on 2022/12/25.
//  Copyright © 2022 Aika Yamada. All rights reserved.
//

import SwiftUI

struct ConfirmDeleteAccountView: View {

    @StateObject var viewModel: ConfirmDeleteAccountViewModel

    var body: some View {
        VStack {
            Text("Confirm your mail")
                .font(.largeTitle)

            Spacer()

            Text("Complete your deletion request by entering the email address associated with your account")
                .padding(20)

            Spacer()
        }
    }
}

struct ConfirmDeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmDeleteAccountView(viewModel: ConfirmDeleteAccountViewModel())
    }
}

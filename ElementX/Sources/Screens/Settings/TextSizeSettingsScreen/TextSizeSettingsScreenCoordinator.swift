//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct TextSizeSettingsScreenCoordinatorParameters {
    let appSettings: AppSettings
}

final class TextSizeSettingsScreenCoordinator: CoordinatorProtocol {
    private var viewModel: TextSizeSettingsScreenViewModelProtocol
    
    init(parameters: TextSizeSettingsScreenCoordinatorParameters) {
        viewModel = TextSizeSettingsScreenViewModel(appSettings: parameters.appSettings as TextSizeSettingsProtocol)
    }
            
    func toPresentable() -> AnyView {
        AnyView(TextSizeSettingsScreen(context: viewModel.context))
    }
}

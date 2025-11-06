//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct AppearanceSettingsScreenCoordinatorParameters {
    let appSettings: AppSettings
}

final class AppearanceSettingsScreenCoordinator: CoordinatorProtocol {
    private var viewModel: AppearanceSettingsScreenViewModelProtocol
    
    init(parameters: AppearanceSettingsScreenCoordinatorParameters) {
        viewModel = AppearanceSettingsScreenViewModel(appSettings: parameters.appSettings)
    }
            
    func toPresentable() -> AnyView {
        AnyView(AppearanceSettingsScreen(context: viewModel.context))
    }
}


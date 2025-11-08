//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct HeaderGradientSettingsScreenCoordinatorParameters {
    let appSettings: AppSettings
}

final class HeaderGradientSettingsScreenCoordinator: CoordinatorProtocol {
    private var viewModel: HeaderGradientSettingsScreenViewModelProtocol
    
    init(parameters: HeaderGradientSettingsScreenCoordinatorParameters) {
        viewModel = HeaderGradientSettingsScreenViewModel(appSettings: parameters.appSettings)
    }
            
    func toPresentable() -> AnyView {
        AnyView(HeaderGradientSettingsScreen(context: viewModel.context))
    }
}


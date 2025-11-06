//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias AppearanceSettingsScreenViewModelType = StateStoreViewModelV2<AppearanceSettingsScreenViewState, AppearanceSettingsScreenViewAction>

class AppearanceSettingsScreenViewModel: AppearanceSettingsScreenViewModelType, AppearanceSettingsScreenViewModelProtocol {
    init(appSettings: AppearanceSettingsProtocol) {
        let state = AppearanceSettingsScreenViewState(bindings: .init(appSettings: appSettings))
        super.init(initialViewState: state)
    }
    
    override func process(viewAction: AppearanceSettingsScreenViewAction) {
        // No actions needed for now
    }
}


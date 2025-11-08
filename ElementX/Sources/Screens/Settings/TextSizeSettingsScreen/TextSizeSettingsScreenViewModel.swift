//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias TextSizeSettingsScreenViewModelType = StateStoreViewModelV2<TextSizeSettingsScreenViewState, TextSizeSettingsScreenViewAction>

class TextSizeSettingsScreenViewModel: TextSizeSettingsScreenViewModelType, TextSizeSettingsScreenViewModelProtocol {
    init(appSettings: TextSizeSettingsProtocol) {
        let state = TextSizeSettingsScreenViewState(bindings: .init(appSettings: appSettings))
        super.init(initialViewState: state)
    }
    
    override func process(viewAction: TextSizeSettingsScreenViewAction) {
        // No actions needed for now
    }
}


//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

struct HeaderGradientSettingsScreenViewState: BindableState {
    var bindings: HeaderGradientSettingsScreenViewStateBindings
}

@dynamicMemberLookup
struct HeaderGradientSettingsScreenViewStateBindings {
    private let appSettings: HeaderGradientSettingsProtocol

    init(appSettings: HeaderGradientSettingsProtocol) {
        self.appSettings = appSettings
    }

    subscript<Setting>(dynamicMember keyPath: ReferenceWritableKeyPath<HeaderGradientSettingsProtocol, Setting>) -> Setting {
        get { appSettings[keyPath: keyPath] }
        set { appSettings[keyPath: keyPath] = newValue }
    }
}

enum HeaderGradientSettingsScreenViewAction {
    // No actions needed for now, header gradient changes are handled via bindings
}

protocol HeaderGradientSettingsProtocol: AnyObject {
    var headerGradientEnabled: Bool { get set }
}

extension AppSettings: HeaderGradientSettingsProtocol { }


//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

struct AppearanceSettingsScreenViewState: BindableState {
    var bindings: AppearanceSettingsScreenViewStateBindings
}

// periphery:ignore - subscript are seen as false positives
@dynamicMemberLookup
struct AppearanceSettingsScreenViewStateBindings {
    private let appSettings: AppearanceSettingsProtocol

    init(appSettings: AppearanceSettingsProtocol) {
        self.appSettings = appSettings
    }

    subscript<Setting>(dynamicMember keyPath: ReferenceWritableKeyPath<AppearanceSettingsProtocol, Setting>) -> Setting {
        get { appSettings[keyPath: keyPath] }
        set { appSettings[keyPath: keyPath] = newValue }
    }
}

enum AppearanceSettingsScreenViewAction {
    // No actions needed for now, appearance changes are handled via bindings
}

protocol AppearanceSettingsProtocol: AnyObject {
    var appAppearance: AppAppearance { get set }
}

extension AppSettings: AppearanceSettingsProtocol { }

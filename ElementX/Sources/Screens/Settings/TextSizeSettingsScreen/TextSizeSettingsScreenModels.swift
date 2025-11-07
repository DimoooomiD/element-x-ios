//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

struct TextSizeSettingsScreenViewState: BindableState {
    var bindings: TextSizeSettingsScreenViewStateBindings
}

@dynamicMemberLookup
struct TextSizeSettingsScreenViewStateBindings {
    private let appSettings: TextSizeSettingsProtocol

    init(appSettings: TextSizeSettingsProtocol) {
        self.appSettings = appSettings
    }

    subscript<Setting>(dynamicMember keyPath: ReferenceWritableKeyPath<TextSizeSettingsProtocol, Setting>) -> Setting {
        get { appSettings[keyPath: keyPath] }
        set { appSettings[keyPath: keyPath] = newValue }
    }
}

enum TextSizeSettingsScreenViewAction {
    // No actions needed for now, text size changes are handled via bindings
}

protocol TextSizeSettingsProtocol: AnyObject {
    var chatRoomTextSize: Double { get set }
}

extension AppSettings: TextSizeSettingsProtocol { }


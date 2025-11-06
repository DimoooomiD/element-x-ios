//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// Used to specify the user's app specific appearance preference
enum AppAppearance: CaseIterable, Codable {
    case system
    case dark
    case darkBlue
    case darkGreen
    case darkPurple
    case darkGray
    case darkRed
    case darkOrange
    case light
    case lightGray
    case lightBlue
        
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light, .lightGray, .lightBlue:
            return .light
        case .dark, .darkBlue, .darkGreen, .darkPurple, .darkGray, .darkRed, .darkOrange:
            return .dark
        case .system:
            return .unspecified
        }
    }
}

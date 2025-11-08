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
    case light
    case dark
    // Professional dark themes
    case darkTeal
    case darkIndigo
    case darkSlate
    case darkNavy
    case darkForest
    case darkSteel
    // Professional light themes
    case lightTeal
    case lightIndigo
    case lightSlate
    case lightRose
    case lightCream
    case lightAzure
    case lightPearl
        
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light, .lightTeal, .lightIndigo, .lightSlate, .lightRose, .lightCream, .lightAzure, .lightPearl:
            return .light
        case .dark, .darkTeal, .darkIndigo, .darkSlate, .darkNavy, .darkForest, .darkSteel:
            return .dark
        case .system:
            return .unspecified
        }
    }
}

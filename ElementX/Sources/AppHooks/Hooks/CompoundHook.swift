//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import CompoundDesignTokens
import SwiftUI

protocol CompoundHookProtocol {
    func override(colors: CompoundColors, uiColors: CompoundUIColors)
}

struct DefaultCompoundHook: CompoundHookProtocol {
    func override(colors: CompoundColors, uiColors: CompoundUIColors) {
        // Override bgCanvasDefault for dark mode with a dark blue (not black)
        // RGB: (0.10, 0.15, 0.25) - a dark blue that's lighter than black
        // This creates a dynamic color that adapts to light/dark mode
        // Applies to all screens including HomeScreen and SettingsScreen
        let darkBlueBackground = Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                // Dark mode: dark blue instead of black
                return UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
            } else {
                // Light mode: use the default from tokens
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgCanvasDefault)
            }
        })
        
        // Override bgSubtleSecondaryLevel0 for dark mode (used by Form/List backgrounds)
        // SettingsScreen uses .compoundList() which applies bgSubtleSecondaryLevel0
        let darkBlueFormBackground = Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                // Dark mode: dark blue instead of black
                return UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
            } else {
                // Light mode: use the default from tokens
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgSubtleSecondaryLevel0)
            }
        })
        
        colors.override(\.bgCanvasDefault, with: darkBlueBackground)
        uiColors.override(\.bgCanvasDefault, with: UIColor(darkBlueBackground))
        
        colors.override(\.bgSubtleSecondaryLevel0, with: darkBlueFormBackground)
        uiColors.override(\.bgSubtleSecondaryLevel0, with: UIColor(darkBlueFormBackground))
    }
}

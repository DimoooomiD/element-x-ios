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
        // Create dynamic colors that check AppSettings.appAppearance at runtime
        // Only apply dark blue when darkBlue is selected, otherwise use default dark theme
        
        let customBackground = Color(UIColor { traitCollection in
            guard traitCollection.userInterfaceStyle == .dark else {
                // Light mode: use the default from tokens
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgCanvasDefault)
            }
            
            // Dark mode: check if darkBlue is selected
            guard let appSettings = ServiceLocator.shared.settings else {
                // If settings not available yet, use default dark theme
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgCanvasDefault)
            }
            if appSettings.appAppearance == .darkBlue {
                // Dark Blue theme: RGB (0.10, 0.15, 0.25)
                return UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
            } else {
                // Default dark theme: use the default from tokens
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgCanvasDefault)
            }
        })
        
        let customFormBackground = Color(UIColor { traitCollection in
            guard traitCollection.userInterfaceStyle == .dark else {
                // Light mode: use the default from tokens
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgSubtleSecondaryLevel0)
            }
            
            // Dark mode: check if darkBlue is selected
            guard let appSettings = ServiceLocator.shared.settings else {
                // If settings not available yet, use default dark theme
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgSubtleSecondaryLevel0)
            }
            if appSettings.appAppearance == .darkBlue {
                // Dark Blue theme: RGB (0.10, 0.15, 0.25)
                return UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
            } else {
                // Default dark theme: use the default from tokens
                let tokens = CompoundColorTokens()
                return UIColor(tokens.bgSubtleSecondaryLevel0)
            }
        })
        
        colors.override(\.bgCanvasDefault, with: customBackground)
        uiColors.override(\.bgCanvasDefault, with: UIColor(customBackground))
        
        colors.override(\.bgSubtleSecondaryLevel0, with: customFormBackground)
        uiColors.override(\.bgSubtleSecondaryLevel0, with: UIColor(customFormBackground))
    }
}

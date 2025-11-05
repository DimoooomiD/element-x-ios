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
        let tokens = CompoundColorTokens()
        
        // Create dynamic colors for dark blue theme
        let customBackground = createDynamicColor(
            lightModeToken: tokens.bgCanvasDefault,
            darkModeToken: tokens.bgCanvasDefault,
            darkBlueColor: UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
        )
        
        let customFormBackground = createDynamicColor(
            lightModeToken: tokens.bgSubtleSecondaryLevel0,
            darkModeToken: tokens.bgSubtleSecondaryLevel0,
            darkBlueColor: UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
        )
        
        let customRowBackground = createDynamicColor(
            lightModeToken: tokens.bgCanvasDefaultLevel1,
            darkModeToken: tokens.bgCanvasDefaultLevel1,
            darkBlueColor: UIColor(red: 0.15, green: 0.20, blue: 0.30, alpha: 1.0)
        )
        
        let customPressedBackground = createDynamicColor(
            lightModeToken: tokens.bgSubtlePrimary,
            darkModeToken: tokens.bgSubtlePrimary,
            darkBlueColor: UIColor(red: 0.20, green: 0.25, blue: 0.35, alpha: 1.0)
        )
        
        let customSubtleSecondary = createDynamicColor(
            lightModeToken: tokens.bgSubtleSecondary,
            darkModeToken: tokens.bgSubtleSecondary,
            darkBlueColor: UIColor(red: 0.18, green: 0.23, blue: 0.33, alpha: 1.0)
        )
        
        // Apply overrides
        applyColorOverride(colors: colors, uiColors: uiColors,
                          colorKeyPath: \.bgCanvasDefault,
                          uiColorKeyPath: \.bgCanvasDefault,
                          color: customBackground)
        applyColorOverride(colors: colors, uiColors: uiColors,
                          colorKeyPath: \.bgSubtleSecondaryLevel0,
                          uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                          color: customFormBackground)
        applyColorOverride(colors: colors, uiColors: uiColors,
                          colorKeyPath: \.bgCanvasDefaultLevel1,
                          uiColorKeyPath: \.bgCanvasDefaultLevel1,
                          color: customRowBackground)
        applyColorOverride(colors: colors, uiColors: uiColors,
                          colorKeyPath: \.bgSubtlePrimary,
                          uiColorKeyPath: \.bgSubtlePrimary,
                          color: customPressedBackground)
        applyColorOverride(colors: colors, uiColors: uiColors,
                          colorKeyPath: \.bgSubtleSecondary,
                          uiColorKeyPath: \.bgSubtleSecondary,
                          color: customSubtleSecondary)
    }
    
    // MARK: - Helper Functions
    
    /// Creates a dynamic color that switches between light mode, default dark mode, and dark blue theme
    private func createDynamicColor(lightModeToken: Color,
                                    darkModeToken: Color,
                                    darkBlueColor: UIColor) -> Color {
        Color(UIColor { traitCollection in
            guard traitCollection.userInterfaceStyle == .dark else {
                return UIColor(lightModeToken)
            }
            
            guard let appSettings = ServiceLocator.shared.settings,
                  appSettings.appAppearance == .darkBlue else {
                return UIColor(darkModeToken)
            }
            
            return darkBlueColor
        })
    }
    
    /// Applies color overrides to both CompoundColors and CompoundUIColors
    private func applyColorOverride(colors: CompoundColors,
                                    uiColors: CompoundUIColors,
                                    colorKeyPath: KeyPath<CompoundColorTokens, Color>,
                                    uiColorKeyPath: KeyPath<CompoundUIColorTokens, UIColor>,
                                    color: Color) {
        colors.override(colorKeyPath, with: color)
        uiColors.override(uiColorKeyPath, with: UIColor(color))
    }
}

// Extension to provide helper functions for bubble colors that check app appearance
extension CompoundColors {
    /// Returns the appropriate bubble color for incoming messages based on app appearance
    var bubbleIncomingColor: Color {
        guard let appSettings = ServiceLocator.shared.settings,
              appSettings.appAppearance == .darkBlue else {
            return self._bgBubbleIncoming
        }
        // Dark Blue theme: slightly lighter blue for incoming bubbles
        return Color(UIColor(red: 0.16, green: 0.21, blue: 0.31, alpha: 1.0))
    }
    
    /// Returns the appropriate bubble color for outgoing messages based on app appearance
    var bubbleOutgoingColor: Color {
        guard let appSettings = ServiceLocator.shared.settings,
              appSettings.appAppearance == .darkBlue else {
            return self._bgBubbleOutgoing
        }
        // Dark Blue theme: lighter blue for outgoing bubbles (user's messages)
        return Color(UIColor(red: 0.22, green: 0.28, blue: 0.38, alpha: 1.0))
    }
}

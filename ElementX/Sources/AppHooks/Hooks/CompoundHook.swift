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
        // Apply theme configurations for all registered themes
        for themeConfig in ThemeConfigurationRegistry.allConfigurations {
            applyThemeConfiguration(themeConfig, to: colors, uiColors: uiColors)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Applies a theme configuration to the color system
    private func applyThemeConfiguration(_ config: ThemeConfiguration,
                                        to colors: CompoundColors,
                                        uiColors: CompoundUIColors) {
        for colorOverride in config.colorOverrides {
            let dynamicColor = createDynamicColor(
                lightModeToken: colorOverride.lightModeColor,
                darkModeToken: colorOverride.darkModeColor,
                themeColor: colorOverride.themeColor,
                themeAppearance: config.appearance
            )
            
            applyColorOverride(colors: colors,
                             uiColors: uiColors,
                             colorKeyPath: colorOverride.colorKeyPath,
                             uiColorKeyPath: colorOverride.uiColorKeyPath,
                             color: dynamicColor)
        }
    }
    
    /// Creates a dynamic color that switches between light mode, default dark mode, and theme-specific colors
    private func createDynamicColor(lightModeToken: Color,
                                    darkModeToken: Color,
                                    themeColor: UIColor,
                                    themeAppearance: AppAppearance) -> Color {
        Color(UIColor { traitCollection in
            guard traitCollection.userInterfaceStyle == .dark else {
                return UIColor(lightModeToken)
            }
            
            guard let appSettings = ServiceLocator.shared.settings,
                  appSettings.appAppearance == themeAppearance else {
                return UIColor(darkModeToken)
            }
            
            return themeColor
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
              let themeConfig = ThemeConfigurationRegistry.configuration(for: appSettings.appAppearance),
              let themeColor = themeConfig.bubbleIncomingColor else {
            return self._bgBubbleIncoming
        }
        return Color(themeColor)
    }
    
    /// Returns the appropriate bubble color for outgoing messages based on app appearance
    var bubbleOutgoingColor: Color {
        guard let appSettings = ServiceLocator.shared.settings,
              let themeConfig = ThemeConfigurationRegistry.configuration(for: appSettings.appAppearance),
              let themeColor = themeConfig.bubbleOutgoingColor else {
            return self._bgBubbleOutgoing
        }
        return Color(themeColor)
    }
}

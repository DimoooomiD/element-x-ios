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

/// Holds color override data for a specific color key path
private struct ColorOverrideData {
    let lightMode: Color
    let darkMode: Color
    var themeOverrides: [AppAppearance: UIColor]
    let uiColorKeyPath: KeyPath<CompoundUIColorTokens, UIColor>
}

struct DefaultCompoundHook: CompoundHookProtocol {
    func override(colors: CompoundColors, uiColors: CompoundUIColors) {
        // Collect all color overrides by key path to create unified dynamic colors
        var colorOverridesMap: [KeyPath<CompoundColorTokens, Color>: ColorOverrideData] = [:]
        
        // First pass: collect all overrides from all themes
        for themeConfig in ThemeConfigurationRegistry.allConfigurations {
            for colorOverride in themeConfig.colorOverrides {
                if colorOverridesMap[colorOverride.colorKeyPath] == nil {
                    colorOverridesMap[colorOverride.colorKeyPath] = ColorOverrideData(
                        lightMode: colorOverride.lightModeColor,
                        darkMode: colorOverride.darkModeColor,
                        themeOverrides: [:],
                        uiColorKeyPath: colorOverride.uiColorKeyPath
                    )
                }
                // Need to reassign to update the dictionary value
                var colorData = colorOverridesMap[colorOverride.colorKeyPath]!
                colorData.themeOverrides[themeConfig.appearance] = colorOverride.themeColor
                colorOverridesMap[colorOverride.colorKeyPath] = colorData
            }
        }
        
        // Second pass: apply unified dynamic colors that check all themes
        for (colorKeyPath, colorData) in colorOverridesMap {
            let dynamicColor = createUnifiedDynamicColor(
                lightModeToken: colorData.lightMode,
                darkModeToken: colorData.darkMode,
                themeOverrides: colorData.themeOverrides
            )
            
            applyColorOverride(colors: colors,
                             uiColors: uiColors,
                             colorKeyPath: colorKeyPath,
                             uiColorKeyPath: colorData.uiColorKeyPath,
                             color: dynamicColor)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Creates a unified dynamic color that checks all registered themes
    private func createUnifiedDynamicColor(lightModeToken: Color,
                                          darkModeToken: Color,
                                          themeOverrides: [AppAppearance: UIColor]) -> Color {
        Color(UIColor { traitCollection in
            guard traitCollection.userInterfaceStyle == .dark else {
                return UIColor(lightModeToken)
            }
            
            guard let appSettings = ServiceLocator.shared.settings,
                  let themeColor = themeOverrides[appSettings.appAppearance] else {
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

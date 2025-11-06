//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import CompoundDesignTokens
import SwiftUI
import UIKit

/// Protocol defining the color configuration for a theme
protocol ThemeConfiguration {
    /// The appearance this theme applies to
    var appearance: AppAppearance { get }
    
    /// Color overrides for this theme
    var colorOverrides: [ThemeColorOverride] { get }
    
    /// Bubble color for incoming messages (optional - uses default if nil)
    var bubbleIncomingColor: UIColor? { get }
    
    /// Bubble color for outgoing messages (optional - uses default if nil)
    var bubbleOutgoingColor: UIColor? { get }
}

/// Represents a color override for a specific token
struct ThemeColorOverride {
    let colorKeyPath: KeyPath<CompoundColorTokens, Color>
    let uiColorKeyPath: KeyPath<CompoundUIColorTokens, UIColor>
    let lightModeColor: Color
    let darkModeColor: Color
    let themeColor: UIColor
}

// MARK: - Dark Blue Theme Configuration

struct DarkBlueThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkBlue
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.15, green: 0.20, blue: 0.30, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.20, green: 0.25, blue: 0.35, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.18, green: 0.23, blue: 0.33, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.16, green: 0.21, blue: 0.31, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.22, green: 0.28, blue: 0.38, alpha: 1.0)
    }
}

// MARK: - Dark Green Theme Configuration

struct DarkGreenThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkGreen
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.10, green: 0.20, blue: 0.15, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.10, green: 0.20, blue: 0.15, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.15, green: 0.25, blue: 0.20, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.20, green: 0.30, blue: 0.25, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.18, green: 0.28, blue: 0.23, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.16, green: 0.26, blue: 0.21, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.22, green: 0.32, blue: 0.27, alpha: 1.0)
    }
}

// MARK: - Dark Purple Theme Configuration

struct DarkPurpleThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkPurple
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.15, green: 0.10, blue: 0.20, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.20, green: 0.15, blue: 0.25, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.25, green: 0.20, blue: 0.30, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.23, green: 0.18, blue: 0.28, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.21, green: 0.16, blue: 0.26, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.28, green: 0.23, blue: 0.33, alpha: 1.0)
    }
}

// MARK: - Dark Gray Theme Configuration

struct DarkGrayThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkGray
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.21, green: 0.21, blue: 0.21, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.27, green: 0.27, blue: 0.27, alpha: 1.0)
    }
}

// MARK: - Dark Red Theme Configuration

struct DarkRedThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkRed
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.20, green: 0.12, blue: 0.14, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.20, green: 0.12, blue: 0.14, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.25, green: 0.17, blue: 0.19, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.30, green: 0.22, blue: 0.24, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.28, green: 0.20, blue: 0.22, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.26, green: 0.18, blue: 0.20, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.32, green: 0.24, blue: 0.26, alpha: 1.0)
    }
}

// MARK: - Dark Orange Theme Configuration

struct DarkOrangeThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkOrange
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.22, green: 0.16, blue: 0.10, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.22, green: 0.16, blue: 0.10, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.27, green: 0.21, blue: 0.15, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.32, green: 0.26, blue: 0.20, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.30, green: 0.24, blue: 0.18, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.28, green: 0.22, blue: 0.16, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.34, green: 0.28, blue: 0.22, alpha: 1.0)
    }
}

// MARK: - Light Gray Theme Configuration

struct LightGrayThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightGray
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
    }
}

// MARK: - Light Blue Theme Configuration

struct LightBlueThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightBlue
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefault,
                uiColorKeyPath: \.bgCanvasDefault,
                lightModeColor: tokens.bgCanvasDefault,
                darkModeColor: tokens.bgCanvasDefault,
                themeColor: UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondaryLevel0,
                uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                lightModeColor: tokens.bgSubtleSecondaryLevel0,
                darkModeColor: tokens.bgSubtleSecondaryLevel0,
                themeColor: UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgCanvasDefaultLevel1,
                uiColorKeyPath: \.bgCanvasDefaultLevel1,
                lightModeColor: tokens.bgCanvasDefaultLevel1,
                darkModeColor: tokens.bgCanvasDefaultLevel1,
                themeColor: UIColor(red: 0.93, green: 0.95, blue: 0.97, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtlePrimary,
                uiColorKeyPath: \.bgSubtlePrimary,
                lightModeColor: tokens.bgSubtlePrimary,
                darkModeColor: tokens.bgSubtlePrimary,
                themeColor: UIColor(red: 0.90, green: 0.93, blue: 0.96, alpha: 1.0)
            ),
            ThemeColorOverride(
                colorKeyPath: \.bgSubtleSecondary,
                uiColorKeyPath: \.bgSubtleSecondary,
                lightModeColor: tokens.bgSubtleSecondary,
                darkModeColor: tokens.bgSubtleSecondary,
                themeColor: UIColor(red: 0.92, green: 0.94, blue: 0.97, alpha: 1.0)
            )
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.94, green: 0.96, blue: 0.98, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.88, green: 0.91, blue: 0.95, alpha: 1.0)
    }
}

// MARK: - Theme Configuration Registry

/// Registry that maps AppAppearance to ThemeConfiguration
struct ThemeConfigurationRegistry {
    /// All registered theme configurations
    static let allConfigurations: [ThemeConfiguration] = [
        DarkBlueThemeConfiguration(),
        DarkGreenThemeConfiguration(),
        DarkPurpleThemeConfiguration(),
        DarkGrayThemeConfiguration(),
        DarkRedThemeConfiguration(),
        DarkOrangeThemeConfiguration(),
        LightGrayThemeConfiguration(),
        LightBlueThemeConfiguration()
    ]
    
    /// Get configuration for a specific appearance
    static func configuration(for appearance: AppAppearance) -> ThemeConfiguration? {
        allConfigurations.first { $0.appearance == appearance }
    }
}


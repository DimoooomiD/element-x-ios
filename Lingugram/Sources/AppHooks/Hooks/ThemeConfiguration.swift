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

// MARK: - Dark Teal Theme Configuration

struct DarkTealThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkTeal
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.08, green: 0.18, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.08, green: 0.18, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.12, green: 0.22, blue: 0.24, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.16, green: 0.26, blue: 0.28, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.14, green: 0.24, blue: 0.26, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.13, green: 0.23, blue: 0.25, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.18, green: 0.28, blue: 0.30, alpha: 1.0)
    }
}

// MARK: - Dark Indigo Theme Configuration

struct DarkIndigoThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkIndigo
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.11, green: 0.12, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.11, green: 0.12, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.16, green: 0.17, blue: 0.25, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.21, green: 0.22, blue: 0.30, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.19, green: 0.20, blue: 0.28, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.17, green: 0.18, blue: 0.26, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.23, green: 0.24, blue: 0.32, alpha: 1.0)
    }
}

// MARK: - Dark Slate Theme Configuration

struct DarkSlateThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkSlate
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.14, green: 0.16, blue: 0.18, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.14, green: 0.16, blue: 0.18, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.19, green: 0.21, blue: 0.23, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.24, green: 0.26, blue: 0.28, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.22, green: 0.24, blue: 0.26, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.20, green: 0.22, blue: 0.24, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.26, green: 0.28, blue: 0.30, alpha: 1.0)
    }
}

// MARK: - Dark Blue Theme Configuration (Lingugram)

struct DarkBlueThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkBlue
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        // Based on static background with gradient colors:
        // Base: Color(red: 0.06, green: 0.09, blue: 0.16)
        // Gradients: Purple/Indigo (#6366f1, #8b5cf6), Cyan (#06b6d4), Blue (#3b82f6)
        // Colors blend the base with gradient colors to create visible gradient-inspired palette
        // Blending formula: base * 0.7 + gradient * 0.3 for visible gradient influence
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               // Base dark blue with subtle purple/indigo blend
                               themeColor: UIColor(red: 0.08, green: 0.10, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               // Base with indigo tint
                               themeColor: UIColor(red: 0.08, green: 0.10, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               // Base blended with purple/indigo gradient (#6366f1 influence)
                               themeColor: UIColor(red: 0.12, green: 0.13, blue: 0.28, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               // Enhanced with purple/cyan gradient blend (#8b5cf6 + #06b6d4 influence)
                               themeColor: UIColor(red: 0.14, green: 0.16, blue: 0.32, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               // Blend with cyan/blue gradient tones (#06b6d4 + #3b82f6 influence)
                               themeColor: UIColor(red: 0.10, green: 0.15, blue: 0.26, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        // Base with purple/indigo gradient influence (#6366f1 blend)
        UIColor(red: 0.11, green: 0.13, blue: 0.25, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        // Enhanced with cyan/blue gradient influence (#3b82f6 blend)
        UIColor(red: 0.15, green: 0.18, blue: 0.32, alpha: 1.0)
    }
}

// MARK: - Dark Navy Theme Configuration

struct DarkNavyThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkNavy
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.07, green: 0.10, blue: 0.18, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.07, green: 0.10, blue: 0.18, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.11, green: 0.14, blue: 0.22, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.15, green: 0.18, blue: 0.26, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.12, green: 0.15, blue: 0.23, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.17, green: 0.20, blue: 0.28, alpha: 1.0)
    }
}

// MARK: - Dark Forest Theme Configuration

struct DarkForestThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkForest
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.10, green: 0.15, blue: 0.12, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.10, green: 0.15, blue: 0.12, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.14, green: 0.19, blue: 0.16, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.18, green: 0.23, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.16, green: 0.21, blue: 0.18, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.15, green: 0.20, blue: 0.17, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.20, green: 0.25, blue: 0.22, alpha: 1.0)
    }
}

// MARK: - Dark Steel Theme Configuration

struct DarkSteelThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .darkSteel
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.16, green: 0.18, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.16, green: 0.18, blue: 0.20, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.21, green: 0.23, blue: 0.25, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.26, green: 0.28, blue: 0.30, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.24, green: 0.26, blue: 0.28, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.22, green: 0.24, blue: 0.26, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.28, green: 0.30, blue: 0.32, alpha: 1.0)
    }
}

// MARK: - Light Teal Theme Configuration

struct LightTealThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightTeal
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.97, green: 0.99, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.97, green: 0.99, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.94, green: 0.98, blue: 0.98, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.91, green: 0.96, blue: 0.96, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.93, green: 0.97, blue: 0.97, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.95, green: 0.98, blue: 0.98, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.89, green: 0.95, blue: 0.95, alpha: 1.0)
    }
}

// MARK: - Light Indigo Theme Configuration

struct LightIndigoThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightIndigo
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.92, green: 0.93, blue: 0.96, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1.0)
    }
}

// MARK: - Light Slate Theme Configuration

struct LightSlateThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightSlate
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.92, green: 0.93, blue: 0.94, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.94, green: 0.95, blue: 0.96, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.90, green: 0.91, blue: 0.92, alpha: 1.0)
    }
}

// MARK: - Light Rose Theme Configuration

struct LightRoseThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightRose
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.99, green: 0.97, blue: 0.97, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.99, green: 0.97, blue: 0.97, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.97, green: 0.93, blue: 0.93, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.98, green: 0.95, blue: 0.95, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.98, green: 0.96, blue: 0.96, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.96, green: 0.92, blue: 0.92, alpha: 1.0)
    }
}

// MARK: - Light Cream Theme Configuration

struct LightCreamThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightCream
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 1.00, green: 0.99, blue: 0.97, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 1.00, green: 0.99, blue: 0.97, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.99, green: 0.98, blue: 0.97, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1.0)
    }
}

// MARK: - Light Azure Theme Configuration

struct LightAzureThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightAzure
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.98, green: 0.99, blue: 1.00, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.98, green: 0.99, blue: 1.00, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.95, green: 0.97, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.92, green: 0.95, blue: 0.98, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.96, green: 0.98, blue: 1.00, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.90, green: 0.93, blue: 0.97, alpha: 1.0)
    }
}

// MARK: - Light Pearl Theme Configuration

struct LightPearlThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lightPearl
    }
    
    var colorOverrides: [ThemeColorOverride] {
        let tokens = CompoundColorTokens()
        
        return [
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefault,
                               uiColorKeyPath: \.bgCanvasDefault,
                               lightModeColor: tokens.bgCanvasDefault,
                               darkModeColor: tokens.bgCanvasDefault,
                               themeColor: UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondaryLevel0,
                               uiColorKeyPath: \.bgSubtleSecondaryLevel0,
                               lightModeColor: tokens.bgSubtleSecondaryLevel0,
                               darkModeColor: tokens.bgSubtleSecondaryLevel0,
                               themeColor: UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgCanvasDefaultLevel1,
                               uiColorKeyPath: \.bgCanvasDefaultLevel1,
                               lightModeColor: tokens.bgCanvasDefaultLevel1,
                               darkModeColor: tokens.bgCanvasDefaultLevel1,
                               themeColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtlePrimary,
                               uiColorKeyPath: \.bgSubtlePrimary,
                               lightModeColor: tokens.bgSubtlePrimary,
                               darkModeColor: tokens.bgSubtlePrimary,
                               themeColor: UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)),
            ThemeColorOverride(colorKeyPath: \.bgSubtleSecondary,
                               uiColorKeyPath: \.bgSubtleSecondary,
                               lightModeColor: tokens.bgSubtleSecondary,
                               darkModeColor: tokens.bgSubtleSecondary,
                               themeColor: UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0))
        ]
    }
    
    var bubbleIncomingColor: UIColor? {
        UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
    }
    
    var bubbleOutgoingColor: UIColor? {
        UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1.0)
    }
}

// MARK: - Theme Configuration Registry

/// Registry that maps AppAppearance to ThemeConfiguration
enum ThemeConfigurationRegistry {
    /// All registered theme configurations
    static let allConfigurations: [ThemeConfiguration] = [
        DarkTealThemeConfiguration(),
        DarkIndigoThemeConfiguration(),
        DarkSlateThemeConfiguration(),
        DarkNavyThemeConfiguration(),
        DarkForestThemeConfiguration(),
        DarkSteelThemeConfiguration(),
        DarkBlueThemeConfiguration(),
        LightTealThemeConfiguration(),
        LightIndigoThemeConfiguration(),
        LightSlateThemeConfiguration(),
        LightRoseThemeConfiguration(),
        LightCreamThemeConfiguration(),
        LightAzureThemeConfiguration(),
        LightPearlThemeConfiguration()
    ]
    
    /// Get configuration for a specific appearance
    static func configuration(for appearance: AppAppearance) -> ThemeConfiguration? {
        allConfigurations.first { $0.appearance == appearance }
    }
}

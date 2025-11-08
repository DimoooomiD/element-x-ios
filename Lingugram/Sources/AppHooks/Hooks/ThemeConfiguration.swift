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
    
    /// Optional gradient background for the main canvas (applies to bgCanvasDefault)
    var canvasGradient: ThemeGradient? { get }
}

/// Represents a gradient definition for theme backgrounds
/// Uses RGBA values and coordinates to make it Hashable
struct ThemeGradient: Hashable {
    enum GradientType: Hashable {
        case radial
        case linear
    }
    
    struct ColorComponent: Hashable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }
    
    let type: GradientType
    let colorComponents: [ColorComponent]
    let centerX: Double
    let centerY: Double
    let startRadius: CGFloat
    let endRadius: CGFloat
    let startPointX: Double
    let startPointY: Double
    let endPointX: Double
    let endPointY: Double
    
    /// Creates a radial gradient
    static func radial(colors: [Color], center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat) -> ThemeGradient {
        let colorComponents = colors.map { color in
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return ColorComponent(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        }
        return ThemeGradient(
            type: .radial,
            colorComponents: colorComponents,
            centerX: Double(center.x),
            centerY: Double(center.y),
            startRadius: startRadius,
            endRadius: endRadius,
            startPointX: 0, startPointY: 0, endPointX: 0, endPointY: 0
        )
    }
    
    /// Creates a linear gradient
    static func linear(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) -> ThemeGradient {
        let colorComponents = colors.map { color in
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return ColorComponent(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
        }
        return ThemeGradient(
            type: .linear,
            colorComponents: colorComponents,
            centerX: 0, centerY: 0,
            startRadius: 0, endRadius: 0,
            startPointX: Double(startPoint.x),
            startPointY: Double(startPoint.y),
            endPointX: Double(endPoint.x),
            endPointY: Double(endPoint.y)
        )
    }
    
    /// Converts the gradient to a SwiftUI View for use in backgrounds
    @ViewBuilder
    func asView() -> some View {
        let colors = colorComponents.map { components in
            Color(red: components.red, green: components.green, blue: components.blue, opacity: components.alpha)
        }
        
        switch type {
        case .radial:
            // For Lingugram theme, create a ZStack with multiple gradients like StaticLanguageLearningBackground
            if colors.count >= 8 {
                // This is the Lingugram gradient - use ZStack with multiple radial gradients
                ZStack {
                    // Base color
                    if let baseColor = colors.first {
                        baseColor
                            .ignoresSafeArea()
                    }
                    
                    // Multiple radial gradients at different positions (matching StaticLanguageLearningBackground)
                    // Use higher opacity for better visibility
                    RadialGradient(
                        colors: [
                            Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.15), // #6366f1 - increased opacity
                            Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.15), // #8b5cf6 - increased opacity
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.2, y: 0.5),
                        startRadius: 100,
                        endRadius: 800
                    )
                    .ignoresSafeArea()
                    
                    RadialGradient(
                        colors: [
                            Color(red: 0.80, green: 0.20, blue: 0.20).opacity(0.15), // Red accent - increased opacity
                            Color(red: 0.02, green: 0.71, blue: 0.83).opacity(0.15), // #06b6d4 - increased opacity
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.8, y: 0.2),
                        startRadius: 100,
                        endRadius: 800
                    )
                    .ignoresSafeArea()
                    
                    RadialGradient(
                        colors: [
                            Color(red: 0.02, green: 0.71, blue: 0.83).opacity(0.15), // #06b6d4 - increased opacity
                            Color(red: 0.23, green: 0.51, blue: 0.96).opacity(0.15), // #3b82f6 - increased opacity
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.4, y: 0.8),
                        startRadius: 100,
                        endRadius: 800
                    )
                    .ignoresSafeArea()
                }
            } else {
                // Fallback to single radial gradient for other themes
                RadialGradient(
                    colors: colors,
                    center: UnitPoint(x: centerX, y: centerY),
                    startRadius: startRadius,
                    endRadius: endRadius
                )
                .ignoresSafeArea()
            }
        case .linear:
            LinearGradient(
                colors: colors,
                startPoint: UnitPoint(x: startPointX, y: startPointY),
                endPoint: UnitPoint(x: endPointX, y: endPointY)
            )
            .ignoresSafeArea()
        }
    }
    
    /// Extracts a representative solid color from the gradient (for UIKit compatibility)
    func representativeColor() -> UIColor {
        if let first = colorComponents.first {
            return UIColor(red: first.red, green: first.green, blue: first.blue, alpha: first.alpha)
        }
        return UIColor.systemBackground
    }
}

/// Represents a color override for a specific token
struct ThemeColorOverride {
    let colorKeyPath: KeyPath<CompoundColorTokens, Color>
    let uiColorKeyPath: KeyPath<CompoundUIColorTokens, UIColor>
    let lightModeColor: Color
    let darkModeColor: Color
    let themeColor: UIColor
    /// Optional gradient override - if provided, this takes precedence over themeColor
    let themeGradient: ThemeGradient?
    
    init(colorKeyPath: KeyPath<CompoundColorTokens, Color>,
         uiColorKeyPath: KeyPath<CompoundUIColorTokens, UIColor>,
         lightModeColor: Color,
         darkModeColor: Color,
         themeColor: UIColor,
         themeGradient: ThemeGradient? = nil) {
        self.colorKeyPath = colorKeyPath
        self.uiColorKeyPath = uiColorKeyPath
        self.lightModeColor = lightModeColor
        self.darkModeColor = darkModeColor
        self.themeColor = themeColor
        self.themeGradient = themeGradient
    }
}

// MARK: - Lingugram Theme Configuration

struct LingugramThemeConfiguration: ThemeConfiguration {
    var appearance: AppAppearance {
        .lingugram
    }
    
    var canvasGradient: ThemeGradient? {
        // Create a gradient that matches StaticLanguageLearningBackground
        // Using the actual gradient colors with proper opacity blending
        let baseColor = Color(red: 0.06, green: 0.09, blue: 0.16)
        
        // Blend base with gradient colors at 20% opacity for better visibility
        // Original gradient colors: purple/indigo (#6366f1), purple (#8b5cf6), cyan (#06b6d4), blue (#3b82f6)
        // This creates a more visible gradient effect
        let purpleIndigoBlend = Color(
            red: (0.06 * 0.8) + (0.39 * 0.2),
            green: (0.09 * 0.8) + (0.40 * 0.2),
            blue: (0.16 * 0.8) + (0.95 * 0.2)
        )
        
        let purpleBlend = Color(
            red: (0.06 * 0.8) + (0.55 * 0.2),
            green: (0.09 * 0.8) + (0.36 * 0.2),
            blue: (0.16 * 0.8) + (0.96 * 0.2)
        )
        
        let cyanBlend = Color(
            red: (0.06 * 0.8) + (0.02 * 0.2),
            green: (0.09 * 0.8) + (0.71 * 0.2),
            blue: (0.16 * 0.8) + (0.83 * 0.2)
        )
        
        let blueBlend = Color(
            red: (0.06 * 0.8) + (0.23 * 0.2),
            green: (0.09 * 0.8) + (0.51 * 0.2),
            blue: (0.16 * 0.8) + (0.96 * 0.2)
        )
        
        // Create a radial gradient with multiple color stops for a richer effect
        // This better simulates the ZStack of multiple gradients
        return ThemeGradient.radial(
            colors: [
                baseColor,
                purpleIndigoBlend,
                purpleBlend,
                cyanBlend,
                blueBlend,
                cyanBlend,
                purpleBlend,
                baseColor
            ],
            center: UnitPoint(x: 0.5, y: 0.5),
            startRadius: 0,
            endRadius: 1200
        )
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

// MARK: - Theme Configuration Registry

/// Registry that maps AppAppearance to ThemeConfiguration
enum ThemeConfigurationRegistry {
    /// All registered theme configurations
    static let allConfigurations: [ThemeConfiguration] = [
        LingugramThemeConfiguration()
    ]
    
    /// Get configuration for a specific appearance
    static func configuration(for appearance: AppAppearance) -> ThemeConfiguration? {
        allConfigurations.first { $0.appearance == appearance }
    }
}

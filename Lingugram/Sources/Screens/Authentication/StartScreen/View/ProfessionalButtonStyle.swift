//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// A professional glassmorphism button style that matches the authentication screens
struct ProfessionalButtonStyle: ButtonStyle {
    var variant: Variant = .primary
    var isEnabled = true
    
    enum Variant {
        case primary
        case secondary
        case tertiary
    }
    
    @MainActor
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background)
            .overlay(overlay)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
    
    @MainActor
    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return .white
        case .secondary:
            return .white
        case .tertiary:
            return .white.opacity(0.9)
        }
    }
    
    @MainActor
    private var background: some View {
        Group {
            switch variant {
            case .primary:
                // Primary: Website gradient (indigo to purple)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(colors: [
                            Color(red: 0.39, green: 0.40, blue: 0.95), // #6366f1
                            Color(red: 0.55, green: 0.36, blue: 0.96) // #8b5cf6
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                    )
            case .secondary:
                // Secondary: More transparent glassmorphism
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        LinearGradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
            case .tertiary:
                // Tertiary: Minimal glassmorphism
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial.opacity(0.5))
            }
        }
    }
    
    @MainActor
    private var overlay: some View {
        Group {
            switch variant {
            case .primary:
                // Primary: Bright gradient border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                            lineWidth: 1.5)
            case .secondary:
                // Secondary: Subtle border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LinearGradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                            lineWidth: 1)
            case .tertiary:
                // Tertiary: Very subtle border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2),
                            lineWidth: 1)
            }
        }
    }
    
    @MainActor
    private var shadowColor: Color {
        switch variant {
        case .primary:
            return Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.3) // Website shadow: rgba(99, 102, 241, 0.3)
        case .secondary:
            return .black.opacity(0.2)
        case .tertiary:
            return .black.opacity(0.15)
        }
    }
    
    @MainActor
    private var shadowRadius: CGFloat {
        switch variant {
        case .primary:
            return 20
        case .secondary:
            return 15
        case .tertiary:
            return 10
        }
    }
    
    @MainActor
    private var shadowY: CGFloat {
        switch variant {
        case .primary:
            return 8
        case .secondary:
            return 6
        case .tertiary:
            return 4
        }
    }
}

extension ButtonStyle where Self == ProfessionalButtonStyle {
    static func professional(_ variant: ProfessionalButtonStyle.Variant = .primary, isEnabled: Bool = true) -> ProfessionalButtonStyle {
        ProfessionalButtonStyle(variant: variant, isEnabled: isEnabled)
    }
}

extension View {
    func professionalButtonStyle(_ variant: ProfessionalButtonStyle.Variant = .primary, isEnabled: Bool = true) -> some View {
        buttonStyle(ProfessionalButtonStyle(variant: variant, isEnabled: isEnabled))
    }
}

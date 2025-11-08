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

extension View {
    /// Applies a background that supports both solid colors and gradients based on theme
    /// If the current theme defines a canvas gradient, it will be used; otherwise falls back to solid color
    func themedCanvasBackground() -> some View {
        background {
            ThemedCanvasBackgroundView()
        }
    }
}

/// A view that reactively updates when the theme changes
private struct ThemedCanvasBackgroundView: View {
    @State private var currentAppearance: AppAppearance = ServiceLocator.shared.settings?.appAppearance ?? .system
    
    var body: some View {
        Group {
            if let themeConfig = ThemeConfigurationRegistry.configuration(for: currentAppearance),
               let gradient = themeConfig.canvasGradient {
                // Use the gradient view directly
                gradient.asView()
            } else {
                // Fallback to solid color
                Color.compound.bgCanvasDefault
                    .ignoresSafeArea()
            }
        }
        .onReceive(ServiceLocator.shared.settings.$appAppearance) { newAppearance in
            // Update immediately when theme changes to prevent gradient lingering
            currentAppearance = newAppearance
        }
    }
}

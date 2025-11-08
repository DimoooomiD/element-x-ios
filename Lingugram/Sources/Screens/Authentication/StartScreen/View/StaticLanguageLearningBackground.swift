//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// Static version of the Lingugram background theme with the same color format but no animation
struct StaticLanguageLearningBackground: View {
    var body: some View {
        ZStack {
            // Base dark background matching website (#0f172a)
            Color(red: 0.06, green: 0.09, blue: 0.16)
                .ignoresSafeArea()
            
            // Radial gradients matching website style - static positions
            RadialGradient(colors: [
                Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1), // #6366f1
                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.1), // #8b5cf6
                Color.clear
            ],
            center: UnitPoint(x: 0.2, y: 0.5),
            startRadius: 100,
            endRadius: 600)
                .ignoresSafeArea()
            
            RadialGradient(colors: [
                Color(red: 0.80, green: 0.20, blue: 0.20).opacity(0.1), // #8b5cf6 variant
                Color(red: 0.02, green: 0.71, blue: 0.83).opacity(0.1), // #06b6d4
                Color.clear
            ],
            center: UnitPoint(x: 0.8, y: 0.2),
            startRadius: 100,
            endRadius: 600)
                .ignoresSafeArea()
            
            RadialGradient(colors: [
                Color(red: 0.02, green: 0.71, blue: 0.83).opacity(0.1), // #06b6d4
                Color(red: 0.23, green: 0.51, blue: 0.96).opacity(0.1), // #3b82f6
                Color.clear
            ],
            center: UnitPoint(x: 0.4, y: 0.8),
            startRadius: 100,
            endRadius: 600)
                .ignoresSafeArea()
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Previews

struct StaticLanguageLearningBackground_Previews: PreviewProvider {
    static var previews: some View {
        StaticLanguageLearningBackground()
            .previewDisplayName("Lingugram Static Background")
    }
}

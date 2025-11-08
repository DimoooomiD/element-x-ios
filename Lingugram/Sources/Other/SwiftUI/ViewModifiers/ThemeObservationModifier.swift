//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Compound
import Foundation
import SwiftUI

/// A reusable ViewModifier that observes theme changes and forces view refresh
/// This ensures views update correctly when the app appearance changes, including
/// custom themes like Lingugram (dark blue).
struct ThemeObservationModifier: ViewModifier {
    @State private var appearanceId: AppAppearance = ServiceLocator.shared.settings.appAppearance
    
    /// Whether to use async updates to avoid interfering with user interactions
    /// Set to true for screens that might have timing-sensitive operations (e.g., tab selection)
    let useAsyncUpdates: Bool
    
    init(useAsyncUpdates: Bool = false) {
        self.useAsyncUpdates = useAsyncUpdates
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(ServiceLocator.shared.settings.$appAppearance) { newAppearance in
                if useAsyncUpdates {
                    // Update asynchronously to avoid interfering with other operations
                    Task { @MainActor in
                        appearanceId = newAppearance
                    }
                } else {
                    // Update synchronously for immediate response
                    appearanceId = newAppearance
                }
            }
            .id(appearanceId) // Force refresh when appearance changes
    }
}

extension View {
    /// Observes theme changes and refreshes the view when appearance changes
    /// - Parameter useAsyncUpdates: Whether to use async updates (default: false)
    ///   Set to true for screens with timing-sensitive operations like tab selection
    func observeThemeChanges(useAsyncUpdates: Bool = false) -> some View {
        modifier(ThemeObservationModifier(useAsyncUpdates: useAsyncUpdates))
    }
}

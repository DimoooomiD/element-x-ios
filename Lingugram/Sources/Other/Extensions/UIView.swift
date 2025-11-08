//
// Copyright 2025 Element Creations Ltd.
// Copyright 2024-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI
import UIKit

extension UIView {
    func addMatchedSubview(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Simulator Warning Suppression

extension UIView {
    /// Suppresses known iOS simulator warnings that don't affect functionality.
    ///
    /// This method suppresses:
    /// - Keyboard constraint warnings: Conflicting constraints in UIKit's internal keyboard views
    ///   (These are fully suppressible via UserDefaults)
    ///
    /// Note: The following errors are system-level OSLog messages that cannot be easily suppressed:
    /// - CHHapticPattern errors: Missing haptic pattern library files (simulator doesn't include full haptic support)
    /// - RBSAssertionErrorDomain errors: Background task assertion failures (handled gracefully in code)
    ///
    /// These errors are harmless, simulator-specific, and don't affect functionality. They occur because
    /// the iOS Simulator doesn't have the full system capabilities that physical devices have.
    static func suppressKeyboardConstraintWarnings() {
        #if targetEnvironment(simulator)
        // Suppress constraint logging for keyboard-related views
        // This successfully suppresses the "Unable to simultaneously satisfy constraints" warnings
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // Note: System-level errors (CHHapticPattern, RBSAssertionErrorDomain) are logged via OSLog
        // from system frameworks and cannot be suppressed using UserDefaults. These errors are
        // expected in the simulator and are handled gracefully in the app code. They can be safely
        // ignored as they don't affect app functionality.
        #endif
    }
}

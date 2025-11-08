//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI
import SwiftUIIntrospect

/// Professional glassmorphism text field style for authentication screens
struct ProfessionalTextFieldStyle: @MainActor TextFieldStyle {
    @FocusState private var isFocused: Bool
    let accessibilityIdentifier: String?
    
    init(accessibilityIdentifier: String? = nil) {
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    @MainActor
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .focused($isFocused)
            .font(.system(size: 17, weight: .regular, design: .default))
            .foregroundColor(.white)
            .accentColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background {
                ZStack {
                    // Enhanced glassmorphism background with better colors
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            // Inner glow effect
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(colors: [
                                        Color.white.opacity(isFocused ? 0.15 : 0.05),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                                )
                        }
                        .overlay {
                            // Border with enhanced gradient
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(LinearGradient(colors: [
                                            Color.white.opacity(isFocused ? 0.8 : 0.4),
                                            Color.white.opacity(isFocused ? 0.5 : 0.2),
                                            Color.white.opacity(isFocused ? 0.3 : 0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing),
                                        lineWidth: isFocused ? 2.5 : 1.5)
                        }
                        .shadow(color: .black.opacity(isFocused ? 0.2 : 0.1), radius: isFocused ? 15 : 8, y: isFocused ? 8 : 4)
                        .shadow(color: .white.opacity(0.1), radius: 2, x: -1, y: -1)
                }
            }
            .introspect(.textField, on: .supportedVersions) { textField in
                textField.clearButtonMode = .whileEditing
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "",
                                                                     attributes: [
                                                                         NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)
                                                                     ])
                textField.accessibilityIdentifier = accessibilityIdentifier
            }
    }
}

extension TextFieldStyle where Self == ProfessionalTextFieldStyle {
    @MainActor
    static func professional(accessibilityIdentifier: String? = nil) -> ProfessionalTextFieldStyle {
        ProfessionalTextFieldStyle(accessibilityIdentifier: accessibilityIdentifier)
    }
}

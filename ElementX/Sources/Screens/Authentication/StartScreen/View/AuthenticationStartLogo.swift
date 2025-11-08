//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// The app's logo styled to fit on various launch pages.
struct AuthenticationStartLogo: View {
    @Environment(\.colorScheme) private var colorScheme
    
    /// Set to `true` when using on top of `Asset.Images.launchBackground`
    let hideBrandChrome: Bool
    
    /// The shape that the logo is composed on top of.
    private let outerShape = RoundedRectangle(cornerRadius: 28)
    private var isLight: Bool { colorScheme == .light }
    
    var body: some View {
        if hideBrandChrome {
            Image(asset: Asset.Images.appLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        } else {
            brandLogo
        }
    }
    
    private var brandLogo: some View {
        Image(asset: Asset.Images.appLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(isLight ? 0.1 : 0.3),
                            radius: 20,
                            y: 10)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 32)
                    .stroke(.white.opacity(isLight ? 0.3 : 0.1), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}

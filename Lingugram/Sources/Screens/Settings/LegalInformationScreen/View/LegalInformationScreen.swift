//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SFSafeSymbols
import SwiftUI

struct LegalInformationScreen: View {
    let context: LegalInformationScreenViewModel.Context
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Form {
            Section {
                ListRow(label: .default(title: L10n.commonCopyright,
                                        icon: ColoredIcon(symbol: .cCircle, color: .gray)),
                        kind: .button { openURL(context.viewState.copyrightURL) })
                ListRow(label: .default(title: L10n.commonAcceptableUsePolicy,
                                        icon: ColoredIcon(symbol: .docText, color: .blue)),
                        kind: .button { openURL(context.viewState.acceptableUseURL) })
                ListRow(label: .default(title: L10n.commonPrivacyPolicy,
                                        icon: ColoredIcon(symbol: .lock, color: .red)),
                        kind: .button { openURL(context.viewState.privacyURL) })
            }
        }
        .compoundList()
        .scrollContentBackground(.hidden)
        .themedCanvasBackground()
        .navigationTitle(L10n.commonAbout)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .observeThemeChanges() // Synchronous update for immediate response
    }
}

// MARK: - Previews

struct LegalInformationScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = LegalInformationScreenViewModel(appSettings: AppSettings())
    static var previews: some View {
        LegalInformationScreen(context: viewModel.context)
    }
}

// MARK: - Colored Icon View

private struct ColoredIcon: View {
    let symbol: SFSymbol
    let color: Color
    
    var body: some View {
        Image(systemSymbol: symbol)
            .renderingMode(.template)
            .foregroundColor(color)
    }
}

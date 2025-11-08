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
        .safeAreaInset(edge: .top) {
            headerSection
        }
        .navigationTitle(L10n.commonAbout)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .observeThemeChanges() // Synchronous update for immediate response
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 0) {
            Text(L10n.commonAbout)
                .font(.compound.headingMDBold)
                .foregroundStyle(.compound.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(transparentBackgroundIfLingugram().ignoresSafeArea(edges: .top))
        .frame(maxWidth: .infinity)
    }
    
    /// Returns transparent background for Aurora theme, solid color for others
    private func transparentBackgroundIfLingugram() -> Color {
        if let appSettings = ServiceLocator.shared.settings,
           appSettings.appAppearance == .aurora {
            return Color.clear
        } else {
            return Color.compound.bgCanvasDefault
        }
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

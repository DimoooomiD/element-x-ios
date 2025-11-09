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

struct AnalyticsSettingsScreen: View {
    @Bindable var context: AnalyticsSettingsScreenViewModel.Context
    
    var body: some View {
        Form {
            analyticsSection
        }
        .compoundList()
        .scrollContentBackground(.hidden)
        .themedCanvasBackground()
        .navigationTitle(L10n.commonAnalytics)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .observeThemeChanges() // Synchronous update for immediate response
    }
    
    var analyticsSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenAnalyticsSettingsShareData,
                                    icon: ColoredIcon(symbol: .chartBar, color: .cyan)),
                    kind: .toggle($context.enableAnalytics))
                .onChange(of: context.enableAnalytics) {
                    context.send(viewAction: .toggleAnalytics)
                }
        } footer: {
            Text(context.viewState.strings.sectionFooter)
                .compoundListSectionFooter()
        }
    }
}

// MARK: - Previews

struct AnalyticsSettingsScreen_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        let appSettings = AppSettings()
        let viewModel = AnalyticsSettingsScreenViewModel(appSettings: appSettings,
                                                         analytics: ServiceLocator.shared.analytics)
        AnalyticsSettingsScreen(context: viewModel.context)
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

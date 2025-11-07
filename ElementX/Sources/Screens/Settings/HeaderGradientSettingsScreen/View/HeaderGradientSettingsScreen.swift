//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SFSafeSymbols
import SwiftUI

struct HeaderGradientSettingsScreen: View {
    @Bindable var context: HeaderGradientSettingsScreenViewModel.Context
    
    var body: some View {
        Form {
            Section {
                ListRow(label: .default(title: "Header Gradient",
                                     description: "Show gradient effect on menu headers",
                                     icon: ColoredIcon(symbol: .paintbrush, color: .pink)),
                        kind: .toggle($context.headerGradientEnabled))
            } footer: {
                Text("Enable this option to show a beautiful gradient effect on the headers of all menu screens throughout the app.")
                    .compoundListSectionFooter()
            }
        }
        .compoundList()
        .navigationTitle("Header Gradient")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBloom(hasSearchBar: false)
        .observeThemeChanges() // Synchronous update for immediate response
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

// MARK: - Previews

struct HeaderGradientSettingsScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = HeaderGradientSettingsScreenViewModel(appSettings: ServiceLocator.shared.settings)
    static var previews: some View {
        NavigationStack {
            HeaderGradientSettingsScreen(context: viewModel.context)
        }
    }
}


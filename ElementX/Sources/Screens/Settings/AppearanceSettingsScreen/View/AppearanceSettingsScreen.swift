//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct AppearanceSettingsScreen: View {
    @Bindable var context: AppearanceSettingsScreenViewModel.Context
    
    var body: some View {
        Form {
            Section {
                ListRow(label: .plain(title: L10n.commonAppearance),
                        kind: .picker(selection: $context.appAppearance,
                                      items: AppAppearance.allCases.map { (title: $0.name, tag: $0) }))
            }
        }
        .compoundList()
        .navigationTitle(L10n.commonAppearance)
        .navigationBarTitleDisplayMode(.inline)
        .observeThemeChanges() // Synchronous update for immediate response
    }
}

private extension AppAppearance {
    var name: String {
        switch self {
        case .system:
            return L10n.commonSystem
        case .light:
            return L10n.commonLight
        case .dark:
            return L10n.commonDark
        case .darkBlue:
            return "Dark Blue"
        case .darkGreen:
            return "Dark Green"
        case .darkPurple:
            return "Dark Purple"
        }
    }
}

// MARK: - Previews

struct AppearanceSettingsScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = AppearanceSettingsScreenViewModel(appSettings: ServiceLocator.shared.settings)
    static var previews: some View {
        NavigationStack {
            AppearanceSettingsScreen(context: viewModel.context)
        }
    }
}


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
                ForEach(AppAppearance.allCases, id: \.self) { appearance in
                    ListRow(label: .default(title: appearance.name,
                                           icon: Text(appearance.emoji)),
                            kind: .selection(isSelected: context.appAppearance == appearance) {
                                context.appAppearance = appearance
                            })
                }
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
        case .darkGray:
            return "Charcoal"
        case .darkRed:
            return "Burgundy"
        case .darkOrange:
            return "Amber"
        case .lightGray:
            return "Light Gray"
        case .lightBlue:
            return "Light Blue"
        }
    }
    
    var emoji: String {
        switch self {
        case .system:
            return "⚙️"
        case .light:
            return "☀️"
        case .dark:
            return "🌙"
        case .darkBlue:
            return "🔵"
        case .darkGreen:
            return "🟢"
        case .darkPurple:
            return "🟣"
        case .darkGray:
            return "⚫️"
        case .darkRed:
            return "🍷"
        case .darkOrange:
            return "🟠"
        case .lightGray:
            return "⚪️"
        case .lightBlue:
            return "💙"
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


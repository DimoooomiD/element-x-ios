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

struct AppearanceSettingsScreen: View {
    @Bindable var context: AppearanceSettingsScreenViewModel.Context
    
    var body: some View {
        Form {
            Section {
                ForEach(AppAppearance.allCases, id: \.self) { appearance in
                    ListRow(label: .default(title: appearance.name,
                                            icon: ColoredIcon(symbol: appearance.systemIcon, color: appearance.iconColor)),
                            kind: .selection(isSelected: context.appAppearance == appearance) {
                                context.appAppearance = appearance
                            })
                }
            }
        }
        .compoundList()
        .scrollContentBackground(.hidden)
        .themedCanvasBackground()
        .navigationTitle(L10n.commonAppearance)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
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
        case .lingugram:
            return "Lingugram"
        }
    }
    
    var systemIcon: SFSymbol {
        switch self {
        case .system:
            return .gearshape
        case .light:
            return .sunMax
        case .dark:
            return .moon
        case .lingugram:
            return .circleFill
        }
    }
    
    var iconColor: Color {
        switch self {
        case .system:
            return .gray
        case .light:
            return .yellow
        case .dark:
            return .indigo
        case .lingugram:
            // Base color from static background with gradient influence
            return Color(red: 0.06, green: 0.09, blue: 0.16)
        }
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

struct AppearanceSettingsScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = AppearanceSettingsScreenViewModel(appSettings: ServiceLocator.shared.settings)
    static var previews: some View {
        NavigationStack {
            AppearanceSettingsScreen(context: viewModel.context)
        }
    }
}

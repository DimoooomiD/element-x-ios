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
        case .darkTeal:
            return "Ocean"
        case .darkIndigo:
            return "Midnight"
        case .darkSlate:
            return "Graphite"
        case .darkNavy:
            return "Navy"
        case .darkForest:
            return "Forest"
        case .darkSteel:
            return "Steel"
        case .lightTeal:
            return "Aqua"
        case .lightIndigo:
            return "Sky"
        case .lightSlate:
            return "Silver"
        case .lightRose:
            return "Blush"
        case .lightCream:
            return "Cream"
        case .lightAzure:
            return "Azure"
        case .lightPearl:
            return "Pearl"
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
        case .darkTeal, .darkIndigo, .darkSlate, .darkNavy, .darkForest, .darkSteel:
            return .circleFill
        case .lightTeal, .lightIndigo, .lightSlate, .lightRose, .lightCream, .lightAzure, .lightPearl:
            return .circle
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
        case .darkTeal:
            return Color(red: 0.0, green: 0.5, blue: 0.5)
        case .darkIndigo:
            return Color(red: 0.29, green: 0.0, blue: 0.51)
        case .darkSlate:
            return Color(red: 0.28, green: 0.32, blue: 0.36)
        case .darkNavy:
            return Color(red: 0.0, green: 0.0, blue: 0.5)
        case .darkForest:
            return Color(red: 0.0, green: 0.27, blue: 0.13)
        case .darkSteel:
            return Color(red: 0.27, green: 0.31, blue: 0.35)
        case .lightTeal:
            return Color(red: 0.0, green: 0.5, blue: 0.5).opacity(0.7)
        case .lightIndigo:
            return Color(red: 0.29, green: 0.0, blue: 0.51).opacity(0.7)
        case .lightSlate:
            return Color(red: 0.28, green: 0.32, blue: 0.36).opacity(0.7)
        case .lightRose:
            return Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.7)
        case .lightCream:
            return Color(red: 1.0, green: 0.99, blue: 0.82).opacity(0.7)
        case .lightAzure:
            return Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.7)
        case .lightPearl:
            return Color(red: 0.94, green: 0.92, blue: 0.84).opacity(0.7)
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

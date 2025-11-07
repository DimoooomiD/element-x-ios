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
            
            Section {
                ListRow(label: .default(title: "Header Gradient",
                                     description: "Show gradient effect on menu headers",
                                     icon: ColoredIcon(symbol: .paintbrush, color: .pink)),
                        kind: .toggle($context.headerGradientEnabled))
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
        case .lightGreen:
            return "Mint"
        case .lightPurple:
            return "Lavender"
        case .lightOrange:
            return "Peach"
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
        case .darkBlue:
            return .circleFill
        case .darkGreen:
            return .circleFill
        case .darkPurple:
            return .circleFill
        case .darkGray:
            return .circleFill
        case .darkRed:
            return .circleFill
        case .darkOrange:
            return .circleFill
        case .lightGray:
            return .circle
        case .lightBlue:
            return .circle
        case .lightGreen:
            return .circle
        case .lightPurple:
            return .circle
        case .lightOrange:
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
        case .darkBlue:
            return .blue
        case .darkGreen:
            return .green
        case .darkPurple:
            return .purple
        case .darkGray:
            return .gray
        case .darkRed:
            return .red
        case .darkOrange:
            return .orange
        case .lightGray:
            return .gray.opacity(0.6)
        case .lightBlue:
            return .blue.opacity(0.7)
        case .lightGreen:
            return .green.opacity(0.7)
        case .lightPurple:
            return .purple.opacity(0.7)
        case .lightOrange:
            return .orange.opacity(0.7)
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

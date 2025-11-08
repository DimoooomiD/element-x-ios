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

struct DeactivateAccountScreen: View {
    @Bindable var context: DeactivateAccountScreenViewModel.Context
    
    var body: some View {
        Form {
            infoSection
            eraseDataSection
            passwordSection
        }
        .compoundList()
        .scrollContentBackground(.hidden)
        .themedCanvasBackground()
        .safeAreaInset(edge: .top) {
            headerSection
        }
        .safeAreaInset(edge: .bottom) {
            Button(L10n.actionDeactivateAccount, role: .destructive) {
                context.send(viewAction: .deactivate)
            }
            .buttonStyle(.compound(.primary))
            .disabled(context.password.isEmpty)
            .padding(16)
            .background(Color.compound.bgSubtleSecondaryLevel0.ignoresSafeArea())
        }
        .navigationTitle(L10n.screenDeactivateAccountTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert(item: $context.alertInfo)
        .observeThemeChanges() // Synchronous update for immediate response
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 0) {
            Text(L10n.screenDeactivateAccountTitle)
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
    
    private var infoSection: some View {
        ListRow(kind: .custom {
            VStack(alignment: .leading, spacing: 16) {
                Text(context.viewState.info)
                
                VStack(alignment: .leading, spacing: 8) {
                    InfoItem(title: context.viewState.infoPoint1)
                    InfoItem(title: context.viewState.infoPoint2)
                    InfoItem(title: context.viewState.infoPoint3)
                    InfoItem(title: context.viewState.infoPoint4, isSuccess: true)
                }
            }
            .foregroundColor(.compound.textSecondary)
            .font(.compound.bodyMD)
            .listRowBackground(Color.clear)
        })
    }
    
    private var eraseDataSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenDeactivateAccountDeleteAllMessages,
                                    icon: ColoredIcon(symbol: .trash, color: .red)),
                    kind: .toggle($context.eraseData))
        } footer: {
            Text(L10n.screenDeactivateAccountDeleteAllMessagesNotice)
                .compoundListSectionFooter()
        }
    }
    
    private var passwordSection: some View {
        Section {
            ListRow(label: .default(title: L10n.commonPassword,
                                    icon: ColoredIcon(symbol: .lock, color: .orange)),
                    kind: .secureField(text: $context.password))
                .submitLabel(.done)
        } header: {
            Text(L10n.actionConfirmPassword)
                .compoundListSectionHeader()
        }
    }
}

private struct InfoItem: View {
    let title: AttributedString
    var isSuccess = false
    
    var body: some View {
        Label {
            Text(title).padding(.vertical, 1)
        } icon: {
            CompoundIcon(isSuccess ? \.check : \.close,
                         size: .small,
                         relativeTo: .compound.bodyMD)
                .foregroundStyle(isSuccess ? .compound.iconSuccessPrimary : .compound.iconCriticalPrimary)
        }
        .labelStyle(.custom(spacing: 8, alignment: .top))
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

struct DeactivateAccountScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = DeactivateAccountScreenViewModel(clientProxy: ClientProxyMock(.init()),
                                                            userIndicatorController: UserIndicatorControllerMock())
    static var previews: some View {
        NavigationStack {
            DeactivateAccountScreen(context: viewModel.context)
        }
    }
}

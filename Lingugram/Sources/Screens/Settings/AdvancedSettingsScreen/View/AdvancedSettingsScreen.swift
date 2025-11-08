//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SFSafeSymbols
import SwiftUI

struct AdvancedSettingsScreen: View {
    @Bindable var context: AdvancedSettingsScreenViewModel.Context
    
    var body: some View {
        Form {
            Section {
                ListRow(label: .default(title: L10n.actionViewSource,
                                        description: L10n.screenAdvancedSettingsViewSourceDescription,
                                        icon: ColoredIcon(symbol: .eye, color: .blue)),
                        kind: .toggle($context.viewSourceEnabled))
                
                ListRow(label: .default(title: L10n.screenAdvancedSettingsSharePresence,
                                        description: L10n.screenAdvancedSettingsSharePresenceDescription,
                                        icon: ColoredIcon(symbol: .person2, color: .green)),
                        kind: .toggle($context.sharePresence))
                
                ListRow(label: .default(title: L10n.screenAdvancedSettingsMediaCompressionTitle,
                                        description: L10n.screenAdvancedSettingsMediaCompressionDescription,
                                        icon: ColoredIcon(symbol: .photoStack, color: .purple)),
                        kind: .toggle($context.optimizeMediaUploads))
                    .onChange(of: context.optimizeMediaUploads) {
                        context.send(viewAction: .optimizeMediaUploadsChanged)
                    }
            }
            
            moderationAndSafetySection
            timelineMediaSection
        }
        .compoundList()
        .navigationTitle(L10n.commonAdvancedSettings)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .observeThemeChanges() // Synchronous update for immediate response
    }
    
    @ViewBuilder
    private var moderationAndSafetySection: some View {
        let binding = Binding(get: {
            context.viewState.hideInviteAvatars
        }, set: { newValue in
            context.send(viewAction: .updateHideInviteAvatars(newValue))
        })
        
        Section {
            ListRow(label: .default(title: L10n.screenAdvancedSettingsHideInviteAvatarsToggleTitle,
                                    icon: ColoredIcon(symbol: .personCropCircleBadgeXmark, color: .orange)),
                    details: context.viewState.isWaitingHideInviteAvatars ? .isWaiting(true) : nil,
                    kind: .toggle(binding))
                .disabled(context.viewState.isWaitingHideInviteAvatars)
        } header: {
            Text(L10n.screenAdvancedSettingsModerationAndSafetySectionTitle)
                .compoundListSectionHeader()
        }
    }
    
    @ViewBuilder
    private var timelineMediaSection: some View {
        let binding = Binding(get: {
            context.viewState.timelineMediaVisibility
        }, set: { newValue in
            context.send(viewAction: .updateTimelineMediaVisibility(newValue))
        })
        
        Section {
            ListRow(label: .default(title: L10n.screenAdvancedSettingsShowMediaTimelineTitle,
                                    icon: ColoredIcon(symbol: .photoOnRectangle, color: .cyan)),
                    details: .isWaiting(context.viewState.isWaitingTimelineMediaVisibility),
                    kind: .inlinePicker(selection: binding,
                                        items: TimelineMediaVisibility.items))
                .disabled(context.viewState.isWaitingTimelineMediaVisibility)
        } header: {
            Text(L10n.screenAdvancedSettingsShowMediaTimelineTitle)
                .compoundListSectionHeader()
        } footer: {
            Text(L10n.screenAdvancedSettingsShowMediaTimelineSubtitle)
                .compoundListSectionFooter()
        }
    }
}

// MARK: - Previews

struct AdvancedSettingsScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = AdvancedSettingsScreenViewModel(advancedSettings: ServiceLocator.shared.settings,
                                                           analytics: ServiceLocator.shared.analytics,
                                                           clientProxy: ClientProxyMock(.init()),
                                                           userIndicatorController: UserIndicatorControllerMock())
    static var previews: some View {
        NavigationStack {
            AdvancedSettingsScreen(context: viewModel.context)
        }
    }
}

private extension TimelineMediaVisibility {
    static var items: [(title: String, tag: TimelineMediaVisibility)] {
        [(title: L10n.screenAdvancedSettingsShowMediaTimelineAlwaysHide, tag: .never),
         (title: L10n.screenAdvancedSettingsShowMediaTimelinePrivateRooms, tag: .privateOnly),
         (title: L10n.screenAdvancedSettingsShowMediaTimelineAlwaysShow, tag: .always)]
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

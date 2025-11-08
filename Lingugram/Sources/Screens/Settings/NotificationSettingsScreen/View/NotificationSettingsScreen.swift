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

struct NotificationSettingsScreen: View {
    @Bindable var context: NotificationSettingsScreenViewModel.Context
    
    var body: some View {
        Form {
            if context.viewState.settings?.inconsistentSettings.isEmpty == false {
                configurationMismatchSection
            } else {
                if context.viewState.showSystemNotificationsAlert {
                    userPermissionSection
                }
                
                enableNotificationSection
                
                if context.enableNotifications {
                    roomsNotificationSection
                    
                    if context.viewState.settings?.roomMentionsEnabled != nil {
                        mentionsSection
                    }
                    
                    if context.viewState.showCallsSettings, context.viewState.settings?.callsEnabled != nil {
                        callsSection
                    }
                    
                    if context.viewState.settings?.invitationsEnabled != nil {
                        additionalSettingsSection
                    }
                }
            }
        }
        .compoundList()
        .navigationTitle(L10n.screenNotificationSettingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { toolbar }
        .alert(item: $context.alertInfo)
        .track(screen: .SettingsNotifications)
        .observeThemeChanges() // Synchronous update for immediate response
    }
    
    // MARK: - Private
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if context.viewState.isModallyPresented {
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.actionClose) {
                    context.send(viewAction: .close)
                }
            }
        }
    }
    
    private var userPermissionSection: some View {
        Section {
            ListRow(kind: .custom {
                HStack(alignment: .firstTextBaseline, spacing: 13) {
                    Image(systemSymbol: .exclamationmarkTriangle)
                        .foregroundColor(.orange)
                        .font(.system(size: 20))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.screenNotificationSettingsSystemNotificationsTurnedOff)
                            .font(.compound.bodyLG)
                            .foregroundColor(.compound.textPrimary)
                        Text(context.viewState.strings.changeYourSystemSettings)
                            .font(.compound.bodySM)
                            .foregroundColor(.compound.textSecondary)
                            .tint(.compound.textPrimary)
                    }
                }
                .padding(.horizontal, ListRowPadding.horizontal)
                .padding(.vertical, 8)
            })
        }
    }
    
    private var enableNotificationSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenNotificationSettingsEnableNotifications,
                                    icon: ColoredIcon(symbol: .bell, color: .orange)),
                    kind: .toggle($context.enableNotifications))
                .onChange(of: context.enableNotifications) {
                    context.send(viewAction: .changedEnableNotifications)
                }
        }
    }
    
    private var roomsNotificationSection: some View {
        Section {
            // Group chats
            ListRow(label: .default(title: L10n.screenNotificationSettingsGroupChats,
                                    icon: ColoredIcon(symbol: .person2, color: .blue)),
                    details: context.viewState.settings.map {
                        .title(context.viewState.strings.string(for: $0.groupChatsMode))
                    } ?? .isWaiting(true),
                    kind: .navigationLink {
                        context.send(viewAction: .groupChatsTapped)
                    })
                    .disabled(context.viewState.settings == nil)
                    .accessibilityIdentifier(A11yIdentifiers.roomDetailsScreen.notifications)
            
            // Direct chats
            ListRow(label: .default(title: L10n.screenNotificationSettingsDirectChats,
                                    icon: ColoredIcon(symbol: .message, color: .green)),
                    details: context.viewState.settings.map {
                        .title(context.viewState.strings.string(for: $0.directChatsMode))
                    } ?? .isWaiting(true),
                    kind: .navigationLink {
                        context.send(viewAction: .directChatsTapped)
                    })
                    .disabled(context.viewState.settings == nil)
                    .accessibilityIdentifier(A11yIdentifiers.roomDetailsScreen.notifications)
            
        } header: {
            Text(L10n.screenNotificationSettingsNotificationSectionTitle)
                .compoundListSectionHeader()
        }
    }
        
    private var mentionsSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenNotificationSettingsRoomMentionLabel,
                                    icon: ColoredIcon(symbol: .at, color: .purple)),
                    kind: .toggle($context.roomMentionsEnabled))
                .disabled(context.viewState.settings?.roomMentionsEnabled == nil)
                .allowsHitTesting(!context.viewState.applyingChange)
                .onChange(of: context.roomMentionsEnabled) {
                    context.send(viewAction: .roomMentionChanged)
                }
        } header: {
            Text(L10n.screenNotificationSettingsMentionsSectionTitle)
                .compoundListSectionHeader()
        }
    }
    
    private var callsSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenNotificationSettingsCallsLabel,
                                    icon: ColoredIcon(symbol: .phone, color: .green)),
                    kind: .toggle($context.callsEnabled))
                .disabled(context.viewState.settings?.callsEnabled == nil)
                .allowsHitTesting(!context.viewState.applyingChange)
                .onChange(of: context.callsEnabled) {
                    context.send(viewAction: .callsChanged)
                }
        } header: {
            Text(L10n.screenNotificationSettingsAdditionalSettingsSectionTitle)
                .compoundListSectionHeader()
        }
    }
    
    private var additionalSettingsSection: some View {
        Section {
            ListRow(label: .default(title: L10n.screenNotificationSettingsInviteForMeLabel,
                                    icon: ColoredIcon(symbol: .envelope, color: .blue)),
                    kind: .toggle($context.invitationsEnabled))
                .disabled(context.viewState.settings?.invitationsEnabled == nil)
                .allowsHitTesting(!context.viewState.applyingChange)
                .onChange(of: context.invitationsEnabled) {
                    context.send(viewAction: .invitationsChanged)
                }
        } header: {
            Text(L10n.screenNotificationSettingsAdditionalSettingsSectionTitle)
                .compoundListSectionHeader()
        }
    }
    
    private var configurationMismatchSection: some View {
        Section {
            ListRow(kind: .custom {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.screenNotificationSettingsConfigurationMismatch)
                            .font(.compound.bodyLGSemibold)
                        Text(L10n.screenNotificationSettingsConfigurationMismatchDescription)
                            .font(.compound.bodyMD)
                            .foregroundColor(.compound.textSecondary)
                    }
                    Button {
                        context.send(viewAction: .fixConfigurationMismatchTapped)
                    } label: {
                        Text(L10n.actionContinue)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.compound(.primary, size: .medium))
                    .disabled(context.viewState.fixingConfigurationMismatch)
                    .accessibilityIdentifier(A11yIdentifiers.notificationSettingsScreen.fixMismatchConfiguration)
                }
                .padding(.horizontal, ListRowPadding.horizontal)
                .padding(.vertical, 24)
            })
        }
    }
}

// MARK: - Previews

struct NotificationSettingsScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel: NotificationSettingsScreenViewModel = {
        let appSettings = AppSettings()
        let notificationCenter = UserNotificationCenterMock()
        notificationCenter.authorizationStatusReturnValue = .notDetermined
        let notificationSettingsProxy = NotificationSettingsProxyMock(with: .init())
        notificationSettingsProxy.getDefaultRoomNotificationModeIsEncryptedIsOneToOneClosure = { isEncrypted, isOneToOne in
            switch (isEncrypted, isOneToOne) {
            case (_, true):
                return .allMessages
            default:
                return .mentionsAndKeywordsOnly
            }
        }
        notificationSettingsProxy.isRoomMentionEnabledReturnValue = true
        notificationSettingsProxy.isCallEnabledReturnValue = false

        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "John Doe"))))

        var viewModel = NotificationSettingsScreenViewModel(appSettings: appSettings,
                                                            userNotificationCenter: notificationCenter,
                                                            notificationSettingsProxy: notificationSettingsProxy,
                                                            isModallyPresented: true)
        viewModel.fetchInitialContent()
        return viewModel
    }()
    
    static let viewModelConfigurationMismatch: NotificationSettingsScreenViewModel = {
        let appSettings = AppSettings()
        let notificationCenter = UserNotificationCenterMock()
        notificationCenter.authorizationStatusReturnValue = .notDetermined
        let notificationSettingsProxy = NotificationSettingsProxyMock(with: .init())
        notificationSettingsProxy.getDefaultRoomNotificationModeIsEncryptedIsOneToOneClosure = { isEncrypted, isOneToOne in
            switch (isEncrypted, isOneToOne) {
            case (true, true):
                return .allMessages
            case (false, true):
                return .mute
            default:
                return .mentionsAndKeywordsOnly
            }
        }
        notificationSettingsProxy.isRoomMentionEnabledReturnValue = true
        notificationSettingsProxy.isCallEnabledReturnValue = false
        
        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "John Doe"))))

        var viewModel = NotificationSettingsScreenViewModel(appSettings: appSettings,
                                                            userNotificationCenter: notificationCenter,
                                                            notificationSettingsProxy: notificationSettingsProxy,
                                                            isModallyPresented: true)
        viewModel.fetchInitialContent()
        return viewModel
    }()

    static var previews: some View {
        NotificationSettingsScreen(context: viewModel.context)
            .snapshotPreferences(expect: viewModel.context.observe(\.viewState.settings).map { $0 != nil }.eraseToStream())
        
        NotificationSettingsScreen(context: viewModelConfigurationMismatch.context)
            .snapshotPreferences(expect: viewModelConfigurationMismatch.context.observe(\.viewState.settings).map { $0 != nil }.eraseToStream())
            .previewDisplayName("Configuration mismatch")
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

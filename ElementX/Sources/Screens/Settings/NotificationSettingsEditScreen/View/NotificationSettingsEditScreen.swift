//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct NotificationSettingsEditScreen: View {
    @Bindable var context: NotificationSettingsEditScreenViewModel.Context
    
    @State private var appearanceId: AppAppearance = ServiceLocator.shared.settings.appAppearance
    
    var body: some View {
        Form {
            notificationModeSection
            
            if context.viewState.displayRoomsWithCustomSettings {
                roomsWithCustomSettingsSection
            }
        }
        .compoundList()
        .navigationTitle(context.viewState.strings.navigationTitle)
        .alert(item: $context.alertInfo)
        .track(screen: .SettingsDefaultNotifications)
        .onReceive(ServiceLocator.shared.settings.$appAppearance) { newAppearance in
            appearanceId = newAppearance
        }
        .id(appearanceId) // Force refresh when appearance changes
    }
    
    // MARK: - Private

    private var notificationModeSection: some View {
        Section {
            ForEach(context.viewState.availableDefaultModes, id: \.self) { mode in
                ListRow(label: .default(title: context.viewState.strings.string(for: mode),
                                        description: context.viewState.description(for: mode),
                                        icon: emojiForMode(mode)),
                        details: (context.viewState.pendingMode == mode) ? .isWaiting(true) : nil,
                        kind: .selection(isSelected: context.viewState.isSelected(mode: mode)) {
                            context.send(viewAction: .setMode(mode))
                        })
                        .disabled(context.viewState.pendingMode != nil)
            }
        } header: {
            Text(context.viewState.strings.modeSectionTitle)
                .compoundListSectionHeader()
        }
    }
    
    private func emojiForMode(_ mode: NotificationSettingsEditScreenDefaultMode) -> Text {
        switch mode {
        case .allMessages:
            return Text("📬")
        case .mentionsAndKeywordsOnly:
            return Text("💬")
        }
    }
    
    private var roomsWithCustomSettingsSection: some View {
        Section {
            ForEach(context.viewState.roomsWithUserDefinedMode, id: \.id) { room in
                NotificationSettingsEditScreenRoomCell(room: room, context: context)
            }
        } header: {
            Text(L10n.screenNotificationSettingsEditCustomSettingsSectionTitle)
                .compoundListSectionHeader()
        }
    }
}

// MARK: - Previews

struct NotificationSettingsEditScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModelGroupChats: NotificationSettingsEditScreenViewModel = {
        let notificationSettingsProxy = NotificationSettingsProxyMock(with: .init())
        notificationSettingsProxy.getDefaultRoomNotificationModeIsEncryptedIsOneToOneReturnValue = .allMessages
        
        notificationSettingsProxy.getRoomsWithUserDefinedRulesReturnValue = [RoomSummary].mockRooms.map(\.id)
        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "@alice:example.com",
                                                                                   roomSummaryProvider: RoomSummaryProviderMock(.init(state: .loaded(.mockRooms))),
                                                                                   notificationSettings: notificationSettingsProxy))))
        var viewModel = NotificationSettingsEditScreenViewModel(chatType: .groupChat,
                                                                userSession: userSession)
        viewModel.fetchInitialContent()
        return viewModel
    }()
    
    static let viewModelDirectChats: NotificationSettingsEditScreenViewModel = {
        let notificationSettingsProxy = NotificationSettingsProxyMock(with: .init())
        notificationSettingsProxy.getDefaultRoomNotificationModeIsEncryptedIsOneToOneReturnValue = .mentionsAndKeywordsOnly
        notificationSettingsProxy.getRoomsWithUserDefinedRulesReturnValue = []
        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "@alice:example.com",
                                                                                   roomSummaryProvider: RoomSummaryProviderMock(.init(state: .loaded(.mockRooms))),
                                                                                   notificationSettings: notificationSettingsProxy))))
        var viewModel = NotificationSettingsEditScreenViewModel(chatType: .oneToOneChat,
                                                                userSession: userSession)
        viewModel.fetchInitialContent()
        return viewModel
    }()
    
    static let viewModelDirectApplyingChange: NotificationSettingsEditScreenViewModel = {
        let notificationSettingsProxy = NotificationSettingsProxyMock(with: .init())
        notificationSettingsProxy.getDefaultRoomNotificationModeIsEncryptedIsOneToOneReturnValue = .mentionsAndKeywordsOnly
        notificationSettingsProxy.getRoomsWithUserDefinedRulesReturnValue = []
        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "John Doe",
                                                                                   notificationSettings: notificationSettingsProxy))))
        
        var viewModel = NotificationSettingsEditScreenViewModel(chatType: .oneToOneChat,
                                                                userSession: userSession)
        viewModel.state.pendingMode = .mentionsAndKeywordsOnly
        viewModel.fetchInitialContent()
        return viewModel
    }()
    
    static let viewModelGroupChatsWithouDisclaimer: NotificationSettingsEditScreenViewModel = {
        let notificationSettingsProxy = NotificationSettingsProxyMock(with: .init(canPushEncryptedEvents: true))
        notificationSettingsProxy.getDefaultRoomNotificationModeIsEncryptedIsOneToOneReturnValue = .allMessages
        
        notificationSettingsProxy.getRoomsWithUserDefinedRulesReturnValue = [RoomSummary].mockRooms.map(\.id)
        let userSession = UserSessionMock(.init(clientProxy: ClientProxyMock(.init(userID: "@alice:example.com",
                                                                                   roomSummaryProvider: RoomSummaryProviderMock(.init(state: .loaded(.mockRooms))),
                                                                                   notificationSettings: notificationSettingsProxy))))
        var viewModel = NotificationSettingsEditScreenViewModel(chatType: .groupChat,
                                                                userSession: userSession)
        viewModel.fetchInitialContent()
        return viewModel
    }()
    
    static var previews: some View {
        NotificationSettingsEditScreen(context: viewModelGroupChats.context)
            .previewDisplayName("Group Chats")
        NotificationSettingsEditScreen(context: viewModelDirectChats.context)
            .previewDisplayName("Direct Chats")
        NotificationSettingsEditScreen(context: viewModelDirectApplyingChange.context)
            .previewDisplayName("Applying change")
        NotificationSettingsEditScreen(context: viewModelGroupChatsWithouDisclaimer.context)
            .previewDisplayName("Group Chats Without Disclaimer")
    }
}

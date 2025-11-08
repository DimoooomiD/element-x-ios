//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct SpaceListScreen: View {
    @Bindable var context: SpaceListScreenViewModel.Context
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                header
                spaces
            }
        }
        .safeAreaInset(edge: .top) {
            headerSection
        }
        .themedCanvasBackground()
        .onAppear { context.send(viewAction: .screenAppeared) }
        .observeThemeChanges(useAsyncUpdates: true) // Async to avoid interfering with tab selection
        .sheet(isPresented: $context.isPresentingFeatureAnnouncement) {
            SpacesAnnouncementSheetView(context: context)
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack(spacing: 0) {
            Text(L10n.screenSpaceListTitle)
                .font(.compound.headingMDBold)
                .foregroundStyle(.compound.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(transparentBackgroundIfLingugram())
    }
    
    /// Returns transparent background for Lingugram theme, solid color for others
    private func transparentBackgroundIfLingugram() -> Color {
        if let appSettings = ServiceLocator.shared.settings,
           appSettings.appAppearance == .lingugram {
            return Color.clear
        } else {
            return Color.compound.bgCanvasDefault
        }
    }
    
    var header: some View {
        VStack(spacing: 16) {
            BigIcon(icon: \.spaceSolid)
            
            VStack(spacing: 8) {
                Text(L10n.screenSpaceListTitle)
                    .font(.compound.headingLGBold)
                    .foregroundStyle(.compound.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(L10n.commonSpaces(context.viewState.joinedSpaces.count))
                    .font(.compound.bodyLG)
                    .foregroundStyle(.compound.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Text(L10n.screenSpaceListDescription)
                .font(.compound.bodyMD)
                .foregroundStyle(.compound.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.compound.borderDisabled)
                .frame(height: 1 / UIScreen.main.scale)
        }
    }
    
    var spaces: some View {
        ForEach(context.viewState.joinedSpaces, id: \.id) { spaceRoomProxy in
            SpaceRoomCell(spaceRoomProxy: spaceRoomProxy,
                          isSelected: spaceRoomProxy.id == context.viewState.selectedSpaceID,
                          mediaProvider: context.mediaProvider) { action in
                context.send(viewAction: .spaceAction(action))
            }
        }
    }
}

// MARK: - Previews

struct SpaceListScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    
    static var previews: some View {
        NavigationStack {
            SpaceListScreen(context: viewModel.context)
        }
    }
    
    static func makeViewModel() -> SpaceListScreenViewModel {
        let clientProxy = ClientProxyMock(.init())
        clientProxy.spaceService = SpaceServiceProxyMock(.init(joinedSpaces: .mockJoinedSpaces))
        
        let viewModel = SpaceListScreenViewModel(userSession: UserSessionMock(.init(clientProxy: clientProxy)),
                                                 selectedSpacePublisher: .init(nil),
                                                 appSettings: ServiceLocator.shared.settings,
                                                 userIndicatorController: UserIndicatorControllerMock())
        
        return viewModel
    }
}

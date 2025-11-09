//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI
import SwiftUIIntrospect
import WysiwygComposer

struct RoomScreen: View {
    @ObservedObject private var context: RoomScreenViewModelType.Context
    @ObservedObject private var timelineContext: TimelineViewModelType.Context
    let composerToolbar: ComposerToolbar
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

    init(context: RoomScreenViewModelType.Context,
         timelineContext: TimelineViewModelType.Context,
         composerToolbar: ComposerToolbar) {
        self.context = context
        self.timelineContext = timelineContext
        self.composerToolbar = composerToolbar
    }

    @ViewBuilder
    var body: some View {
        let baseView = makeBaseTimelineView()
        let withNavigation = applyNavigationModifiers(to: baseView)
        applyTrackingModifiers(to: withNavigation)
    }
    
    private func makeBaseTimelineView() -> some View {
        TimelineView(timelineContext: timelineContext)
            .overlay(alignment: .bottomTrailing) {
                TimelineScrollToBottomButton(isVisible: isAtBottomAndLive) {
                    timelineContext.send(viewAction: .scrollToBottom)
                }
                .accessibilityIdentifier(A11yIdentifiers.roomScreen.scrollToBottom)
            }
            .themedCanvasBackground()
            .overlay(alignment: .top) {
                if !isVoiceOverEnabled {
                    pinnedItemsBanner
                }
            }
            // This can overlay on top of the pinnedItemsBanner
            .overlay(alignment: .top) {
                knockRequestsBanner
            }
            .safeAreaInset(edge: .top) {
                // When voice over is on the table view is not reversed
                // and the scroll gestures are not intercepted
                // so we render the pinned banner on top.
                if isVoiceOverEnabled {
                    pinnedItemsBanner
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    RoomScreenFooterView(details: context.viewState.footerDetails,
                                         mediaProvider: context.mediaProvider) { action in
                        context.send(viewAction: .footerViewAction(action))
                    }
                    
                    composer
                        .padding(.top, 8)
                        .themedCanvasBackground()
                        .environmentObject(timelineContext)
                        .environment(\.timelineContext, timelineContext)
                        // Make sure the reply header honours the hideTimelineMedia setting too.
                        .environment(\.shouldAutomaticallyLoadImages, !timelineContext.viewState.hideTimelineMedia)
                }
            }
            .overlay { loadingIndicator }
            .timelineMediaPreview(viewModel: $context.mediaPreviewViewModel)
    }
    
    private func applyNavigationModifiers<Content: View>(to content: Content) -> some View {
        content
            .toolbarRole(RoomHeaderView.toolbarRole)
            .navigationTitle(L10n.screenRoomTitle) // Hidden but used for back button text.
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .toolbarBackground(.visible, for: .navigationBar) // Fix the toolbar's background.
            .toolbarBloom(hasSearchBar: false, headerOnly: true)
            .onAppear {
                // Update navigation bar immediately when screen appears
                // This must happen synchronously to prevent showing previous screen's header
                updateNavigationBarImmediately()
            }
    }
    
    private func applyTrackingModifiers<Content: View>(to content: Content) -> some View {
        content
            .track(screen: .Room)
            .sentryTrace("\(Self.self)")
            .observeThemeChanges(useAsyncUpdates: true) // Async to avoid interfering with scrolling operations
    }
    
    private func updateNavigationBarImmediately() {
        // Update navigation bar immediately on main thread to show correct toolbar content
        // This is called in .onAppear to ensure it happens synchronously when screen appears
        // Using DispatchQueue.main.async ensures it runs after the current run loop cycle
        // but still early enough to prevent showing the previous screen's header
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
               let rootViewController = window.rootViewController {
                // Find the active navigation controller
                func findActiveNavController(from vc: UIViewController) -> UINavigationController? {
                    if let nav = vc as? UINavigationController {
                        return nav
                    }
                    if let nav = vc.navigationController {
                        return nav
                    }
                    if let presented = vc.presentedViewController {
                        return findActiveNavController(from: presented)
                    }
                    for child in vc.children {
                        if let nav = findActiveNavController(from: child) {
                            return nav
                        }
                    }
                    return nil
                }
                
                if let navController = findActiveNavController(from: rootViewController) {
                    // Only set needs layout - don't force layoutIfNeeded to avoid constraint warnings
                    // The system will handle the layout update naturally
                    navController.navigationBar.setNeedsLayout()
                }
            }
        }
    }
    
    @ViewBuilder
    private var pinnedItemsBanner: some View {
        // Color.clear and clipped() are required for iOS 26 transparent nav bar
        VStack(spacing: 0) {
            if context.viewState.shouldShowPinnedEventsBanner {
                PinnedItemsBannerView(state: context.viewState.pinnedEventsBannerState,
                                      onMainButtonTap: { context.send(viewAction: .tappedPinnedEventsBanner) },
                                      onViewAllButtonTap: { context.send(viewAction: .viewAllPins) })
                    .transition(.move(edge: .top))
            } else {
                Color.clear
                    .allowsHitTesting(false)
            }
        }
        .animation(.elementDefault, value: context.viewState.shouldShowPinnedEventsBanner)
        .clipped()
    }
    
    @ViewBuilder
    private var knockRequestsBanner: some View {
        // Color.clear and clipped() are required for iOS 26 transparent nav bar
        VStack(spacing: 0) {
            if context.viewState.shouldSeeKnockRequests {
                KnockRequestsBannerView(requests: context.viewState.displayedKnockRequests,
                                        onDismiss: dismissKnockRequestsBanner,
                                        onAccept: context.viewState.canAcceptKnocks ? acceptKnockRequest : nil,
                                        onViewAll: onViewAllKnockRequests,
                                        mediaProvider: context.mediaProvider)
                    .padding(.top, 16)
                    .transition(.move(edge: .top))
            } else {
                Color.clear
                    .allowsHitTesting(false)
            }
        }
        .animation(.elementDefault, value: context.viewState.shouldSeeKnockRequests)
        .clipped()
    }
    
    private func dismissKnockRequestsBanner() {
        context.send(viewAction: .dismissKnockRequests)
    }
    
    private func acceptKnockRequest(eventID: String) {
        context.send(viewAction: .acceptKnock(eventID: eventID))
    }
    
    private func onViewAllKnockRequests() {
        context.send(viewAction: .viewKnockRequests)
    }
    
    private var isAtBottomAndLive: Bool {
        timelineContext.isScrolledToBottom && timelineContext.viewState.timelineState.isLive
    }
    
    @ViewBuilder
    private var composer: some View {
        if context.viewState.hasSuccessor {
            tombstonedDialogue
        } else if context.viewState.canSendMessage, !ProcessInfo.isRunningAccessibilityTests {
            // We are not sure why but when wrapped in the room screen the composer toolbar breaks the accessibility tests
            composerToolbar
        } else {
            EmptyView()
        }
    }
    
    private var tombstonedDialogue: some View {
        VStack(spacing: 16) {
            Text(L10n.screenRoomTimelineTombstonedRoomMessage)
                .font(.compound.bodyMD)
                .foregroundStyle(.compound.textPrimary)
            
            Button {
                context.send(viewAction: .displaySuccessorRoom)
            } label: {
                Text(L10n.screenRoomTimelineTombstonedRoomAction)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.compound(.primary, size: .medium))
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .highlight(gradient: .compound.info,
                   borderColor: .compound.borderInfoSubtle,
                   backgroundColor: .compound.bgCanvasDefault)
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        if timelineContext.viewState.showLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.compound.textPrimary)
                .padding(16)
                .background(.ultraThickMaterial)
                .cornerRadius(8)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        // .principal + .primaryAction works better than .navigation leading + trailing
        // as the latter disables interaction in the action button for rooms with long names
        ToolbarItem(placement: .principal) {
            RoomHeaderView(roomName: context.viewState.roomTitle,
                           roomAvatar: context.viewState.roomAvatar,
                           dmRecipientVerificationState: context.viewState.dmRecipientVerificationState,
                           mediaProvider: context.mediaProvider)
                // Using a button stops it from getting truncated in the navigation bar
                .contentShape(.rect)
                .onTapGesture {
                    context.send(viewAction: .displayRoomDetails)
                }
                // Force refresh when room title changes to prevent showing previous header
                .id("room-header-\(context.viewState.roomTitle)")
        }
    }
}

// MARK: - Previews

struct RoomScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModels = makeViewModels()
    static let readOnlyViewModels = makeViewModels(canSendMessage: false)
    static let tombstonedViewModels = makeViewModels(hasSuccessor: true)

    static var previews: some View {
        NavigationStack {
            RoomScreen(context: viewModels.room.context,
                       timelineContext: viewModels.timeline.context,
                       composerToolbar: ComposerToolbar.mock())
        }
        .previewDisplayName("Normal")
        
        NavigationStack {
            RoomScreen(context: readOnlyViewModels.room.context,
                       timelineContext: readOnlyViewModels.timeline.context,
                       composerToolbar: ComposerToolbar.mock())
        }
        .previewDisplayName("Read-only")
        .snapshotPreferences(expect: readOnlyViewModels.room.context.$viewState.map { !$0.canSendMessage })
        
        NavigationStack {
            RoomScreen(context: tombstonedViewModels.room.context,
                       timelineContext: tombstonedViewModels.timeline.context,
                       composerToolbar: ComposerToolbar.mock())
        }
        .previewDisplayName("Tombstoned")
        .snapshotPreferences(expect: tombstonedViewModels.room.context.$viewState.map(\.hasSuccessor))
    }
    
    static func makeViewModels(canSendMessage: Bool = true, hasSuccessor: Bool = false) -> ViewModels {
        let roomProxyMock = JoinedRoomProxyMock(.init(id: "stable_id",
                                                      name: "Preview room",
                                                      hasOngoingCall: true,
                                                      successor: hasSuccessor ? .init(roomId: UUID().uuidString, reason: nil) : nil,
                                                      powerLevelsConfiguration: .init(canUserSendMessage: canSendMessage)))
        let roomViewModel = RoomScreenViewModel.mock(roomProxyMock: roomProxyMock)
        let timelineViewModel = TimelineViewModel(roomProxy: roomProxyMock,
                                                  timelineController: MockTimelineController(),
                                                  userSession: UserSessionMock(.init()),
                                                  mediaPlayerProvider: MediaPlayerProviderMock(),
                                                  userIndicatorController: ServiceLocator.shared.userIndicatorController,
                                                  appMediator: AppMediatorMock.default,
                                                  appSettings: ServiceLocator.shared.settings,
                                                  analyticsService: ServiceLocator.shared.analytics,
                                                  emojiProvider: EmojiProvider(appSettings: ServiceLocator.shared.settings),
                                                  linkMetadataProvider: LinkMetadataProvider(),
                                                  timelineControllerFactory: TimelineControllerFactoryMock(.init()))
        
        return .init(room: roomViewModel, timeline: timelineViewModel)
    }
    
    struct ViewModels {
        let room: RoomScreenViewModelProtocol
        let timeline: TimelineViewModelProtocol
    }
}

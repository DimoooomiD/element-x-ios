//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

/// Class responsible for displaying an arbitrary number of coordinators within the tab bar.
@Observable class NavigationTabCoordinator<Tag: Hashable>: CoordinatorProtocol, CustomStringConvertible {
    struct Tab {
        let coordinator: CoordinatorProtocol
        let details: TabDetails
        var dismissalCallback: (() -> Void)?
    }
    
    @MainActor
    @Observable class TabDetails {
        /// A unique tab that identifies the tab for selection.
        let tag: Tag
        let title: String
        let icon: KeyPath<CompoundIcons, Image>
        let selectedIcon: KeyPath<CompoundIcons, Image>
        var badgeCount = 0
        var barVisibilityOverride: Visibility?
        
        /// Provide the tab's split coordinator in here to have the tab bar automatically hidden
        /// when pushing a child into the split view's details on iPhone/compact iPad.
        weak var navigationSplitCoordinator: NavigationSplitCoordinator?
        
        /// Provide the tab's stack coordinator in here to have the tab bar automatically hidden
        /// when pushing screens onto the navigation stack.
        weak var navigationStackCoordinator: NavigationStackCoordinator?
        
        init(tag: Tag, title: String, icon: KeyPath<CompoundIcons, Image>, selectedIcon: KeyPath<CompoundIcons, Image>) {
            self.tag = tag
            self.title = title
            self.icon = icon
            self.selectedIcon = selectedIcon
        }
        
        func barVisibility(in horizontalSizeClass: UserInterfaceSizeClass?) -> Visibility {
            if #unavailable(iOS 18.0) {
                // There are glitches with the tab bar on iPadOS 17, so disable the tab bar until we have fixed it.
                .hidden
            } else if let barVisibilityOverride {
                barVisibilityOverride
            } else if horizontalSizeClass == .compact, navigationSplitCoordinator?.detailCoordinator != nil {
                // Hide tab bar when inside a room (detail view) on compact devices
                .hidden
            } else if navigationStackCoordinator?.stackCoordinators.isEmpty == false {
                // Hide tab bar when inside settings sub-screens (stack has pushed items)
                .hidden
            } else {
                .automatic
            }
        }
    }
    
    // MARK: Tabs
    
    fileprivate struct TabModule: Identifiable {
        let module: NavigationModule
        let details: TabDetails
        
        var id: ObjectIdentifier { module.id }
        @MainActor var coordinator: CoordinatorProtocol? { module.coordinator }
    }
    
    fileprivate var tabModules = [TabModule]() {
        didSet {
            let diffs = tabModules.map(\.module).difference(from: oldValue.map(\.module))
            diffs.forEach { change in
                switch change {
                case .insert(_, let module, _):
                    logPresentationChange("Set tab", module)
                    module.coordinator?.start()
                case .remove(_, let module, _):
                    logPresentationChange("Remove tab", module)
                    module.tearDown()
                }
            }
        }
    }
    
    /// The current set of coordinators displayed by the tabs.
    var tabCoordinators: [any CoordinatorProtocol] {
        tabModules.compactMap(\.module.coordinator)
    }
    
    /// Updates the displayed tabs with the provided array.
    func setTabs(_ tabs: [Tab], animated: Bool = true) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            tabModules = tabs.map { TabModule(module: .init($0.coordinator, dismissalCallback: $0.dismissalCallback), details: $0.details) }
        }
        
        selectedTab = tabModules.first?.details.tag
    }
    
    /// The currently selected tab's tag.
    var selectedTab: Tag?
    
    // MARK: Sheets
    
    fileprivate var sheetModule: NavigationModule? {
        didSet {
            if let oldValue {
                logPresentationChange("Remove sheet", oldValue)
                oldValue.tearDown()
            }
            
            if let sheetModule {
                logPresentationChange("Set sheet", sheetModule)
                sheetModule.coordinator?.start()
            }
        }
    }
    
    var presentationDetents: Set<PresentationDetent> = []
    
    /// The currently presented sheet coordinator.
    var sheetCoordinator: (any CoordinatorProtocol)? {
        sheetModule?.coordinator
    }
    
    /// Present a sheet on top of the stack. If this NavigationStackCoordinator is embedded within a NavigationSplitCoordinator
    /// then the presentation will be proxied to the split
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - animated: whether to animate the transition or not. Default is true

    ///   - dismissalCallback: called when the sheet has been dismissed, programatically or otherwise
    func setSheetCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            sheetModule = nil
            return
        }
        
        if sheetModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }

        var transaction = Transaction()
        transaction.disablesAnimations = !animated

        withTransaction(transaction) {
            sheetModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    // MARK: Full Screen Cover
    
    fileprivate var fullScreenCoverModule: NavigationModule? {
        didSet {
            if let oldValue {
                logPresentationChange("Remove fullscreen cover", oldValue)
                oldValue.tearDown()
            }
            
            if let fullScreenCoverModule {
                logPresentationChange("Set fullscreen cover", fullScreenCoverModule)
                fullScreenCoverModule.coordinator?.start()
            }
        }
    }
    
    /// The currently presented fullscreen cover coordinator
    /// Fullscreen covers will be presented through the NavigationSplitCoordinator if provided
    var fullScreenCoverCoordinator: (any CoordinatorProtocol)? {
        fullScreenCoverModule?.coordinator
    }
    
    /// Present a fullscreen cover on top of the stack. If this NavigationStackCoordinator is embedded within a NavigationSplitCoordinator
    /// then the presentation will be proxied to the split
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - animated: whether to animate the transition or not. Default is true
    ///   - dismissalCallback: called when the fullscreen cover has been dismissed, programatically or otherwise
    func setFullScreenCoverCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            fullScreenCoverModule = nil
            return
        }
        
        if fullScreenCoverModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }

        var transaction = Transaction()
        transaction.disablesAnimations = !animated

        withTransaction(transaction) {
            fullScreenCoverModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    // MARK: - Overlay
    
    fileprivate var overlayModule: NavigationModule? {
        didSet {
            if let oldValue {
                logPresentationChange("Remove overlay", oldValue)
                oldValue.tearDown()
            }
            
            if let overlayModule {
                logPresentationChange("Set overlay", overlayModule)
                overlayModule.coordinator?.start()
            }
        }
    }
    
    /// The currently displayed overlay coordinator
    var overlayCoordinator: (any CoordinatorProtocol)? {
        overlayModule?.coordinator
    }
    
    enum OverlayPresentationMode { case fullScreen, minimized }
    fileprivate var overlayPresentationMode: OverlayPresentationMode = .minimized
    
    /// Present an overlay on top of the tab view
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - presentationMode: how the coordinator should be presented
    ///   - animated: whether the transition should be animated
    ///   - dismissalCallback: called when the overlay has been dismissed, programatically or otherwise
    func setOverlayCoordinator(_ coordinator: (any CoordinatorProtocol)?,
                               presentationMode: OverlayPresentationMode = .fullScreen,
                               animated: Bool = true,
                               dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            overlayModule = nil
            return
        }
        
        if overlayModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }

        var transaction = Transaction()
        transaction.disablesAnimations = !animated

        withTransaction(transaction) {
            overlayPresentationMode = presentationMode
            overlayModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    /// Updates the presentation of the overlay coordinator.
    /// - Parameters:
    ///   - mode: The type of presentation to use.
    ///   - animated: whether the transition should be animated
    func setOverlayPresentationMode(_ mode: OverlayPresentationMode, animated: Bool = true) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            overlayPresentationMode = mode
        }
    }
    
    // MARK: - CoordinatorProtocol
    
    /// No idea if this is particuarly needed for the TabView but we do this for the NavigationStackCoordinator and NavigationSplitCoordinator so it
    /// doesn't seem to harm to also do it here.
    func stop() {
        tabModules.forEach { $0.module.tearDown() }
    }
    
    func toPresentable() -> AnyView {
        AnyView(NavigationTabCoordinatorView(navigationTabCoordinator: self))
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        guard !tabModules.isEmpty else { return "NavigationTabCoordinator(Empty)" }
        return "NavigationTabCoordinator(\(tabCoordinators)"
    }
    
    // MARK: - Private
    
    private func logPresentationChange(_ change: String, _ module: NavigationModule) {
        if let coordinator = module.coordinator {
            MXLog.info("\(self) \(change): \(coordinator)")
        }
    }
}

private struct NavigationTabCoordinatorView<Tag: Hashable>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Bindable var navigationTabCoordinator: NavigationTabCoordinator<Tag>
    
    @State private var tabBarController: UITabBarController?
    
    var body: some View {
        TabView(selection: $navigationTabCoordinator.selectedTab) {
            ForEach(navigationTabCoordinator.tabModules) { module in
                module.coordinator?.toPresentable()
                    .id(module.id)
                    .tabItem {
                        Label {
                            Text(module.details.title)
                        } icon: {
                            CompoundIcon(module.details.tag == navigationTabCoordinator.selectedTab ? module.details.selectedIcon : module.details.icon)
                        }
                    }
                    .tag(module.details.tag)
                    .badge(module.details.badgeCount)
                    .toolbar(module.details.barVisibility(in: horizontalSizeClass), for: .tabBar)
            }
        }
        .backportTabBarMinimizeBehaviorOnScrollDown()
        .introspect(.tabView, on: .supportedVersions) { tabBarController in
            // Store reference immediately for synchronous access
            self.tabBarController = tabBarController
            
            // Configure appearance immediately so tab bar has proper frame on first render
            // This is safe because we're only configuring UIKit, not modifying SwiftUI state
            configureAppearance(tabBarController)
        }
        .onAppear {
            // Ensure appearance is configured when view appears
            // This is critical for initial load to show the selection indicator
            if let tabBarController = tabBarController {
                configureAppearance(tabBarController)
            }
        }
        .task {
            // Fallback: ensure appearance is configured after a short delay
            // This helps prevent missing frame on startup if introspect is delayed
            try? await Task.sleep(for: .milliseconds(100))
            if let tabBarController = tabBarController {
                configureAppearance(tabBarController)
            }
        }
        .onReceive(ServiceLocator.shared.settings.$appAppearance) { _ in
            // Update appearance asynchronously to avoid modifying state during view update
            // This is critical for custom dark themes (darkBlue, darkGreen, darkPurple)
            // which don't change interfaceStyle but still need appearance refresh
            Task { @MainActor in
                updateTabBarAppearance()
            }
        }
        .sheet(item: $navigationTabCoordinator.sheetModule) { module in
            module.coordinator?.toPresentable()
                .id(module.id)
        }
        .fullScreenCover(item: $navigationTabCoordinator.fullScreenCoverModule) { module in
            module.coordinator?.toPresentable()
                .id(module.id)
        }
        .accessibilityHidden(navigationTabCoordinator.overlayModule?.coordinator != nil && navigationTabCoordinator.overlayPresentationMode == .fullScreen)
        .overlay {
            Group {
                if let coordinator = navigationTabCoordinator.overlayModule?.coordinator {
                    coordinator.toPresentable()
                        .opacity(navigationTabCoordinator.overlayPresentationMode == .minimized ? 0 : 1)
                        .transition(.opacity)
                }
            }
            .animation(.elementDefault, value: navigationTabCoordinator.overlayPresentationMode)
            .animation(.elementDefault, value: navigationTabCoordinator.overlayModule)
        }
    }
    
    private func configureAppearance(_ tabBarController: UITabBarController) {
        let standardAppearance = UITabBarAppearance()
        
        // Configure with default background to preserve selection indicator
        // This ensures the background frame around selected icons is displayed
        standardAppearance.configureWithDefaultBackground()
        
        // Override with theme-aware background color
        // This ensures dark blue and dark green themes are properly applied
        standardAppearance.backgroundColor = UIColor.compound.bgCanvasDefault
        
        // Configure badge colors
        standardAppearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .compound.iconAccentPrimary // iPhone Portrait
        standardAppearance.compactInlineLayoutAppearance.normal.badgeBackgroundColor = .compound.iconAccentPrimary // iPhone Landscape
        standardAppearance.inlineLayoutAppearance.normal.badgeBackgroundColor = .compound.iconAccentPrimary // iPadOS 17 (doesn't work for 18+)
        
        // Configure icon and text colors for normal (unselected) state - use bright colors
        standardAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.compound.iconPrimary
        standardAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.compound.textPrimary
        ]
        
        // Configure icon and text colors for selected state - use bright colors
        standardAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.compound.iconPrimary
        standardAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.compound.textPrimary
        ]
        
        // Apply same configuration to compact and inline layouts
        standardAppearance.compactInlineLayoutAppearance.normal.iconColor = UIColor.compound.iconPrimary
        standardAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.compound.textPrimary
        ]
        standardAppearance.compactInlineLayoutAppearance.selected.iconColor = UIColor.compound.iconPrimary
        standardAppearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.compound.textPrimary
        ]
        
        standardAppearance.inlineLayoutAppearance.normal.iconColor = UIColor.compound.iconPrimary
        standardAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.compound.textPrimary
        ]
        standardAppearance.inlineLayoutAppearance.selected.iconColor = UIColor.compound.iconPrimary
        standardAppearance.inlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.compound.textPrimary
        ]
        
        tabBarController.tabBar.standardAppearance = standardAppearance
        tabBarController.tabBar.scrollEdgeAppearance = standardAppearance
        
        // Ensure selection indicator is visible (background/frame around selected icon)
        // Create a custom selection indicator to ensure it's visible on all themes
        // This creates the visual frame around the selectable tab items
        let selectionColor = UIColor.compound.bgSubtleSecondary.withAlphaComponent(0.3)
        let selectionImage = createSelectionIndicatorImage(color: selectionColor)
        tabBarController.tabBar.selectionIndicatorImage = selectionImage
        
        // Ensure the tab bar shows the top border/separator by configuring shadow
        // This is needed to display the frame around the tab bar
        tabBarController.tabBar.shadowImage = nil // Use default shadow
        tabBarController.tabBar.clipsToBounds = false // Allow shadow to be visible
        
        // Force the tab bar to update its layout and selection indicator
        // This ensures the frame appears immediately on startup and after theme changes
        DispatchQueue.main.async {
            tabBarController.tabBar.setNeedsLayout()
            tabBarController.tabBar.layoutIfNeeded()
            
            // Force selection indicator to refresh by toggling selection
            // This is necessary for custom dark themes where interfaceStyle doesn't change
            if let selectedItem = tabBarController.tabBar.selectedItem {
                let selectedIndex = tabBarController.tabBar.items?.firstIndex(of: selectedItem)
                tabBarController.selectedIndex = selectedIndex ?? 0
            }
        }
    }
    
    private func updateTabBarAppearance() {
        guard let tabBarController = tabBarController else { return }
        configureAppearance(tabBarController)
        
        // Force immediate layout update to ensure selection indicator is visible
        // This is critical when switching between themes with same interfaceStyle
        tabBarController.tabBar.setNeedsLayout()
        tabBarController.tabBar.layoutIfNeeded()
    }
    
    /// Creates a custom selection indicator image for the tab bar
    /// This ensures the selection indicator is visible on all themes
    private func createSelectionIndicatorImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 60, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Create a rounded rectangle for the selection indicator
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 15)
        
        context.setFillColor(color.cgColor)
        path.fill()
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Make the image resizable so it adapts to different tab item sizes
        let capInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}

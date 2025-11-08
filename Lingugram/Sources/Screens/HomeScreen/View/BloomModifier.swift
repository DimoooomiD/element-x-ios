//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Compound
import Foundation
import SwiftUI
import SwiftUIIntrospect

// MARK: - Custom Gradient Helper

/// Creates a customizable header gradient
/// Modify the color values here to change the gradient appearance
private func headerGradient() -> Gradient {
    // Original Compound subtle gradient
    Gradient(colors: [
        .compound.gradientSubtleStop1, // Top color - darkest
        .compound.gradientSubtleStop2,
        .compound.gradientSubtleStop3,
        .compound.gradientSubtleStop4,
        .compound.gradientSubtleStop5,
        .compound.gradientSubtleStop6 // Bottom color - lightest
    ])
}

extension View {
    /// Adds a bloom behind the navigation bar.
    /// - Parameters:
    ///   - hasSearchBar: Whether or not the navigation bar contains a search bar (so that
    /// the bloom can be sized appropriately).
    ///   - headerOnly: If true, limits the gradient to just the header area (safe area + nav bar).
    /// If false, extends the gradient further down for a longer bright section.
    @ViewBuilder func toolbarBloom(hasSearchBar: Bool, headerOnly: Bool = false) -> some View {
        modifier(GradientToggleModifier(hasSearchBar: hasSearchBar, headerOnly: headerOnly))
    }
}

private struct GradientToggleModifier: ViewModifier {
    let hasSearchBar: Bool
    let headerOnly: Bool
    @State private var gradientEnabled: Bool = ServiceLocator.shared.settings.headerGradientEnabled
    
    func body(content: Content) -> some View {
        Group {
            if gradientEnabled {
                if #available(iOS 26, *) {
                    content.modifier(BloomModifier(hasSearchBar: hasSearchBar, headerOnly: headerOnly))
                } else {
                    content.modifier(OldBloomModifier(hasSearchBar: hasSearchBar, headerOnly: headerOnly))
                }
            } else {
                content
            }
        }
        .onReceive(ServiceLocator.shared.settings.$headerGradientEnabled) { newValue in
            gradientEnabled = newValue
        }
    }
}

private struct BloomModifier: ViewModifier {
    let hasSearchBar: Bool
    let headerOnly: Bool
    
    @State private var height = CGFloat.zero
    
    // Extend the gradient further down for a longer bright section
    private var gradientHeight: CGFloat {
        if headerOnly {
            // For header-only, limit to safe area + navigation bar height (44pt)
            return height + 44
        } else {
            // Make the gradient 3x the safe area height to extend the bright section
            return height * 3.0
        }
    }
    
    // Keep endPoint at 1.0 to let the gradient complete fully across the extended height
    private var endPointY: CGFloat { hasSearchBar ? 0.6 : 1.0 }
    
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.safeAreaInsets.top
            } action: { height in
                self.height = height
            }
            .overlay(alignment: .top) {
                LinearGradient(gradient: headerGradient(),
                               startPoint: .top,
                               endPoint: .init(x: 0.5, y: endPointY))
                    .ignoresSafeArea(edges: .all)
                    .frame(height: gradientHeight)
                    .allowsHitTesting(false)
                    // Does not render properly on dark themes otherwise
                    .colorScheme(.light)
            }
    }
}

private struct OldBloomModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    let hasSearchBar: Bool
    let headerOnly: Bool
    
    @State private var standardAppearance = UINavigationBarAppearance()
    @State private var scrollEdgeAppearance = UINavigationBarAppearance()
    
    @State private var bloom = Bloom()
    @State private var controllerRef = ControllerRef()
    @State private var hasAppeared = false
    @State private var lastAppliedTimestamp: Date?
    
    func body(content: Content) -> some View {
        content
            .introspect(.viewController, on: .supportedVersions) { controller in
                controllerRef.controller = controller
                // Apply asynchronously to ensure view is ready
                // Use force: true for initial setup to ensure gradient is always applied
                Task { @MainActor in
                    // Small delay to ensure navigation controller is fully set up
                    try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
                    configureBloom(controller: controller, force: true)
                }
            }
            .onAppear {
                hasAppeared = true
                // Always re-apply when view appears to handle navigation bar resets
                // Use multiple retry attempts with increasing delays
                Task { @MainActor in
                    // First attempt after short delay
                    try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                    if let controller = controllerRef.controller {
                        configureBloom(controller: controller, force: true)
                    }
                    
                    // Second attempt after longer delay to catch late resets
                    try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
                    if let controller = controllerRef.controller {
                        configureBloom(controller: controller, force: true)
                    }
                    
                    // Third attempt after even longer delay for edge cases
                    try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                    if let controller = controllerRef.controller {
                        configureBloom(controller: controller, force: true)
                    }
                }
            }
            .onDisappear {
                hasAppeared = false
            }
            .task {
                // Periodic check to ensure gradient remains applied
                // This handles cases where SwiftUI resets the navigation bar after onAppear
                while hasAppeared {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
                    if let controller = controllerRef.controller {
                        // Only re-apply if gradient is missing or stale
                        if !isGradientApplied(controller: controller) {
                            configureBloom(controller: controller, force: true)
                        }
                    }
                }
            }
    }
    
    /// Verifies if the gradient is actually applied to the navigation bar
    private func isGradientApplied(controller: UIViewController) -> Bool {
        // First ensure we have a bloom image to compare against
        // If we don't have one yet, we can't verify, so return false to trigger application
        guard let bloomImage = bloom.image,
              canUse(bloom) else {
            return false
        }
        
        // Check standard appearance
        let standardAppearance = controller.navigationItem.standardAppearance
        guard let standardBackgroundImage = standardAppearance?.backgroundImage else {
            return false
        }
        
        // Check scroll edge appearance
        let scrollEdgeAppearance = controller.navigationItem.scrollEdgeAppearance
        guard let scrollEdgeBackgroundImage = scrollEdgeAppearance?.backgroundImage else {
            return false
        }
        
        // Verify both appearances have the gradient image applied
        // Use reference equality first (fastest), then fall back to content comparison if needed
        let standardMatches = standardBackgroundImage === bloomImage
        let scrollEdgeMatches = scrollEdgeBackgroundImage === bloomImage
        
        // If reference equality fails, check if images are similar in size and properties
        // This handles cases where SwiftUI creates new image instances with same content
        if !standardMatches || !scrollEdgeMatches {
            // Check if images have similar dimensions and properties
            let standardSizeMatches = standardBackgroundImage.size == bloomImage.size
                && standardBackgroundImage.scale == bloomImage.scale
            let scrollEdgeSizeMatches = scrollEdgeBackgroundImage.size == bloomImage.size
                && scrollEdgeBackgroundImage.scale == bloomImage.scale

            // If sizes match, assume it's the same gradient (SwiftUI may have recreated the image)
            // Also check that the images are non-zero size (valid gradient images)
            return standardSizeMatches && scrollEdgeSizeMatches
                && bloomImage.size.width > 0 && bloomImage.size.height > 0
        }
        
        return true
    }
    
    private func configureBloom(controller: UIViewController, force: Bool) {
        // Create/update bloom image first (needed for both check and application)
        // This modifies self.bloom since Bloom is a class (reference type)
        _ = makeBloom()
        
        // If forcing (e.g., on appear), always re-apply to handle navigation bar resets
        if !force {
            // Improved check: verify the gradient is actually applied to the navigation bar
            // Only check if we have a valid bloom image
            if bloom.image != nil, isGradientApplied(controller: controller) {
                return
            }
        }
        
        // Ensure we have a valid image before applying
        guard let bloomImage = bloom.image else {
            // Retry after a short delay if image rendering failed
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                configureBloom(controller: controller, force: force)
            }
            return
        }
        
        // Create new appearance instances to avoid reference issues
        let newStandardAppearance = UINavigationBarAppearance()
        let newScrollEdgeAppearance = UINavigationBarAppearance()
        
        // Use transparent background for consistency with main menus
        // This ensures the gradient depth is the same across all screens
        newStandardAppearance.configureWithTransparentBackground()
        newStandardAppearance.backgroundImage = bloomImage
        newStandardAppearance.backgroundImageContentMode = .scaleToFill
        newStandardAppearance.backgroundColor = .compound.bgCanvasDefault
        controller.navigationItem.standardAppearance = newStandardAppearance
        
        newScrollEdgeAppearance.configureWithTransparentBackground()
        newScrollEdgeAppearance.backgroundImage = bloomImage
        newScrollEdgeAppearance.backgroundImageContentMode = .scaleToFill
        newScrollEdgeAppearance.backgroundColor = .compound.bgCanvasDefault
        controller.navigationItem.scrollEdgeAppearance = newScrollEdgeAppearance
        
        // Update stored appearances for future comparisons
        standardAppearance = newStandardAppearance
        scrollEdgeAppearance = newScrollEdgeAppearance
        lastAppliedTimestamp = Date()
        
        // Force navigation bar to update immediately
        DispatchQueue.main.async {
            controller.navigationController?.navigationBar.setNeedsLayout()
            controller.navigationController?.navigationBar.layoutIfNeeded()
        }
    }
    
    private func makeBloom() -> Bloom {
        if bloom.image != nil, canUse(bloom) {
            return bloom
        }
        
        // There's a bug somewhere when rendering in dark mode (which we've mistakenly not been doing)
        // which results in the first 5 stops not having any alpha, only the last one…
        let renderer = ImageRenderer(content: bloomGradient /* .colorScheme(colorScheme) */ )
        renderer.scale = UIScreen.main.scale
        
        // Ensure rendering happens on main thread with proper scale
        let newImage = renderer.uiImage
        
        // If rendering failed, try again with explicit size
        if newImage == nil {
            let fallbackRenderer = ImageRenderer(content: bloomGradient)
            fallbackRenderer.scale = UIScreen.main.scale
            fallbackRenderer.proposedSize = ProposedViewSize(width: 256, height: 384)
            bloom.image = fallbackRenderer.uiImage
        } else {
            bloom.image = newImage
        }
        
        bloom.colorScheme = colorScheme
        bloom.baseColor = .compound.gradientSubtleStop1
        return bloom
    }
    
    // Extend the gradient further down for a longer bright section
    private var endPointY: CGFloat { hasSearchBar ? 0.6 : 1.0 }
    
    private var bloomGradient: some View {
        let gradientHeight: CGFloat = headerOnly ? 88 : 384 // Header-only: safe area (~44) + nav bar (44)
        return LinearGradient(gradient: headerGradient(),
                              startPoint: .top,
                              endPoint: .init(x: 0.5, y: endPointY))
            .ignoresSafeArea(edges: .all)
            .frame(width: 256, height: gradientHeight)
    }
    
    private func canUse(_ bloom: Bloom) -> Bool {
        // Don't check for a nil image in here, there's no point re-rendering over and over if the render fails.
        bloom.colorScheme == colorScheme && bloom.baseColor == .compound.gradientSubtleStop1
    }
    
    // This is a class to avoid a "Modifying state during view update" warning when storing
    // the result on the same run-loop - we want to avoid dispatching that to the next loop as
    // that can result in further (unnecessary) renders being made.
    class Bloom {
        var image: UIImage?
        var colorScheme: ColorScheme?
        var baseColor: Color?
    }
    
    // Store controller reference to allow re-application on appear
    class ControllerRef {
        weak var controller: UIViewController?
    }
}

// MARK: - Previews

struct BloomModifier_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        NavigationStack {
            mockScreen
                .navigationTitle(L10n.screenRoomlistMainSpaceTitle)
                .searchable(text: .constant(""), placement: .navigationBarDrawer(displayMode: .always))
                .toolbarBloom(hasSearchBar: true)
        }
        .previewDisplayName("Chats")
        
        NavigationStack {
            mockScreen
                .navigationTitle(L10n.screenSpaceListTitle)
                .toolbarBloom(hasSearchBar: false)
        }
        .previewDisplayName("Spaces")
    }
    
    static var mockScreen: some View {
        List { }
            .toolbar {
                Button { } label: { CompoundIcon(\.check) }
                    .accessibilityLabel(L10n.actionConfirm) // Keep the a11y tests happy 😄
            }
    }
}

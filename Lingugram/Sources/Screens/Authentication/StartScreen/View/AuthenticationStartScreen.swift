//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI
import UIKit

/// The screen shown at the beginning of the onboarding flow.
struct AuthenticationStartScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let context: AuthenticationStartScreenViewModel.Context
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: UIConstants.spacerHeight(in: geometry))
                
                content
                    .frame(width: geometry.size.width)
                    .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.hidden)
                
                buttons
                    .frame(width: geometry.size.width)
                    .padding(.bottom, UIConstants.actionButtonBottomPadding)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                    .padding(.top, 8)
                
                Spacer()
                    .frame(height: UIConstants.spacerHeight(in: geometry))
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                versionText
                    .font(.compound.bodySM)
                    .foregroundColor(.compound.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    .onTapGesture(count: 7) {
                        context.send(viewAction: .reportProblem)
                    }
                    .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.appVersion)
            }
        }
        .navigationBarHidden(true)
        .background {
            LanguageLearningBackground(config: backgroundConfig)
        }
        .introspect(.window, on: .supportedVersions) { window in
            context.send(viewAction: .updateWindow(window))
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            if verticalSizeClass == .regular {
                Spacer()
                    .frame(height: 80)
                
                // Combined icon and text without frame
                VStack(spacing: 12) {
                    // App logo
                    Image(asset: Asset.Images.appLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    
                    VStack(spacing: 8) {
                        Text("Lingugram")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background {
                                ZStack {
                                    // Base glassmorphism background
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                    
                                    // Gradient overlay for depth
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.25),
                                                    Color.white.opacity(0.1),
                                                    Color.white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Subtle inner glow
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.4),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            }
                            .overlay {
                                // Outer border with gradient
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.6),
                                                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.4),
                                                Color.white.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            }
                            .shadow(color: Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.3), radius: 20, x: 0, y: 8)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            } else {
                // Compact layout for smaller screens
                Spacer()
                    .frame(height: 60)
                
                VStack(spacing: 8) {
                    // App logo
                    Image(asset: Asset.Images.appLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    VStack(spacing: 6) {
                        Text("Lingugram")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background {
                                ZStack {
                                    // Base glassmorphism background
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.ultraThinMaterial)
                                    
                                    // Gradient overlay for depth
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.25),
                                                    Color.white.opacity(0.1),
                                                    Color.white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Subtle inner glow
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.4),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            }
                            .overlay {
                                // Outer border with gradient
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.6),
                                                Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.4),
                                                Color.white.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            }
                            .shadow(color: Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.3), radius: 18, x: 0, y: 6)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .readableFrame()
    }
    
    /// The main action buttons.
    var buttons: some View {
        VStack(spacing: 16) {
            if context.viewState.showQRCodeLoginButton {
                Button { context.send(viewAction: .loginWithQR) } label: {
                    Label(L10n.screenOnboardingSignInWithQrCode, icon: \.qrCode)
                }
                .buttonStyle(.professional(.secondary))
                .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.signInWithQr)
            }
            
            Button { context.send(viewAction: .login) } label: {
                Text(context.viewState.loginButtonTitle)
            }
            .buttonStyle(.professional(.primary))
            .accessibilityIdentifier(A11yIdentifiers.authenticationStartScreen.signIn)
            
            if context.viewState.showCreateAccountButton {
                Button { context.send(viewAction: .register) } label: {
                    Text(L10n.screenCreateAccountTitle)
                }
                .buttonStyle(.professional(.tertiary))
            }
        }
        .padding(.horizontal, verticalSizeClass == .compact ? 128 : 24)
        .readableFrame()
    }
    
    var versionText: Text {
        // Let's not deal with snapshotting a changing version string.
        let shortVersionString = ProcessInfo.isRunningTests ? "0.0.0" : InfoPlistReader.main.bundleShortVersionString
        return Text(L10n.screenOnboardingAppVersion(shortVersionString))
    }
    
    private var backgroundConfig: LanguageBackgroundConfig {
        if verticalSizeClass == .regular {
            return LanguageBackgroundConfig(
                emojiCount: 36,
                verticalStart: 0.05,
                verticalEnd: 0.95,
                horizontalPadding: 12,
                centerGapFraction: 0.0,
                speedMultiplier: 1.0,
                uniformDistribution: false,
                randomDistribution: true
            )
        } else {
            return LanguageBackgroundConfig(
                emojiCount: 28,
                verticalStart: 0.05,
                verticalEnd: 0.95,
                horizontalPadding: 10,
                centerGapFraction: 0.0,
                speedMultiplier: 0.9,
                uniformDistribution: false,
                randomDistribution: true
            )
        }
    }
}

// MARK: - Previews

struct AuthenticationStartScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    static let provisionedViewModel = makeViewModel(provisionedServerName: "example.com")
    
    static var previews: some View {
        AuthenticationStartScreen(context: viewModel.context)
            .previewDisplayName("Default")
        AuthenticationStartScreen(context: provisionedViewModel.context)
            .previewDisplayName("Provisioned")
    }
    
    static func makeViewModel(provisionedServerName: String? = nil) -> AuthenticationStartScreenViewModel {
        AuthenticationStartScreenViewModel(authenticationService: AuthenticationService.mock,
                                           provisioningParameters: provisionedServerName.map { .init(accountProvider: $0, loginHint: nil) },
                                           isBugReportServiceEnabled: true,
                                           appSettings: ServiceLocator.shared.settings,
                                           userIndicatorController: UserIndicatorControllerMock())
    }
}

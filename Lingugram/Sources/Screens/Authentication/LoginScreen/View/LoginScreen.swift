//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct LoginScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    /// The focus state of the username text field.
    @FocusState private var isUsernameFocused: Bool
    /// The focus state of the password text field.
    @FocusState private var isPasswordFocused: Bool
    
    @Bindable var context: LoginScreenViewModel.Context
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: UIConstants.spacerHeight(in: geometry))
                
                content
                    .frame(width: geometry.size.width)
                
                buttons
                    .frame(width: geometry.size.width)
                    .padding(.bottom, UIConstants.actionButtonBottomPadding)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 16)
                    .padding(.top, 32)
                
                Spacer()
                    .frame(height: UIConstants.spacerHeight(in: geometry))
            }
            .frame(maxHeight: .infinity)
        }
        .background {
            LanguageLearningBackground(config: backgroundConfig)
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Login")
        .alert(item: $context.alertInfo)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            switch context.viewState.loginMode {
            case .password:
                loginForm
            case .oidc:
                // This should never be shown.
                ProgressView()
            default:
                // This should never be shown either.
                loginUnavailableText
            }
        }
        .readableFrame()
        .padding(.horizontal, 24)
    }
    
    /// The form with text fields for username and password.
    var loginForm: some View {
        VStack(alignment: .leading, spacing: 18) {
            TextField(text: $context.username) {
                Text(L10n.commonUsername).foregroundColor(.white.opacity(0.7))
            }
            .focused($isUsernameFocused)
            .textFieldStyle(.professional(accessibilityIdentifier: A11yIdentifiers.loginScreen.emailUsername))
            .disableAutocorrection(true)
            .textContentType(.username)
            .autocapitalization(.none)
            .submitLabel(.next)
            .onChange(of: isUsernameFocused) { _, newValue in
                usernameFocusChanged(isFocussed: newValue)
            }
            .onSubmit { isPasswordFocused = true }
            
            SecureField(text: $context.password) {
                Text(L10n.commonPassword).foregroundColor(.white.opacity(0.7))
            }
            .focused($isPasswordFocused)
            .textFieldStyle(.professional(accessibilityIdentifier: A11yIdentifiers.loginScreen.password))
            .textContentType(.password)
            .submitLabel(.done)
            .onSubmit(submit)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// The action buttons.
    var buttons: some View {
        VStack(spacing: 16) {
            Button(action: submit) {
                Text(L10n.actionContinue)
            }
            .buttonStyle(ProfessionalButtonStyle(variant: .primary, isEnabled: context.viewState.canSubmit))
            .disabled(!context.viewState.canSubmit)
            .accessibilityIdentifier(A11yIdentifiers.loginScreen.continue)
        }
        .padding(.horizontal, 24)
        .readableFrame()
    }
    
    /// Text shown if neither password or OIDC login is supported.
    var loginUnavailableText: some View {
        Text(L10n.screenLoginErrorUnsupportedAuthentication)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.compound.textPrimary)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier(A11yIdentifiers.loginScreen.unsupportedServer)
    }
    
    private var backgroundConfig: LanguageBackgroundConfig {
        if verticalSizeClass == .regular {
            return LanguageBackgroundConfig(emojiCount: 36,
                                            verticalStart: 0.05,
                                            verticalEnd: 0.95,
                                            horizontalPadding: 12,
                                            centerGapFraction: 0.0,
                                            speedMultiplier: 1.0,
                                            uniformDistribution: false,
                                            randomDistribution: true)
        } else {
            return LanguageBackgroundConfig(emojiCount: 28,
                                            verticalStart: 0.05,
                                            verticalEnd: 0.95,
                                            horizontalPadding: 10,
                                            centerGapFraction: 0.0,
                                            speedMultiplier: 0.9,
                                            uniformDistribution: false,
                                            randomDistribution: true)
        }
    }
    
    /// Parses the username for a homeserver.
    private func usernameFocusChanged(isFocussed: Bool) {
        guard !isFocussed, !context.username.isEmpty else { return }
        context.send(viewAction: .parseUsername)
    }
    
    /// Sends the `next` view action so long as valid credentials have been input.
    private func submit() {
        guard context.viewState.canSubmit else { return }
        context.send(viewAction: .next)
        isUsernameFocused = false
        isPasswordFocused = false
    }
}

// MARK: - Previews

struct LoginScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    static let credentialsViewModel = makeViewModel(withCredentials: true)
    static let unconfiguredViewModel = makeViewModel(homeserverAddress: "somethingtofailconfiguration")
    
    static var previews: some View {
        NavigationStack {
            LoginScreen(context: viewModel.context)
        }
        .snapshotPreferences(expect: viewModel.context.observe(\.viewState.homeserver.loginMode).map { $0 == .password }.eraseToStream())
        .previewDisplayName("Initial State")
        
        NavigationStack {
            LoginScreen(context: credentialsViewModel.context)
        }
        .snapshotPreferences(expect: credentialsViewModel.context.observe(\.viewState.homeserver.loginMode).map { $0 == .password }.eraseToStream())
        .previewDisplayName("Credentials Entered")
        
        NavigationStack {
            LoginScreen(context: unconfiguredViewModel.context)
        }
        .previewDisplayName("Unsupported")
    }
    
    static func makeViewModel(homeserverAddress: String = "example.com", withCredentials: Bool = false) -> LoginScreenViewModel {
        let authenticationService = AuthenticationService.mock
        
        Task { await authenticationService.configure(for: homeserverAddress, flow: .login) }
        
        let viewModel = LoginScreenViewModel(authenticationService: authenticationService,
                                             loginHint: nil,
                                             userIndicatorController: UserIndicatorControllerMock(),
                                             appSettings: ServiceLocator.shared.settings,
                                             analytics: ServiceLocator.shared.analytics)
        
        if withCredentials {
            viewModel.context.username = "alice"
            viewModel.context.password = "password"
        }
        
        return viewModel
    }
}

//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct RegistrationScreen: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    /// The focus state of the username text field.
    @FocusState private var isUsernameFocused: Bool
    /// The focus state of the password text field.
    @FocusState private var isPasswordFocused: Bool
    /// The focus state of the password confirmation text field.
    @FocusState private var isPasswordConfirmFocused: Bool
    
    @Bindable var context: RegistrationScreenViewModel.Context
    
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
        .navigationTitle("Create Account")
        .alert(item: $context.alertInfo)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            switch context.viewState.loginMode {
            case .password:
                registrationForm
            case .oidc:
                // This should never be shown.
                ProgressView()
            default:
                // This should never be shown either.
                registrationUnavailableText
            }
        }
        .readableFrame()
        .padding(.horizontal, 24)
    }
    
    /// The form with text fields for username, password, and password confirmation.
    var registrationForm: some View {
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
            .onSubmit { isPasswordFocused = true }
            
            SecureField(text: $context.password) {
                Text(L10n.commonPassword).foregroundColor(.white.opacity(0.7))
            }
            .focused($isPasswordFocused)
            .textFieldStyle(.professional(accessibilityIdentifier: A11yIdentifiers.loginScreen.password))
            .textContentType(.newPassword)
            .submitLabel(.next)
            .onSubmit { isPasswordConfirmFocused = true }
            
            SecureField(text: $context.passwordConfirm) {
                Text("Confirm Password").foregroundColor(.white.opacity(0.7))
            }
            .focused($isPasswordConfirmFocused)
            .textFieldStyle(.professional(accessibilityIdentifier: A11yIdentifiers.loginScreen.password))
            .textContentType(.newPassword)
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
    
    /// Text shown if neither password or OIDC registration is supported.
    var registrationUnavailableText: some View {
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
    
    /// Sends the `next` view action so long as valid credentials have been input.
    private func submit() {
        guard context.viewState.canSubmit else { return }
        context.send(viewAction: .next)
        isUsernameFocused = false
        isPasswordFocused = false
        isPasswordConfirmFocused = false
    }
}

// MARK: - Previews

struct RegistrationScreen_Previews: PreviewProvider, TestablePreview {
    static let viewModel = makeViewModel()
    
    static var previews: some View {
        NavigationStack {
            RegistrationScreen(context: viewModel.context)
        }
        .previewDisplayName("Initial State")
    }
    
    static func makeViewModel() -> RegistrationScreenViewModel {
        let authenticationService = AuthenticationService.mock
        
        Task { await authenticationService.configure(for: "http://192.168.178.34", flow: .register) }
        
        let viewModel = RegistrationScreenViewModel(authenticationService: authenticationService,
                                                    userIndicatorController: UserIndicatorControllerMock(),
                                                    appSettings: ServiceLocator.shared.settings,
                                                    analytics: ServiceLocator.shared.analytics)
        
        return viewModel
    }
}

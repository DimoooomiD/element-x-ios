//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

struct RegistrationScreen: View {
    /// The focus state of the username text field.
    @FocusState private var isUsernameFocused: Bool
    /// The focus state of the password text field.
    @FocusState private var isPasswordFocused: Bool
    /// The focus state of the password confirmation text field.
    @FocusState private var isPasswordConfirmFocused: Bool
    
    @Bindable var context: RegistrationScreenViewModel.Context
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, UIConstants.titleTopPaddingToNavigationBar)
                    .padding(.bottom, 32)
                
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
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $context.alertInfo)
    }
    
    /// The header containing the title and icon.
    var header: some View {
        VStack(spacing: 8) {
            BigIcon(icon: \.lockSolid)
                .padding(.bottom, 8)
            
            Text(L10n.screenCreateAccountTitle)
                .font(.compound.headingMDBold)
                .multilineTextAlignment(.center)
                .foregroundColor(.compound.textPrimary)
        }
        .padding(.horizontal, 16)
    }
    
    /// The form with text fields for username, password, and password confirmation, along with a submit button.
    var registrationForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.screenLoginFormHeader)
                .font(.compound.bodySM)
                .foregroundColor(.compound.textPrimary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            TextField(text: $context.username) {
                Text(L10n.commonUsername).foregroundColor(.compound.textSecondary)
            }
            .focused($isUsernameFocused)
            .textFieldStyle(.element(accessibilityIdentifier: A11yIdentifiers.loginScreen.emailUsername))
            .disableAutocorrection(true)
            .textContentType(.username)
            .autocapitalization(.none)
            .submitLabel(.next)
            .onSubmit { isPasswordFocused = true }
            .padding(.bottom, 20)
            
            SecureField(text: $context.password) {
                Text(L10n.commonPassword).foregroundColor(.compound.textSecondary)
            }
            .focused($isPasswordFocused)
            .textFieldStyle(.element(accessibilityIdentifier: A11yIdentifiers.loginScreen.password))
            .textContentType(.newPassword)
            .submitLabel(.next)
            .onSubmit { isPasswordConfirmFocused = true }
            .padding(.bottom, 20)
            
            SecureField(text: $context.passwordConfirm) {
                Text("Confirm Password").foregroundColor(.compound.textSecondary)
            }
            .focused($isPasswordConfirmFocused)
            .textFieldStyle(.element(accessibilityIdentifier: A11yIdentifiers.loginScreen.password))
            .textContentType(.newPassword)
            .submitLabel(.done)
            .onSubmit(submit)
            
            Spacer().frame(height: 32)

            Button(action: submit) {
                Text(L10n.actionContinue)
            }
            .buttonStyle(.compound(.primary))
            .disabled(!context.viewState.canSubmit)
            .accessibilityIdentifier(A11yIdentifiers.loginScreen.continue)
        }
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


//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias AuthenticationStartScreenViewModelType = StateStoreViewModelV2<AuthenticationStartScreenViewState, AuthenticationStartScreenViewAction>

class AuthenticationStartScreenViewModel: AuthenticationStartScreenViewModelType, AuthenticationStartScreenViewModelProtocol {
    private let authenticationService: AuthenticationServiceProtocol
    private let provisioningParameters: AccountProvisioningParameters?
    private let appSettings: AppSettings
    private let userIndicatorController: UserIndicatorControllerProtocol
    
    private let canReportProblem: Bool
    
    // Hardcoded localhost server address - not visible to users
    private static let defaultServerAddress = "http://192.168.178.34"
    
    private var actionsSubject: PassthroughSubject<AuthenticationStartScreenViewModelAction, Never> = .init()
    
    var actions: AnyPublisher<AuthenticationStartScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(authenticationService: AuthenticationServiceProtocol,
         provisioningParameters: AccountProvisioningParameters?,
         isBugReportServiceEnabled: Bool,
         appSettings: AppSettings,
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.authenticationService = authenticationService
        self.provisioningParameters = provisioningParameters
        self.appSettings = appSettings
        self.userIndicatorController = userIndicatorController
        canReportProblem = isBugReportServiceEnabled
        
        let initialViewState = if !appSettings.allowOtherAccountProviders {
            // We don't show the create account button when custom providers are disallowed.
            // The assumption here being that if you're running a custom app, your users will already be created.
            AuthenticationStartScreenViewState(serverName: appSettings.accountProviders.count == 1 ? appSettings.accountProviders[0] : nil,
                                               showCreateAccountButton: false,
                                               showQRCodeLoginButton: false,
                                               hideBrandChrome: appSettings.hideBrandChrome)
        } else if let provisioningParameters {
            // We only show the "Sign in to …" button when using a provisioning link.
            AuthenticationStartScreenViewState(serverName: provisioningParameters.accountProvider,
                                               showCreateAccountButton: false,
                                               showQRCodeLoginButton: false,
                                               hideBrandChrome: appSettings.hideBrandChrome)
        } else {
            // The default configuration.
            AuthenticationStartScreenViewState(serverName: nil,
                                               showCreateAccountButton: appSettings.showCreateAccountButton,
                                               showQRCodeLoginButton: false,
                                               hideBrandChrome: appSettings.hideBrandChrome)
        }
        
        super.init(initialViewState: initialViewState)
    }

    override func process(viewAction: AuthenticationStartScreenViewAction) {
        switch viewAction {
        case .updateWindow(let window):
            guard state.window != window else { return }
            state.window = window
        case .loginWithQR:
            actionsSubject.send(.loginWithQR)
        case .login:
            Task { await login() }
        case .register:
            Task { await register() }
        case .reportProblem:
            if canReportProblem {
                actionsSubject.send(.reportProblem)
            }
        }
    }
    
    // MARK: - Private
    
    private func login() async {
        if let serverName = state.serverName {
            await configureAccountProvider(serverName, loginHint: provisioningParameters?.loginHint)
        } else {
            // Automatically configure the default localhost server
            await configureAccountProvider(Self.defaultServerAddress, loginHint: provisioningParameters?.loginHint)
        }
    }
    
    private func register() async {
        // Automatically configure the default localhost server for registration
        // Add a small delay to ensure UI is ready
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        await configureAccountProviderForRegistration(Self.defaultServerAddress)
    }
    
    private func configureAccountProvider(_ accountProvider: String, loginHint: String? = nil) async {
        startLoading()
        defer { stopLoading() }
        
        guard case .success = await authenticationService.configure(for: accountProvider, flow: .login) else {
            // As the server was provisioned, we don't worry about the specifics and show a generic error to the user.
            displayError()
            return
        }
        
        guard authenticationService.homeserver.value.loginMode.supportsOIDCFlow else {
            actionsSubject.send(.loginDirectlyWithPassword(loginHint: loginHint))
            return
        }
        
        guard let window = state.window else {
            displayError()
            return
        }
        
        switch await authenticationService.urlForOIDCLogin(loginHint: loginHint) {
        case .success(let oidcData):
            actionsSubject.send(.loginDirectlyWithOIDC(data: oidcData, window: window))
        case .failure:
            displayError()
        }
    }
    
    private func configureAccountProviderForRegistration(_ accountProvider: String) async {
        startLoading()
        defer { stopLoading() }
        
        switch await authenticationService.configure(for: accountProvider, flow: .register) {
        case .success:
            // Registration requires OIDC support, so if we get here, OIDC is supported
            guard authenticationService.homeserver.value.loginMode.supportsOIDCFlow else {
                // This shouldn't happen as configuration should have failed, but handle it anyway
                // Fall back to showing server confirmation screen which will display the error
                actionsSubject.send(.register)
                return
            }
            
            // Try to get window from state first, if not available, wait a bit and try again
            var window = state.window
            if window == nil {
                // Wait a short moment for the window to be set
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                window = state.window
            }
            
            // If window is still not available, fall back to server confirmation screen
            // which can handle getting the window and proceeding
            guard let window = window else {
                // Fall back to server confirmation screen which will handle this
                actionsSubject.send(.register)
                return
            }
            
            switch await authenticationService.urlForOIDCLogin(loginHint: nil) {
            case .success(let oidcData):
                // Go directly to OIDC registration, skipping server confirmation screen
                actionsSubject.send(.loginDirectlyWithOIDC(data: oidcData, window: window))
            case .failure:
                // If OIDC URL fetch fails, fall back to server confirmation screen
                // which will display the error properly
                actionsSubject.send(.register)
            }
        case .failure:
            // Configuration failed (e.g., registration not supported, server unreachable, etc.)
            // Show server confirmation screen which will display the specific error
            actionsSubject.send(.register)
        }
    }
    
    private let loadingIndicatorID = "\(AuthenticationStartScreenViewModel.self)-Loading"
    
    private func startLoading() {
        userIndicatorController.submitIndicator(UserIndicator(id: loadingIndicatorID,
                                                              type: .modal,
                                                              title: L10n.commonLoading,
                                                              persistent: true))
    }
    
    private func stopLoading() {
        userIndicatorController.retractIndicatorWithId(loadingIndicatorID)
    }
    
    private func displayError() {
        state.bindings.alertInfo = AlertInfo(id: .genericError)
    }
}

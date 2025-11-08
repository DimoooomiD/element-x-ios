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
            let loginMode = authenticationService.homeserver.value.loginMode
            
            // Prefer password-based registration for local server to avoid matrix.org redirects
            if loginMode == .password {
                // Use password-based registration - go to login screen which can handle registration
                actionsSubject.send(.register)
                return
            }
            
            // If OIDC is supported, check if it redirects to matrix.org
            if loginMode.supportsOIDCFlow {
                // Try to get window from state first, if not available, wait a bit and try again
                var window = state.window
                if window == nil {
                    // Wait a short moment for the window to be set
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                    window = state.window
                }
                
                // If window is still not available, fall back to server confirmation screen
                guard let window = window else {
                    actionsSubject.send(.register)
                    return
                }
                
                switch await authenticationService.urlForOIDCLogin(loginHint: nil) {
                case .success(let oidcData):
                    // Check if OIDC URL contains matrix.org - if so, use password registration instead
                    let oidcURLString = oidcData.url.absoluteString
                    if oidcURLString.contains("matrix.org") {
                        // OIDC redirects to matrix.org, use password registration instead
                        actionsSubject.send(.register)
                    } else {
                        // OIDC is for local server, proceed with OIDC
                        actionsSubject.send(.loginDirectlyWithOIDC(data: oidcData, window: window))
                    }
                case .failure:
                    // If OIDC URL fetch fails, fall back to password registration if available
                    if loginMode == .password {
                        actionsSubject.send(.register)
                    } else {
                        actionsSubject.send(.register)
                    }
                }
            } else {
                // No OIDC support, use password registration
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

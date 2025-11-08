//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias RegistrationScreenViewModelType = StateStoreViewModelV2<RegistrationScreenViewState, RegistrationScreenViewAction>

class RegistrationScreenViewModel: RegistrationScreenViewModelType, RegistrationScreenViewModelProtocol {
    private let authenticationService: AuthenticationServiceProtocol
    private let userIndicatorController: UserIndicatorControllerProtocol
    private let appSettings: AppSettings
    private let analytics: AnalyticsService
    
    private var actionsSubject: PassthroughSubject<RegistrationScreenViewModelAction, Never> = .init()
    var actions: AnyPublisher<RegistrationScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init(authenticationService: AuthenticationServiceProtocol,
         userIndicatorController: UserIndicatorControllerProtocol,
         appSettings: AppSettings,
         analytics: AnalyticsService) {
        self.authenticationService = authenticationService
        self.userIndicatorController = userIndicatorController
        self.appSettings = appSettings
        self.analytics = analytics
        
        let viewState = RegistrationScreenViewState(homeserver: authenticationService.homeserver.value,
                                                    bindings: RegistrationScreenBindings())
        
        super.init(initialViewState: viewState)
        
        authenticationService.homeserver
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.state.homeserver, on: self)
            .store(in: &cancellables)
    }

    override func process(viewAction: RegistrationScreenViewAction) {
        switch viewAction {
        case .next:
            register()
        }
    }
    
    func stopLoading() {
        state.isLoading = false
        userIndicatorController.retractIndicatorWithId(Self.loadingIndicatorIdentifier)
    }
    
    // MARK: - Private
    
    /// Requests the authentication coordinator to register using the specified credentials.
    private func register() {
        MXLog.info("Starting registration with password.")
        startLoading(isInteractionBlocking: true)
        
        Task {
            switch await authenticationService.register(username: state.bindings.username,
                                                       password: state.bindings.password,
                                                       initialDeviceName: UIDevice.current.initialDeviceName) {
            case .success(let userSession):
                actionsSubject.send(.signedIn(userSession))
                stopLoading()
            case .failure(let error):
                stopLoading()
                handleError(error)
            }
        }
    }
    
    private static let loadingIndicatorIdentifier = "\(RegistrationScreenCoordinatorAction.self)-Loading"
    
    private func startLoading(isInteractionBlocking: Bool) {
        if isInteractionBlocking {
            userIndicatorController.submitIndicator(UserIndicator(id: Self.loadingIndicatorIdentifier,
                                                                  type: .modal,
                                                                  title: L10n.commonLoading,
                                                                  persistent: true))
        } else {
            state.isLoading = true
        }
    }
    
    /// Processes an error to either update the flow or display it to the user.
    private func handleError(_ error: AuthenticationServiceError) {
        MXLog.error("Registration error occurred: \(error)")
        
        switch error {
        case .invalidCredentials:
            state.bindings.alertInfo = AlertInfo(id: .credentialsAlert,
                                                 title: L10n.commonError,
                                                 message: L10n.screenLoginErrorInvalidCredentials)
        case .registrationNotSupported:
            state.bindings.alertInfo = AlertInfo(id: .alert("Registration not supported"),
                                                 title: L10n.commonError,
                                                 message: "Registration is not supported on this server. Please contact the server administrator.")
        case .loginNotSupported:
            state.bindings.alertInfo = AlertInfo(id: .alert("Login not supported"),
                                                 title: L10n.commonError,
                                                 message: "Login is not supported on this server.")
        case .failedLoggingIn:
            state.bindings.alertInfo = AlertInfo(id: .alert("Registration failed"),
                                                 title: L10n.commonError,
                                                 message: "Failed to create account. Please check your username and password, and try again.")
        case .invalidHomeserverAddress:
            state.bindings.alertInfo = AlertInfo(id: .alert("Invalid server"),
                                                 title: L10n.commonError,
                                                 message: "The server address is invalid. Please check your connection and try again.")
        case .invalidWellKnown(let error):
            state.bindings.alertInfo = AlertInfo(id: .slidingSyncAlert,
                                                 title: L10n.commonServerNotSupported,
                                                 message: L10n.screenChangeServerErrorInvalidWellKnown(error))
        case .slidingSyncNotAvailable:
            let nonBreakingAppName = InfoPlistReader.main.bundleDisplayName.replacingOccurrences(of: " ", with: "\u{00A0}")
            state.bindings.alertInfo = AlertInfo(id: .slidingSyncAlert,
                                                 title: L10n.commonServerNotSupported,
                                                 message: L10n.screenChangeServerErrorNoSlidingSyncMessage(nonBreakingAppName))
        case .elementProRequired(let serverName):
            state.bindings.alertInfo = AlertInfo(id: .elementProAlert,
                                                 title: L10n.screenChangeServerErrorElementProRequiredTitle,
                                                 message: L10n.screenChangeServerErrorElementProRequiredMessage(serverName),
                                                 primaryButton: .init(title: L10n.screenChangeServerErrorElementProRequiredActionIos) {
                                                     UIApplication.shared.open(self.appSettings.elementProAppStoreURL)
                                                 },
                                                 secondaryButton: .init(title: L10n.actionCancel, role: .cancel, action: nil))
        case .accountDeactivated:
            state.bindings.alertInfo = AlertInfo(id: .alert("Account deactivated"),
                                                 title: L10n.commonError,
                                                 message: "This account has been deactivated.")
        case .sessionTokenRefreshNotSupported:
            state.bindings.alertInfo = AlertInfo(id: .alert("Session error"),
                                                 title: L10n.commonError,
                                                 message: "Session error occurred. Please try again.")
        case .failedUsingWebCredentials:
            state.bindings.alertInfo = AlertInfo(id: .alert("Web credentials failed"),
                                                 title: L10n.commonError,
                                                 message: "Failed to use web credentials. Please try again.")
        case .oidcError(let oidcError):
            state.bindings.alertInfo = AlertInfo(id: .alert("Authentication error"),
                                                 title: L10n.commonError,
                                                 message: "Authentication error: \(oidcError.localizedDescription)")
        case .qrCodeError(let qrError):
            state.bindings.alertInfo = AlertInfo(id: .alert("QR code error"),
                                                 title: L10n.commonError,
                                                 message: "QR code error: \(qrError.localizedDescription)")
        default:
            // For any unhandled errors, show a more helpful message
            MXLog.error("Unhandled registration error: \(error)")
            state.bindings.alertInfo = AlertInfo(id: .alert("Registration failed"),
                                                 title: L10n.commonError,
                                                 message: "An error occurred while creating your account. Please check your username and password, ensure the server is accessible, and try again.")
        }
    }
}


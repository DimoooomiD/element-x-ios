//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftState
import SwiftUI

@MainActor
protocol AuthenticationFlowCoordinatorDelegate: AnyObject {
    func authenticationFlowCoordinator(didLoginWithSession userSession: UserSessionProtocol)
}

class AuthenticationFlowCoordinator: FlowCoordinatorProtocol {
    private let authenticationService: AuthenticationServiceProtocol
    private let bugReportService: BugReportServiceProtocol
    private let navigationRootCoordinator: NavigationRootCoordinator
    private let navigationStackCoordinator: NavigationStackCoordinator
    private let appMediator: AppMediatorProtocol
    private let appSettings: AppSettings
    private let analytics: AnalyticsService
    private let userIndicatorController: UserIndicatorControllerProtocol
    
    enum State: StateType {
        /// The state machine hasn't started.
        case initial
        
        /// The initial screen shown when you first launch the app.
        case startScreen
        
        /// The screen used for the whole QR Code flow.
        case qrCodeLoginScreen
        
        /// The screen to continue authentication with the current server.
        case serverConfirmationScreen
        /// The screen to choose a different server.
        case serverSelectionScreen
        /// The web authentication session is being presented.
        case oidcAuthentication
        /// The screen to login with a password.
        case loginScreen
        /// The screen to register with a password.
        case registrationScreen
        
        /// The screen to report an error.
        case bugReportFlow
        
        /// The flow is complete.
        case complete
    }
    
    enum Event: EventType {
        /// The flow is being started.
        case start
        
        /// Modify the flow using the provisioning parameters in the `userInfo`.
        case applyProvisioningParameters
        
        /// The user would like to login with a QR code.
        case loginWithQR
        /// Show the server confirmation screen.
        case confirmServer(AuthenticationFlow)
        /// The user encountered a problem.
        case reportProblem
        
        /// The QR login flow was aborted.
        case cancelledLoginWithQR
        /// The user aborted manual login.
        case cancelledServerConfirmation
        
        /// The user would like to enter a different server.
        case changeServer(AuthenticationFlow)
        /// The user is no longer selecting a server.
        case dismissedServerSelection
        
        /// Show the web authentication session for OIDC (using the parameters in the `userInfo`).
        case continueWithOIDC
        /// The web authentication session was aborted.
        case cancelledOIDCAuthentication(previousState: State)
        /// Show the screen to login with password (with the optional login hint in the `userInfo`).
        case continueWithPassword
        /// The password login was aborted.
        case cancelledPasswordLogin(previousState: State)
        /// The password registration was aborted.
        case cancelledPasswordRegistration(previousState: State)
        
        /// The user has finished reporting a problem (or viewing the logs).
        case bugReportFlowComplete
        
        /// The user has successfully signed in. The new session can be found in the `userInfo`.
        case signedIn
    }
    
    private let stateMachine: StateMachine<State, Event>
    private var cancellables = Set<AnyCancellable>()
    
    private var oidcPresenter: OIDCAuthenticationPresenter?
    
    // periphery:ignore - retaining purpose
    private var bugReportFlowCoordinator: BugReportFlowCoordinator?
    
    weak var delegate: AuthenticationFlowCoordinatorDelegate?
    
    init(authenticationService: AuthenticationServiceProtocol,
         bugReportService: BugReportServiceProtocol,
         navigationRootCoordinator: NavigationRootCoordinator,
         appMediator: AppMediatorProtocol,
         appSettings: AppSettings,
         analytics: AnalyticsService,
         userIndicatorController: UserIndicatorControllerProtocol) {
        self.authenticationService = authenticationService
        self.bugReportService = bugReportService
        self.navigationRootCoordinator = navigationRootCoordinator
        self.appMediator = appMediator
        self.appSettings = appSettings
        self.analytics = analytics
        self.userIndicatorController = userIndicatorController
        
        navigationStackCoordinator = NavigationStackCoordinator()
        
        stateMachine = .init(state: .initial)
        configureStateMachine()
    }
    
    func start(animated: Bool) {
        stateMachine.tryEvent(.start)
    }
    
    func handleAppRoute(_ appRoute: AppRoute, animated: Bool) {
        switch appRoute {
        case .accountProvisioningLink(let provisioningParameters):
            guard appSettings.allowOtherAccountProviders else {
                MXLog.error("Provisioning links not allowed, ignoring.")
                return
            }
            
            if stateMachine.state != .startScreen {
                clearRoute(animated: animated)
            }
            
            stateMachine.tryEvent(.applyProvisioningParameters, userInfo: provisioningParameters)
        default:
            fatalError()
        }
    }
    
    func clearRoute(animated: Bool) {
        switch stateMachine.state {
        case .initial, .startScreen:
            break
        case .qrCodeLoginScreen:
            navigationStackCoordinator.setSheetCoordinator(nil)
            stateMachine.tryEvent(.cancelledLoginWithQR) // Needs to be handled manually.
        case .serverConfirmationScreen:
            navigationStackCoordinator.popToRoot(animated: animated)
        case .serverSelectionScreen:
            navigationStackCoordinator.setSheetCoordinator(nil)
            navigationStackCoordinator.popToRoot(animated: animated)
        case .oidcAuthentication:
            oidcPresenter?.cancel()
            navigationStackCoordinator.popToRoot(animated: animated)
        case .loginScreen:
            navigationStackCoordinator.popToRoot(animated: animated)
        case .registrationScreen:
            navigationStackCoordinator.popToRoot(animated: animated)
        case .bugReportFlow:
            navigationStackCoordinator.setSheetCoordinator(nil)
        case .complete:
            fatalError()
        }
    }
    
    // MARK: - Setup
    
    private func configureStateMachine() {
        stateMachine.addRoutes(event: .start, transitions: [.initial => .startScreen]) { [weak self] _ in
            self?.showStartScreen(fromState: .initial)
        }
        
        stateMachine.addRoutes(event: .applyProvisioningParameters, transitions: [.initial => .startScreen,
                                                                                  .startScreen => .startScreen]) { [weak self] context in
            guard let provisioningParameters = context.userInfo as? AccountProvisioningParameters else { fatalError("The authentication configuration is missing.") }
            self?.showStartScreen(fromState: context.fromState, applying: provisioningParameters)
        }
        
        // QR Code
        
        stateMachine.addRoutes(event: .loginWithQR, transitions: [.startScreen => .qrCodeLoginScreen]) { [weak self] _ in
            self?.showQRCodeLoginScreen()
        }
        stateMachine.addRoutes(event: .cancelledLoginWithQR, transitions: [.qrCodeLoginScreen => .startScreen])
        
        // Manual Authentication
        
        stateMachine.addRoutes(event: .confirmServer(.login), transitions: [.startScreen => .serverConfirmationScreen]) { [weak self] _ in
            self?.showServerConfirmationScreen(authenticationFlow: .login)
        }
        stateMachine.addRoutes(event: .confirmServer(.register), transitions: [.startScreen => .serverConfirmationScreen]) { [weak self] _ in
            self?.showServerConfirmationScreen(authenticationFlow: .register)
        }
        stateMachine.addRoutes(event: .cancelledServerConfirmation, transitions: [.serverConfirmationScreen => .startScreen])
        
        stateMachine.addRoutes(event: .changeServer(.login), transitions: [.serverConfirmationScreen => .serverSelectionScreen]) { [weak self] _ in
            self?.showServerSelectionScreen(authenticationFlow: .login)
        }
        stateMachine.addRoutes(event: .changeServer(.register), transitions: [.serverConfirmationScreen => .serverSelectionScreen]) { [weak self] _ in
            self?.showServerSelectionScreen(authenticationFlow: .register)
        }
        stateMachine.addRoutes(event: .dismissedServerSelection, transitions: [.serverSelectionScreen => .serverConfirmationScreen])
        
        stateMachine.addRoutes(event: .continueWithOIDC, transitions: [.serverConfirmationScreen => .oidcAuthentication,
                                                                       .startScreen => .oidcAuthentication]) { [weak self] context in
            guard let (oidcData, window) = context.userInfo as? (OIDCAuthorizationDataProxy, UIWindow) else {
                fatalError("Missing the OIDC data and presentation anchor.")
            }
            self?.showOIDCAuthentication(oidcData: oidcData, presentationAnchor: window, fromState: context.fromState)
        }
        stateMachine.addRoutes(event: .cancelledOIDCAuthentication(previousState: .serverConfirmationScreen), transitions: [.oidcAuthentication => .serverConfirmationScreen])
        stateMachine.addRoutes(event: .cancelledOIDCAuthentication(previousState: .startScreen), transitions: [.oidcAuthentication => .startScreen])
        
        // Use route mapping to dynamically determine the target state based on the flow
        // This must be used instead of addRoutes to avoid conflicts when multiple transitions are possible
        stateMachine.addRouteMapping { [weak self] event, fromState, _ in
            guard let self else { return nil }
            
            if case .continueWithPassword = event {
                let currentFlow = self.authenticationService.flow
                switch fromState {
                case .startScreen:
                    return currentFlow == .register ? .registrationScreen : .loginScreen
                case .serverConfirmationScreen:
                    return currentFlow == .register ? .registrationScreen : .loginScreen
                default:
                    return nil
                }
            }
            return nil
        } handler: { [weak self] context in
            let loginHint = context.userInfo as? String
            // Check the authentication flow to determine which screen to show
            guard let self else { return }
            let currentFlow = self.authenticationService.flow
            MXLog.info("continueWithPassword: current flow is \(currentFlow), fromState is \(context.fromState), toState is \(context.toState)")
            if currentFlow == .register {
                MXLog.info("Showing registration screen")
                self.showRegistrationScreen(fromState: context.fromState)
            } else {
                MXLog.info("Showing login screen")
                self.showLoginScreen(loginHint: loginHint, fromState: context.fromState)
            }
        }
        stateMachine.addRoutes(event: .cancelledPasswordLogin(previousState: .serverConfirmationScreen), transitions: [.loginScreen => .serverConfirmationScreen])
        stateMachine.addRoutes(event: .cancelledPasswordLogin(previousState: .startScreen), transitions: [.loginScreen => .startScreen])
        stateMachine.addRoutes(event: .cancelledPasswordRegistration(previousState: .serverConfirmationScreen), transitions: [.registrationScreen => .serverConfirmationScreen])
        stateMachine.addRoutes(event: .cancelledPasswordRegistration(previousState: .startScreen), transitions: [.registrationScreen => .startScreen])
        
        // Bug Report
        
        stateMachine.addRoutes(event: .reportProblem, transitions: [.startScreen => .bugReportFlow]) { [weak self] _ in
            self?.startBugReportFlow()
        }
        stateMachine.addRoutes(event: .bugReportFlowComplete, transitions: [.bugReportFlow => .startScreen])
        
        // Completion
        
        stateMachine.addRoutes(event: .signedIn, transitions: [.qrCodeLoginScreen => .complete,
                                                               .oidcAuthentication => .complete,
                                                               .loginScreen => .complete,
                                                               .registrationScreen => .complete]) { [weak self] context in
            guard let userSession = context.userInfo as? UserSessionProtocol else { fatalError("The user session wasn't included in the context") }
            self?.userHasSignedIn(userSession: userSession)
        }
        
        // Logging
        
        stateMachine.addAnyHandler(.any => .any) { context in
            MXLog.info("Transitioning from `\(context.fromState)` to `\(context.toState)` with event `\(String(describing: context.event))`.")
        }
        
        // Unhandled
        
        stateMachine.addErrorHandler { context in
            switch (context.fromState, context.toState) {
            case (.complete, .complete):
                break // Ignore all events triggered by
            default:
                fatalError("Unexpected transition: \(context)")
            }
        }
    }
    
    private func showStartScreen(fromState: State, applying provisioningParameters: AccountProvisioningParameters? = nil) {
        let parameters = AuthenticationStartScreenParameters(authenticationService: authenticationService,
                                                             provisioningParameters: provisioningParameters,
                                                             isBugReportServiceEnabled: bugReportService.isEnabled,
                                                             appSettings: appSettings,
                                                             userIndicatorController: userIndicatorController)
        let coordinator = AuthenticationStartScreenCoordinator(parameters: parameters)
        
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .loginWithQR:
                    stateMachine.tryEvent(.loginWithQR)
                case .login:
                    stateMachine.tryEvent(.confirmServer(.login))
                case .register:
                    stateMachine.tryEvent(.confirmServer(.register))
                case .reportProblem:
                    stateMachine.tryEvent(.reportProblem)
                    
                case .loginDirectlyWithOIDC(let oidcData, let window):
                    stateMachine.tryEvent(.continueWithOIDC, userInfo: (oidcData, window))
                case .loginDirectlyWithPassword(let loginHint):
                    stateMachine.tryEvent(.continueWithPassword, userInfo: loginHint)
                }
            }
            .store(in: &cancellables)
        
        navigationStackCoordinator.setRootCoordinator(coordinator)
        
        if fromState == .initial {
            navigationRootCoordinator.setRootCoordinator(navigationStackCoordinator)
        }
    }
    
    // MARK: - QR Code
    
    private func showQRCodeLoginScreen() {
        let coordinator = QRCodeLoginScreenCoordinator(parameters: .init(qrCodeLoginService: authenticationService,
                                                                         canSignInManually: appSettings.allowOtherAccountProviders, // No need to worry about provisioning links as we hide QR login.
                                                                         orientationManager: appMediator.windowManager,
                                                                         appMediator: appMediator))
        coordinator.actionsPublisher.sink { [weak self] action in
            guard let self else {
                return
            }
            switch action {
            case .signInManually:
                navigationStackCoordinator.setSheetCoordinator(nil)
                stateMachine.tryEvent(.cancelledLoginWithQR)
                stateMachine.tryEvent(.confirmServer(.login))
            case .cancel:
                navigationStackCoordinator.setSheetCoordinator(nil)
                stateMachine.tryEvent(.cancelledLoginWithQR)
            case .done(let userSession):
                navigationStackCoordinator.setSheetCoordinator(nil)
                // Since the qr code login flow includes verification
                appSettings.hasRunIdentityConfirmationOnboarding = true
                DispatchQueue.main.async {
                    self.stateMachine.tryEvent(.signedIn, userInfo: userSession)
                }
            }
        }
        .store(in: &cancellables)
        navigationStackCoordinator.setSheetCoordinator(coordinator) // Don't use the callback (interactive dismiss disabled), choose the event with the action.
    }
    
    // MARK: - Manual Authentication
    
    private func showServerConfirmationScreen(authenticationFlow: AuthenticationFlow) {
        let homeserver = authenticationService.homeserver.value
        let currentFlow = authenticationService.flow
        
        MXLog.info("showServerConfirmationScreen: flow=\(authenticationFlow), homeserver.loginMode=\(homeserver.loginMode), currentFlow=\(currentFlow)")
        
        // If server is already configured for this flow, skip the confirmation screen and proceed directly
        // However, if it was configured for a different flow, we need to reconfigure
        if homeserver.loginMode != .unknown && currentFlow == authenticationFlow {
            // Server is already configured for this flow, proceed directly
            MXLog.info("Server already configured for \(authenticationFlow), proceeding directly")
            Task {
                await proceedWithConfiguredServer(authenticationFlow: authenticationFlow, homeserver: homeserver)
            }
            return
        }
        
        // Reset the service back to the default homeserver before continuing. This ensures
        // we check that registration is supported if it was previously configured for login.
        // But don't reset if we're coming from automatic configuration - preserve the configured server
        if homeserver.loginMode == .unknown || currentFlow != authenticationFlow {
            MXLog.info("Resetting authentication service: loginMode=\(homeserver.loginMode), flow mismatch (\(currentFlow) != \(authenticationFlow))")
            authenticationService.reset()
        }
        
        let parameters = ServerConfirmationScreenCoordinatorParameters(authenticationService: authenticationService,
                                                                       authenticationFlow: authenticationFlow,
                                                                       appSettings: appSettings,
                                                                       userIndicatorController: userIndicatorController)
        let coordinator = ServerConfirmationScreenCoordinator(parameters: parameters)
        
        coordinator.actions.sink { [weak self] action in
            guard let self else { return }

            switch action {
            case .continueWithOIDC(let oidcData, let window):
                stateMachine.tryEvent(.continueWithOIDC, userInfo: (oidcData, window))
            case .continueWithPassword:
                stateMachine.tryEvent(.continueWithPassword)
            case .changeServer:
                stateMachine.tryEvent(.changeServer(authenticationFlow))
            }
        }
        .store(in: &cancellables)
        
        navigationStackCoordinator.push(coordinator) { [weak self] in
            self?.stateMachine.tryEvent(.cancelledServerConfirmation)
        }
    }
    
    private func proceedWithConfiguredServer(authenticationFlow: AuthenticationFlow, homeserver: LoginHomeserver) async {
        // Ensure the authentication service flow matches the requested flow
        // This is important when transitioning between login and registration
        if authenticationService.flow != authenticationFlow {
            // Flow mismatch - reconfigure if needed, but for now just proceed
            // The flow should already be set by configureAccountProviderForRegistration
            MXLog.warning("Flow mismatch: service flow is \(authenticationService.flow), requested flow is \(authenticationFlow)")
        }
        
        // For password-based authentication (login or registration), proceed directly
        if homeserver.loginMode == .password {
            stateMachine.tryEvent(.continueWithPassword)
            return
        }
        
        // For OIDC, check if it redirects to matrix.org and avoid it
        guard homeserver.loginMode.supportsOIDCFlow else {
            // No OIDC support and no password support - show error
            showServerConfirmationScreen(authenticationFlow: authenticationFlow)
            return
        }
        
        // For OIDC, we need a window to present the authentication
        let window = await MainActor.run {
            appMediator.windowManager.windows.first { $0.isKeyWindow } ?? appMediator.windowManager.windows.first
        }

        guard let window else {
            // Fallback: show server confirmation screen if we can't get the window
            showServerConfirmationScreen(authenticationFlow: authenticationFlow)
            return
        }
        
        switch await authenticationService.urlForOIDCLogin(loginHint: nil) {
        case .success(let oidcData):
            // Check if OIDC URL contains matrix.org - if so, use password registration instead
            let oidcURLString = oidcData.url.absoluteString
            if oidcURLString.contains("matrix.org") {
                // OIDC redirects to matrix.org, use password authentication instead if available
                if homeserver.loginMode == .password {
                    stateMachine.tryEvent(.continueWithPassword)
                } else {
                    // Can't use password, show error
                    showServerConfirmationScreen(authenticationFlow: authenticationFlow)
                }
            } else {
                // OIDC is for local server, proceed with OIDC
                stateMachine.tryEvent(.continueWithOIDC, userInfo: (oidcData, window))
            }
        case .failure:
            // If OIDC fails, fall back to password if available
            if homeserver.loginMode == .password {
                stateMachine.tryEvent(.continueWithPassword)
            } else {
                showServerConfirmationScreen(authenticationFlow: authenticationFlow)
            }
        }
    }
    
    private func showServerSelectionScreen(authenticationFlow: AuthenticationFlow) {
        let navigationCoordinator = NavigationStackCoordinator()
        
        let parameters = ServerSelectionScreenCoordinatorParameters(authenticationService: authenticationService,
                                                                    authenticationFlow: authenticationFlow,
                                                                    appSettings: appSettings,
                                                                    userIndicatorController: userIndicatorController)
        let coordinator = ServerSelectionScreenCoordinator(parameters: parameters)
        
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .updated:
                    navigationStackCoordinator.setSheetCoordinator(nil)
                case .dismiss:
                    navigationStackCoordinator.setSheetCoordinator(nil)
                }
            }
            .store(in: &cancellables)
        
        navigationCoordinator.setRootCoordinator(coordinator)
        navigationStackCoordinator.setSheetCoordinator(navigationCoordinator) { [weak self] in
            self?.stateMachine.tryEvent(.dismissedServerSelection)
        }
    }
    
    private func showOIDCAuthentication(oidcData: OIDCAuthorizationDataProxy, presentationAnchor: UIWindow, fromState: State) {
        let presenter = OIDCAuthenticationPresenter(authenticationService: authenticationService,
                                                    oidcRedirectURL: appSettings.oidcRedirectURL,
                                                    presentationAnchor: presentationAnchor,
                                                    userIndicatorController: userIndicatorController)
        oidcPresenter = presenter
        
        Task {
            switch await presenter.authenticate(using: oidcData) {
            case .success(let userSession):
                stateMachine.tryEvent(.signedIn, userInfo: userSession)
            case .failure:
                stateMachine.tryEvent(.cancelledOIDCAuthentication(previousState: fromState))
                // Nothing more to do, the alerts are handled by the presenter.
            }
            oidcPresenter = nil
        }
    }
    
    private func showLoginScreen(loginHint: String?, fromState: State) {
        let parameters = LoginScreenCoordinatorParameters(authenticationService: authenticationService,
                                                          loginHint: loginHint,
                                                          userIndicatorController: userIndicatorController,
                                                          appSettings: appSettings,
                                                          analytics: analytics)
        let coordinator = LoginScreenCoordinator(parameters: parameters)
        
        coordinator.actions
            .sink { [weak self] action in
                guard let self else { return }

                switch action {
                case .signedIn(let userSession):
                    stateMachine.tryEvent(.signedIn, userInfo: userSession)
                case .configuredForOIDC:
                    // Pop back to the confirmation screen for OIDC login to continue.
                    navigationStackCoordinator.pop(animated: false)
                }
            }
            .store(in: &cancellables)

        navigationStackCoordinator.push(coordinator) { [weak self] in
            guard let self else { return }
            // Safely handle back button - check current state before transitioning
            let currentState = self.stateMachine.state
            guard currentState == .loginScreen else {
                MXLog.warning("Back button pressed but state machine is in \(currentState), not .loginScreen. Ignoring.")
                return
            }
            
            // Try to transition based on fromState, with fallback to start screen
            let targetState: State = fromState == .startScreen ? .startScreen :
                (fromState == .serverConfirmationScreen ? .serverConfirmationScreen : .startScreen)

            let event: Event = targetState == .startScreen ?
                .cancelledPasswordLogin(previousState: .startScreen) :
                .cancelledPasswordLogin(previousState: .serverConfirmationScreen)
            
            // Try the transition - if it fails, the state machine will handle it gracefully
            self.stateMachine.tryEvent(event)
        }
    }
    
    private func showRegistrationScreen(fromState: State) {
        let parameters = RegistrationScreenCoordinatorParameters(authenticationService: authenticationService,
                                                                 userIndicatorController: userIndicatorController,
                                                                 appSettings: appSettings,
                                                                 analytics: analytics)
        let coordinator = RegistrationScreenCoordinator(parameters: parameters)
        
        coordinator.start()
        
        coordinator.actions
            .sink { [weak self] (action: RegistrationScreenCoordinatorAction) in
                guard let self else { return }

                switch action {
                case .signedIn(let userSession):
                    stateMachine.tryEvent(.signedIn, userInfo: userSession)
                }
            }
            .store(in: &cancellables)

        navigationStackCoordinator.push(coordinator) { [weak self] in
            guard let self else { return }
            // Safely handle back button - check current state before transitioning
            let currentState = self.stateMachine.state
            guard currentState == .registrationScreen else {
                MXLog.warning("Back button pressed but state machine is in \(currentState), not .registrationScreen. Ignoring.")
                return
            }
            
            // Try to transition based on fromState, with fallback to start screen
            let targetState: State = fromState == .startScreen ? .startScreen :
                (fromState == .serverConfirmationScreen ? .serverConfirmationScreen : .startScreen)

            let event: Event = targetState == .startScreen ?
                .cancelledPasswordRegistration(previousState: .startScreen) :
                .cancelledPasswordRegistration(previousState: .serverConfirmationScreen)
            
            // Try the transition - if it fails, the state machine will handle it gracefully
            self.stateMachine.tryEvent(event)
        }
    }
    
    // MARK: - Bug Report
    
    private func startBugReportFlow() {
        let coordinator = BugReportFlowCoordinator(parameters: .init(presentationMode: .sheet(navigationStackCoordinator),
                                                                     userIndicatorController: userIndicatorController,
                                                                     bugReportService: bugReportService,
                                                                     userSession: nil))
        coordinator.actionsPublisher.sink { [weak self] action in
            switch action {
            case .complete:
                self?.stateMachine.tryEvent(.bugReportFlowComplete)
            }
        }
        .store(in: &cancellables)
        
        bugReportFlowCoordinator = coordinator
        coordinator.start()
    }
    
    // MARK: - Completion

    private func userHasSignedIn(userSession: UserSessionProtocol) {
        delegate?.authenticationFlowCoordinator(didLoginWithSession: userSession)
    }
}

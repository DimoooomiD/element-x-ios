//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct RegistrationScreenCoordinatorParameters {
    /// The service used to authenticate the user.
    let authenticationService: AuthenticationServiceProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    let appSettings: AppSettings
    let analytics: AnalyticsService
}

enum RegistrationScreenCoordinatorAction {
    /// Registration was successful.
    case signedIn(UserSessionProtocol)
}

final class RegistrationScreenCoordinator: CoordinatorProtocol {
    private let parameters: RegistrationScreenCoordinatorParameters
    private var viewModel: RegistrationScreenViewModelProtocol
        
    private var authenticationService: AuthenticationServiceProtocol { parameters.authenticationService }

    private let actionsSubject: PassthroughSubject<RegistrationScreenCoordinatorAction, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    var actions: AnyPublisher<RegistrationScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Setup
    
    init(parameters: RegistrationScreenCoordinatorParameters) {
        self.parameters = parameters
        
        viewModel = RegistrationScreenViewModel(authenticationService: parameters.authenticationService,
                                            userIndicatorController: parameters.userIndicatorController,
                                            appSettings: parameters.appSettings,
                                            analytics: parameters.analytics)
    }
    
    // MARK: - Public

    func start() {
        viewModel.actions
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .signedIn(let userSession):
                    actionsSubject.send(.signedIn(userSession))
                }
            }
            .store(in: &cancellables)
    }

    func stop() {
        viewModel.stopLoading()
    }
    
    func toPresentable() -> AnyView {
        AnyView(RegistrationScreen(context: viewModel.context))
    }
}


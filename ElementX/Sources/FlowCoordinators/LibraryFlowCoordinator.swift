//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

enum LibraryFlowCoordinatorAction {
    case dismiss
}

class LibraryFlowCoordinator: FlowCoordinatorProtocol {
    private let navigationStackCoordinator: NavigationStackCoordinator
    private let flowParameters: CommonFlowParameters
    
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject: PassthroughSubject<LibraryFlowCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<LibraryFlowCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(navigationStackCoordinator: NavigationStackCoordinator,
         flowParameters: CommonFlowParameters) {
        self.navigationStackCoordinator = navigationStackCoordinator
        self.flowParameters = flowParameters
    }
    
    func start(animated: Bool) {
        // If library screen is not already presented, present it
        if navigationStackCoordinator.rootCoordinator == nil {
            presentLibraryScreen(animated: animated)
        }
    }
    
    func handleAppRoute(_ appRoute: AppRoute, animated: Bool) {
        // Handle library-specific routes if needed
    }
    
    func clearRoute(animated: Bool) {
        fatalError("Unavailable")
    }
    
    // MARK: - Private
    
    private func presentLibraryScreen(animated: Bool) {
        let libraryScreenCoordinator = LibraryScreenCoordinator(parameters: .init())
        
        libraryScreenCoordinator.actions
            .sink { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .dismiss:
                    actionsSubject.send(.dismiss)
                }
            }
            .store(in: &cancellables)
        
        libraryScreenCoordinator.start()
        navigationStackCoordinator.setRootCoordinator(libraryScreenCoordinator, animated: animated)
    }
}


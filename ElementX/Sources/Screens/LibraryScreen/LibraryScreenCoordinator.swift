//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

struct LibraryScreenCoordinatorParameters {
    // Add parameters as needed
}

enum LibraryScreenCoordinatorAction {
    case dismiss
}

final class LibraryScreenCoordinator: CoordinatorProtocol {
    private let parameters: LibraryScreenCoordinatorParameters
    private var viewModel: LibraryScreenViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let actionsSubject: PassthroughSubject<LibraryScreenCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<LibraryScreenCoordinatorAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }
    
    init(parameters: LibraryScreenCoordinatorParameters) {
        self.parameters = parameters
        viewModel = LibraryScreenViewModel()
    }
    
    func start() {
        viewModel.actions.sink { [weak self] action in
            MXLog.info("Coordinator: received view model action: \(action)")
            
            guard let self else { return }
            switch action {
            case .dismiss:
                self.actionsSubject.send(.dismiss)
            case .purchaseInitiated(let packageId):
                MXLog.info("Purchase initiated for package: \(packageId)")
                // Handle purchase logic here
            }
        }
        .store(in: &cancellables)
    }
        
    func toPresentable() -> AnyView {
        AnyView(LibraryScreen(context: viewModel.context))
    }
}


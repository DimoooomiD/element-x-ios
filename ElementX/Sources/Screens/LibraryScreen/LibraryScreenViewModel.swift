//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import SwiftUI

typealias LibraryScreenViewModelType = StateStoreViewModelV2<LibraryScreenViewState, LibraryScreenViewAction>

class LibraryScreenViewModel: LibraryScreenViewModelType, LibraryScreenViewModelProtocol {
    private var actionsSubject: PassthroughSubject<LibraryScreenViewModelAction, Never> = .init()
    
    var actions: AnyPublisher<LibraryScreenViewModelAction, Never> {
        actionsSubject.eraseToAnyPublisher()
    }

    init() {
        super.init(initialViewState: LibraryScreenViewState())
    }
    
    // MARK: - Public
    
    override func process(viewAction: LibraryScreenViewAction) {
        MXLog.info("View model: received view action: \(viewAction)")
        
        switch viewAction {
        case .dismiss:
            actionsSubject.send(.dismiss)
        case .purchasePackage(let packageId):
            actionsSubject.send(.purchaseInitiated(packageId: packageId))
        }
    }
}


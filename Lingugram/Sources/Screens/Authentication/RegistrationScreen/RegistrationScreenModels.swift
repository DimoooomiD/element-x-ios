//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum RegistrationScreenViewModelAction {
    /// Registration was successful.
    case signedIn(UserSessionProtocol)
}

struct RegistrationScreenViewState: BindableState {
    /// Data about the selected homeserver.
    var homeserver: LoginHomeserver
    /// Whether a new homeserver is currently being loaded.
    var isLoading = false
    /// View state that can be bound to from SwiftUI.
    var bindings = RegistrationScreenBindings()
    
    /// The types of login supported by the homeserver.
    var loginMode: LoginMode { homeserver.loginMode }
    
    /// `true` if the username and password are ready to be submitted.
    var hasValidCredentials: Bool {
        !bindings.username.isEmpty && !bindings.password.isEmpty && !bindings.passwordConfirm.isEmpty && bindings.password == bindings.passwordConfirm
    }
    
    /// `true` when valid credentials have been entered and a homeserver has been loaded.
    var canSubmit: Bool {
        hasValidCredentials && !isLoading
    }
}

struct RegistrationScreenBindings {
    /// The username input by the user.
    var username = ""
    /// The password input by the user.
    var password = ""
    /// The password confirmation input by the user.
    var passwordConfirm = ""
    /// Information describing the currently displayed alert.
    var alertInfo: AlertInfo<RegistrationScreenErrorType>?
}

enum RegistrationScreenViewAction {
    /// Continue using the input username and password.
    case next
}

enum RegistrationScreenErrorType: Hashable {
    /// A specific error message shown in an alert.
    case alert(String)
    /// An alert that informs the user to check their username/password.
    case credentialsAlert
    /// An alert that informs the user about a bad well-known file.
    case invalidWellKnownAlert(String)
    /// An alert that allows the user to learn about sliding sync.
    case slidingSyncAlert
    /// An alert that informs the user that Element Pro should be used for a particular server.
    case elementProAlert
    /// The response from the homeserver was unexpected.
    case unknown
}


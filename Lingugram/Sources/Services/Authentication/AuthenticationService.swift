//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation
import MatrixRustSDK
import UIKit

class AuthenticationService: AuthenticationServiceProtocol {
    private var client: ClientProtocol?
    private var sessionDirectories: SessionDirectories
    private let passphrase: String
    
    private let clientFactory: AuthenticationClientFactoryProtocol
    private let userSessionStore: UserSessionStoreProtocol
    private let appSettings: AppSettings
    private let appHooks: AppHooks
    
    private let homeserverSubject: CurrentValueSubject<LoginHomeserver, Never>
    var homeserver: CurrentValuePublisher<LoginHomeserver, Never> { homeserverSubject.asCurrentValuePublisher() }
    private(set) var flow: AuthenticationFlow
    
    private let qrLoginProgressSubject = PassthroughSubject<QrLoginProgress, Never>()
    var qrLoginProgressPublisher: AnyPublisher<QrLoginProgress, Never> {
        qrLoginProgressSubject.eraseToAnyPublisher()
    }
    
    init(userSessionStore: UserSessionStoreProtocol,
         encryptionKeyProvider: EncryptionKeyProviderProtocol,
         clientFactory: AuthenticationClientFactoryProtocol = AuthenticationClientFactory(),
         appSettings: AppSettings,
         appHooks: AppHooks) {
        sessionDirectories = .init()
        passphrase = encryptionKeyProvider.generateKey().base64EncodedString()
        self.clientFactory = clientFactory
        self.userSessionStore = userSessionStore
        self.appSettings = appSettings
        self.appHooks = appHooks
        
        // When updating these, don't forget to update the reset method too.
        homeserverSubject = .init(LoginHomeserver(address: appSettings.accountProviders[0], loginMode: .unknown))
        flow = .login
    }
    
    // MARK: - Public
    
    func configure(for homeserverAddress: String, flow: AuthenticationFlow) async -> Result<Void, AuthenticationServiceError> {
        do {
            var homeserver = LoginHomeserver(address: homeserverAddress, loginMode: .unknown)
            
            let client = try await makeClient(homeserverAddress: homeserverAddress)
            let loginDetails = await client.homeserverLoginDetails()
            
            homeserver.loginMode = if loginDetails.supportsOidcLogin() {
                .oidc(supportsCreatePrompt: loginDetails.supportedOidcPrompts().contains(.create))
            } else if loginDetails.supportsPasswordLogin() {
                .password
            } else {
                .unsupported
            }
            
            if flow == .login, homeserver.loginMode == .unsupported {
                return .failure(.loginNotSupported)
            }
            // Allow password-based registration for local servers
            // Only require OIDC if the server explicitly doesn't support password registration
            if flow == .register, homeserver.loginMode == .unsupported {
                return .failure(.registrationNotSupported)
            }
            
            self.client = client
            self.flow = flow
            homeserverSubject.send(homeserver)
            return .success(())
        } catch ClientBuildError.WellKnownDeserializationError(let error) {
            MXLog.error("The user entered a server with an invalid well-known file: \(error)")
            return .failure(.invalidWellKnown(error))
        } catch ClientBuildError.SlidingSyncVersion(let error) {
            MXLog.info("User entered a homeserver that isn't configured for sliding sync: \(error)")
            return .failure(.slidingSyncNotAvailable)
        } catch RemoteSettingsError.elementProRequired(let serverName) {
            return .failure(.elementProRequired(serverName: serverName))
        } catch {
            MXLog.error("Failed configuring a server: \(error)")
            return .failure(.invalidHomeserverAddress)
        }
    }
    
    func urlForOIDCLogin(loginHint: String?) async -> Result<OIDCAuthorizationDataProxy, AuthenticationServiceError> {
        guard let client else { return .failure(.oidcError(.urlFailure)) }
        do {
            // The create prompt is broken: https://github.com/element-hq/matrix-authentication-service/issues/3429
            // let prompt: OidcPrompt = flow == .register ? .create : .consent
            let oidcData = try await client.urlForOidc(oidcConfiguration: appSettings.oidcConfiguration.rustValue,
                                                       prompt: .consent,
                                                       loginHint: loginHint,
                                                       deviceId: nil,
                                                       additionalScopes: nil)
            return .success(OIDCAuthorizationDataProxy(underlyingData: oidcData))
        } catch {
            MXLog.error("Failed to get URL for OIDC login: \(error)")
            return .failure(.oidcError(.urlFailure))
        }
    }
    
    func abortOIDCLogin(data: OIDCAuthorizationDataProxy) async {
        guard let client else { return }
        MXLog.info("Aborting OIDC login.")
        await client.abortOidcAuth(authorizationData: data.underlyingData)
    }
    
    func loginWithOIDCCallback(_ callbackURL: URL) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        guard let client else { return .failure(.failedLoggingIn) }
        do {
            try await client.loginWithOidcCallback(callbackUrl: callbackURL.absoluteString)
            return await userSession(for: client)
        } catch OidcError.Cancelled {
            return .failure(.oidcError(.userCancellation))
        } catch {
            MXLog.error("Login with OIDC failed: \(error)")
            return .failure(.failedLoggingIn)
        }
    }
    
    func login(username: String, password: String, initialDeviceName: String?, deviceID: String?) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        guard let client else { return .failure(.failedLoggingIn) }
        do {
            try await client.login(username: username, password: password, initialDeviceName: initialDeviceName, deviceId: deviceID)
            
            let refreshToken = try? client.session().refreshToken
            if refreshToken != nil {
                MXLog.warning("Refresh token found for a non oidc session, can't restore session, logging out")
                _ = try? await client.logout()
                return .failure(.sessionTokenRefreshNotSupported)
            }
            
            return await userSession(for: client)
        } catch let ClientError.MatrixApi(errorKind, _, _, _) {
            MXLog.error("Failed logging in with error kind: \(errorKind)")
            switch errorKind {
            case .forbidden:
                return .failure(.invalidCredentials)
            case .userDeactivated:
                return .failure(.accountDeactivated)
            default:
                return .failure(.failedLoggingIn)
            }
        } catch {
            MXLog.error("Failed logging in with error: \(error)")
            return .failure(.failedLoggingIn)
        }
    }
    
    func register(username: String, password: String, initialDeviceName: String?) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        guard let client else {
            MXLog.error("Registration failed: client is nil")
            return .failure(.failedLoggingIn)
        }
        
        // Get the homeserver URL for making the registration request
        let homeserverURL = client.homeserver()
        MXLog.info("Registration: Using homeserver URL: \(homeserverURL)")
        MXLog.info("Registration: Username: \(username)")
        
        // Make a direct HTTP POST request to the Matrix /register endpoint
        let registerURL = URL(string: homeserverURL)?.appending(path: "/_matrix/client/v3/register")
        guard let registerURL = registerURL else {
            MXLog.error("Failed to construct registration URL from: \(homeserverURL)")
            return .failure(.invalidHomeserverAddress)
        }
        
        MXLog.info("Registration: Full URL: \(registerURL.absoluteString)")
        
        // Perform the registration request with two-step flow if needed
        do {
            // Step 1: Get registration session (some servers require this)
            MXLog.info("Registration: Step 1 - Getting registration session...")
            var sessionPayload: [String: Any] = [
                "username": username,
                "password": password,
                "initial_device_display_name": initialDeviceName ?? UIDevice.current.name
            ]
            
            var sessionRequest = URLRequest(url: registerURL)
            sessionRequest.httpMethod = "POST"
            sessionRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            sessionRequest.httpBody = try JSONSerialization.data(withJSONObject: sessionPayload)
            
            let (sessionData, sessionResponse) = try await URLSession.shared.data(for: sessionRequest)
            
            guard let sessionHttpResponse = sessionResponse as? HTTPURLResponse else {
                MXLog.error("Registration: Invalid response type")
                return .failure(.failedLoggingIn)
            }
            
            MXLog.info("Registration: Step 1 response status: \(sessionHttpResponse.statusCode)")
            
            // Check if we need to complete the registration flow
            if sessionHttpResponse.statusCode == 401 {
                // Server requires authentication flow (e.g., m.login.dummy)
                MXLog.info("Registration: Server requires authentication flow")
                
                guard let sessionJson = try? JSONSerialization.jsonObject(with: sessionData) as? [String: Any],
                      let session = sessionJson["session"] as? String else {
                    MXLog.error("Registration: Failed to get session from 401 response")
                    if let responseString = String(data: sessionData, encoding: .utf8) {
                        MXLog.error("Registration: Response: \(responseString)")
                    }
                    return handleRegistrationError(data: sessionData, statusCode: sessionHttpResponse.statusCode)
                }
                
                MXLog.info("Registration: Got session: \(session)")
                
                // Step 2: Complete registration with session and dummy auth
                var finalPayload: [String: Any] = [
                    "username": username,
                    "password": password,
                    "initial_device_display_name": initialDeviceName ?? UIDevice.current.name,
                    "auth": [
                        "type": "m.login.dummy",
                        "session": session
                    ]
                ]
                
                var finalRequest = URLRequest(url: registerURL)
                finalRequest.httpMethod = "POST"
                finalRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                finalRequest.httpBody = try JSONSerialization.data(withJSONObject: finalPayload)
                
                MXLog.info("Registration: Step 2 - Completing registration with session...")
                let (finalData, finalResponse) = try await URLSession.shared.data(for: finalRequest)
                
                guard let finalHttpResponse = finalResponse as? HTTPURLResponse else {
                    MXLog.error("Registration: Invalid response type in step 2")
                    return .failure(.failedLoggingIn)
                }
                
                MXLog.info("Registration: Step 2 response status: \(finalHttpResponse.statusCode)")
                
                if let responseString = String(data: finalData, encoding: .utf8) {
                    MXLog.info("Registration: Step 2 response body: \(responseString)")
                }
                
                if finalHttpResponse.statusCode == 200 || finalHttpResponse.statusCode == 201 {
                    MXLog.info("Registration: Success! Status code: \(finalHttpResponse.statusCode)")
                    return await handleSuccessfulRegistration(data: finalData, username: username, password: password, initialDeviceName: initialDeviceName)
                } else {
                    MXLog.error("Registration: Step 2 failed with status code: \(finalHttpResponse.statusCode)")
                    return handleRegistrationError(data: finalData, statusCode: finalHttpResponse.statusCode)
                }
            } else if sessionHttpResponse.statusCode == 200 || sessionHttpResponse.statusCode == 201 {
                // Direct registration succeeded (no auth flow required)
                MXLog.info("Registration: Direct registration succeeded! Status code: \(sessionHttpResponse.statusCode)")
                if let responseString = String(data: sessionData, encoding: .utf8) {
                    MXLog.info("Registration: Response body: \(responseString)")
                }
                return await handleSuccessfulRegistration(data: sessionData, username: username, password: password, initialDeviceName: initialDeviceName)
            } else {
                // Registration failed
                MXLog.error("Registration: Failed with status code: \(sessionHttpResponse.statusCode)")
                if let responseString = String(data: sessionData, encoding: .utf8) {
                    MXLog.error("Registration: Response: \(responseString)")
                }
                return handleRegistrationError(data: sessionData, statusCode: sessionHttpResponse.statusCode)
            }
        } catch let urlError as URLError {
            return handleRegistrationNetworkError(urlError)
        } catch {
            MXLog.error("Failed to register: \(error)")
            return .failure(.failedLoggingIn)
        }
    }
    
    private func handleSuccessfulRegistration(data: Data, username: String, password: String, initialDeviceName: String?) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        let userID = json?["user_id"] as? String
        let deviceID = json?["device_id"] as? String
        
        MXLog.info("Registration successful for user: \(userID ?? "unknown")")
        
        // Extract the localpart (username without @ and server) from user_id if available
        let loginUsername = extractLocalpart(from: userID, fallback: username)
        MXLog.info("Using username for login: \(loginUsername)")
        
        // Add a small delay to ensure the server has processed the registration
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Retry login up to 3 times in case the server needs a moment to process the registration
        var lastError: Error?
        for attempt in 1...3 {
            MXLog.info("Attempting login after registration (attempt \(attempt)/3) with username: \(loginUsername)")
            let loginResult = await login(username: loginUsername, password: password, initialDeviceName: initialDeviceName, deviceID: deviceID)
            
            switch loginResult {
            case .success:
                MXLog.info("Login successful after registration")
                return loginResult
            case .failure(let error):
                lastError = error
                MXLog.warning("Login attempt \(attempt) failed: \(error)")
                if attempt < 3 {
                    let delay = UInt64(attempt) * 1_000_000_000 // 1, 2, 3 seconds
                    MXLog.info("Waiting \(attempt) second(s) before retry...")
                    try? await Task.sleep(nanoseconds: delay)
                }
            }
        }
        
        MXLog.error("Login failed after registration after 3 attempts: \(String(describing: lastError))")
        if let lastError = lastError as? AuthenticationServiceError {
            return .failure(lastError)
        }
        return .failure(.failedLoggingIn)
    }
    
    private func extractLocalpart(from userID: String?, fallback: String) -> String {
        guard let userID = userID, userID.hasPrefix("@") else {
            return fallback
        }
        
        if let colonIndex = userID.firstIndex(of: ":") {
            return String(userID[userID.index(after: userID.startIndex)..<colonIndex])
        } else {
            return String(userID.dropFirst()) // Remove @
        }
    }
    
    private func handleRegistrationError(data: Data, statusCode: Int) -> Result<UserSessionProtocol, AuthenticationServiceError> {
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
        MXLog.error("Registration failed with status \(statusCode): \(errorMessage)")
        
        // Try to parse the error response for more specific error information
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let errcode = json["errcode"] as? String {
            MXLog.error("Registration error code: \(errcode)")
            
            switch errcode {
            case "M_USER_IN_USE":
                return .failure(.invalidCredentials) // Username already taken
            case "M_FORBIDDEN":
                return .failure(.registrationNotSupported) // Registration disabled
            case "M_INVALID_USERNAME":
                return .failure(.invalidCredentials) // Invalid username format
            case "M_WEAK_PASSWORD":
                return .failure(.invalidCredentials) // Password too weak
            default:
                MXLog.error("Unknown error code: \(errcode)")
            }
        }
        
        // Map HTTP status codes to appropriate errors
        switch statusCode {
        case 400:
            return .failure(.invalidCredentials) // Bad request - likely invalid input
        case 403:
            return .failure(.registrationNotSupported) // Forbidden - registration disabled
        case 429:
            return .failure(.failedLoggingIn) // Rate limited
        case 500...599:
            return .failure(.failedLoggingIn) // Server error
        default:
            return .failure(.failedLoggingIn)
        }
    }
    
    private func handleRegistrationNetworkError(_ urlError: URLError) -> Result<UserSessionProtocol, AuthenticationServiceError> {
        MXLog.error("Network error during registration: \(urlError)")
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .failure(.invalidHomeserverAddress) // Network issue
        case .timedOut:
            return .failure(.invalidHomeserverAddress) // Timeout
        default:
            return .failure(.failedLoggingIn)
        }
    }
    
    func loginWithQRCode(data: Data) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        let qrData: QrCodeData
        do {
            qrData = try QrCodeData.fromBytes(bytes: data)
        } catch {
            MXLog.error("QRCode decode error: \(error)")
            return .failure(.qrCodeError(.invalidQRCode))
        }
        
        guard let scannedServerName = qrData.serverName() else {
            MXLog.error("The QR code is from a device that is not yet signed in.")
            return .failure(.qrCodeError(.deviceNotSignedIn))
        }
        
        if !appSettings.allowOtherAccountProviders, !appSettings.accountProviders.contains(scannedServerName) {
            MXLog.error("The scanned device's server is not allowed: \(scannedServerName)")
            return .failure(.qrCodeError(.providerNotAllowed(scannedProvider: scannedServerName, allowedProviders: appSettings.accountProviders)))
        }
        
        let listener = SDKListener { [weak self] progress in
            self?.qrLoginProgressSubject.send(progress)
        }
        
        do {
            let client = try await makeClient(homeserverAddress: scannedServerName)
            let qrCodeHandler = client.loginWithQrCode(oidcConfiguration: appSettings.oidcConfiguration.rustValue)
            try await qrCodeHandler.scan(qrCodeData: qrData, progressListener: listener)
            return await userSession(for: client)
        } catch let error as HumanQrLoginError {
            MXLog.error("QRCode login error: \(error)")
            return .failure(error.serviceError)
        } catch RemoteSettingsError.elementProRequired(let serverName) {
            return .failure(.elementProRequired(serverName: serverName))
        } catch {
            MXLog.error("QRCode login unknown error: \(error)")
            return .failure(.qrCodeError(.unknown))
        }
    }
    
    func reset() {
        homeserverSubject.send(LoginHomeserver(address: appSettings.accountProviders[0], loginMode: .unknown))
        flow = .login
        client = nil
    }
    
    // MARK: - Private
    
    private func makeClient(homeserverAddress: String) async throws -> ClientProtocol {
        // Use a fresh session directory each time the user enters a different server
        // so that caches (e.g. server versions) are always fresh for the new server.
        rotateSessionDirectory()
        
        let client = try await clientFactory.makeClient(homeserverAddress: homeserverAddress,
                                                        sessionDirectories: sessionDirectories,
                                                        passphrase: passphrase,
                                                        clientSessionDelegate: userSessionStore.clientSessionDelegate,
                                                        appSettings: appSettings,
                                                        appHooks: appHooks)
        try await appHooks.remoteSettingsHook.initializeCache(using: client, applyingTo: appSettings).get()
        
        return client
    }
    
    private func rotateSessionDirectory() {
        sessionDirectories.delete()
        sessionDirectories = .init()
    }
    
    private func userSession(for client: ClientProtocol) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        switch await userSessionStore.userSession(for: client, sessionDirectories: sessionDirectories, passphrase: passphrase) {
        case .success(let clientProxy):
            return .success(clientProxy)
        case .failure:
            return .failure(.failedLoggingIn)
        }
    }
}

private extension HumanQrLoginError {
    var serviceError: AuthenticationServiceError {
        switch self {
        case .Cancelled:
            .qrCodeError(.cancelled)
        case .ConnectionInsecure:
            .qrCodeError(.connectionInsecure)
        case .Declined:
            .qrCodeError(.declined)
        case .LinkingNotSupported:
            .qrCodeError(.linkingNotSupported)
        case .Expired:
            .qrCodeError(.expired)
        case .SlidingSyncNotAvailable:
            .qrCodeError(.deviceNotSupported)
        case .OtherDeviceNotSignedIn:
            .qrCodeError(.deviceNotSignedIn)
        case .Unknown, .OidcMetadataInvalid, .CheckCodeAlreadySent, .CheckCodeCannotBeSent:
            .qrCodeError(.unknown)
        }
    }
}

// MARK: - Mocks

extension AuthenticationService {
    static var mock: AuthenticationService {
        AuthenticationService(userSessionStore: UserSessionStoreMock(configuration: .init()),
                              encryptionKeyProvider: EncryptionKeyProvider(),
                              clientFactory: AuthenticationClientFactoryMock(configuration: .init()),
                              appSettings: ServiceLocator.shared.settings,
                              appHooks: AppHooks())
    }
}

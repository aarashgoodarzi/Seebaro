//
//  LoginViewModel.swift
//  Sibaro
//
//  Created by Ebrahim Tahernejad on 5/25/1402 AP.
//

import Foundation
import Combine
import OneSignalFramework

extension LoginView {

    @MainActor
    class ViewModel: BaseViewModel {

        @Injected(\.authRepository) var auth

        @Injected(\.storage) var storage

        @Published var username: String = "" {
            didSet {
                updateLoginButtonState()
            }
        }

        @Published var password: String = "" {
            didSet {
                updateLoginButtonState()
            }
        }

        @Published var loading: Bool = false

        @Published var message: String = ""

        @Published var isLoginButtonDisabled = true

        // MARK: Login
        nonisolated func login() {
            Task {
                await _login()
            }
        }

        private func _login() async {
            loading = true
            isLoginButtonDisabled = true
            message = ""

            do {
                let response = try await auth.login(username: username, password: password)
                OneSignal.login(externalId: "\(response.userId)", token: response.access)
                storage.token = response.access
                storage.username = username
                loading = false
                isLoginButtonDisabled = false
            } catch {
                handle(error)
                loading = false
                isLoginButtonDisabled = false
            }
        }

        // MARK: handle error
        private func handle(_ error: Error) {
            guard let error = error as? RequestError else {
                message = error.localizedDescription
                return
            }
            switch error {
            case .unauthorized(let data):
                let decodedResponse = try? JSONDecoder().decode(LoginMessage.self, from: data)
                message = decodedResponse?.detail ?? ""
            default:
                message = error.description
            }
        }

        // MARK: updateLoginButtonState
        private func updateLoginButtonState() {
            guard loading == false else {
                self.isLoginButtonDisabled = true
                return
            }
            let isDisabled = username.isEmpty || password.isEmpty
            self.isLoginButtonDisabled = isDisabled
        }
    }
}

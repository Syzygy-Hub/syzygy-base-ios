//
//  LoginView.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 27/07/26.
//

import SwiftUI

struct LoginView: View {

    @State private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header

                        formFields
                            .padding(.horizontal, 24)

                        Spacer(minLength: 0)
                    }
                }
                .dismissKeyboardOnTap()
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .errorAlert(error: $viewModel.error)
            .navigationDestination(isPresented: Binding(
                get: { viewModel.isAuthenticated },
                set: { isPresented in
                    if !isPresented { Task { await viewModel.logout() } }
                }
            )) {
                HomeView(user: viewModel.currentUser) {
                    Task { await viewModel.logout() }
                }
            }
            .task {
                await viewModel.checkAuthenticationStatus()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.primary)

            Text("Welcome Back")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.text)

            Text("Sign in to continue")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.top, 60)
    }

    // MARK: - Form

    private var formFields: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.secondaryText)

                TextField("Enter your email", text: $viewModel.email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .disabled(viewModel.isLoading)
                    .onSubmit { focusedField = .password }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.secondaryText)

                SecureField("Enter your password", text: $viewModel.password)
                    .textFieldStyle(CustomTextFieldStyle())
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .disabled(viewModel.isLoading)
                    .onSubmit(submit)
            }

            signInButton
                .padding(.top, 8)
        }
    }

    private var signInButton: some View {
        Button(action: submit) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                        .font(AppFonts.button)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isFormValid ? AppColors.primary : AppColors.disabled)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }

    private func submit() {
        focusedField = nil
        Task { await viewModel.login() }
    }
}

// MARK: - Custom Text Field Style

private struct CustomTextFieldStyle: TextFieldStyle {
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: AppDependencies.makeLoginViewModel())
}

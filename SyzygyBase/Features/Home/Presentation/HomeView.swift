//
//  HomeView.swift
//  SyzygyBase
//
//  Created by Ayush Kumar Sethi on 30/07/26.
//

import SwiftUI

/// Landing screen shown after a successful login. Intentionally minimal — replace
/// with a real feature (own Domain/Data/Presentation layers) as the app grows.
struct HomeView: View {

    let user: User?
    let onLogout: () -> Void

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.success)

                Text("Welcome\(user.map { ", \($0.name)" } ?? "")!")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.text)
                    .multilineTextAlignment(.center)

                if let email = user?.email {
                    Text(email)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

                logoutButton
                    .padding(.top, 24)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private var logoutButton: some View {
        Button(action: onLogout) {
            Text("Log Out")
                .font(AppFonts.button)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.surface)
                .foregroundStyle(AppColors.error)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(user: User(id: "1", email: "jane@example.com", name: "Jane"), onLogout: {})
    }
}

//
//  AuthView.swift
//  PiKa
//
//  Created by Naveen on 25/04/26.
//

import SwiftUI

struct AuthView: View {
    
    @StateObject var viewModel = AuthViewModel()
    @StateObject private var videoManager = VideoPlayerManager()
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Video
            BackgroundVideoView(player: videoManager.player)
                .ignoresSafeArea()
            AppGradients.onboardingOverlay
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                // Title
                Text(NSLocalizedString("login_title", comment: ""))
                    .font(AppFonts.heavy(size: 30))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Subtitle
                Text(NSLocalizedString("login_subtitle", comment: ""))
                    .font(AppFonts.regular(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                // Phone Field
                HStack(spacing: 8) {
                    Text("+91")
                        .foregroundStyle(AppColors.textPrimary)
                        .font(AppFonts.regular(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                    
                    TextField(
                        NSLocalizedString("phone_placeholder", comment: ""),
                        text: $viewModel.phoneNumber
                    )
                    .keyboardType(.phonePad)
                    .font(AppFonts.regular(size: 14))
                }
                .padding(6)
                .frame(height: 50)
                .background(AppColors.backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border.opacity(0.5))
                )
                
                // Continue Button
                Button(action: {
                    viewModel.onContinueTapped()
                }) {
                    Text(NSLocalizedString("continue", comment: ""))
                        .font(AppFonts.bold(size: 16))
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(AppColors.themeColor.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text(NSLocalizedString("or_continue", comment: ""))
                        .font(AppFonts.regular(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }
                
                // Social Buttons
                HStack(spacing: 30) {
                    Image("google_login").frame(width: 60, height: 60)
                    Image("mail_login").frame(width: 60, height: 60)
                }
                
                Spacer()
                    .frame(height: 4)
                
                TermsText()
            }
            .padding()
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            videoManager.play()
        }
        .onDisappear {
            videoManager.pause()
        }
    }
}

struct AppGradients {
    
    static var onboardingOverlay: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.white.opacity(0.0), location: 0.0),
                .init(color: Color.white.opacity(0.4), location: 0.4),
                .init(color: Color.white.opacity(0.85), location: 0.7),
                .init(color: Color.white.opacity(1.0), location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct TermsText: View {
    
    var body: some View {
        HStack(spacing: 0) {
            
            Text("Sign in to agree to ")
                .font(AppFonts.regular(size: 14))
                .foregroundColor(AppColors.textSecondary)
            
            Text("terms")
                .font(AppFonts.bold(size: 14))
                .foregroundColor(AppColors.textSecondary)
                .onTapGesture {
                    print("Terms tapped")
                }
        }
    }
}

#Preview {
     AuthView()
}

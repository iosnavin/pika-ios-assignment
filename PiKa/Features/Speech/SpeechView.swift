//
//  SpeechView.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import SwiftUI

struct SpeechView: View {

    @ObservedObject var coordinator: AuthCoordinator
    @StateObject var viewModel: SpeechViewModel
    var onNext: (() -> Void)?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 0.93),
                    Color(red: 0.90, green: 0.89, blue: 0.87)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack {
                Spacer()
                
                titleSection
                
                Spacer()
                
                textSection
                
                Spacer()
                
                bottomControls
            }
            .padding()
        }
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            if isCompleted {
                onNext?()
            }
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                ProgressView(value: viewModel.progress)
                    .tint(AppColors.themeColor)
                    .frame(width: 120)
            }
        }
    }
}

private extension SpeechView {

    var titleSection: some View {
        VStack(spacing: 12) {
            Text("MAKE YOUR AI SELF SOUND LIKE YOU")
                .font(AppFonts.heavy(size: 24))
                .multilineTextAlignment(.center)

            Text("Read the text below to clone your voice and create an AI Self that talks like you.")
                .font(AppFonts.regular(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

private extension SpeechView {

    var textSection: some View {
        Text(viewModel.highlightedText)
            .font(AppFonts.bold(size: 22))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
}

private extension SpeechView {

    var bottomControls: some View {
        Group {
            switch viewModel.state {

            case .idle:
                micButton

            case .listening:
                VStack(spacing: 12) {
                    stopButton

                    Text("Listening...")
                        .font(AppFonts.regular(size: 14))
                        .foregroundColor(.gray)
                }

            case .completed:
                completedControls

            case .error(let msg):
                Text(msg)
            }
        }
        .padding(.bottom, 20)
    }
}

private extension SpeechView {
    
    var micButton: some View {
        Button {
            viewModel.checkMicPermissionsAndStartListning()
        } label: {
            Circle()
                .fill(AppColors.themeColor.opacity(0.3))
                .frame(width: 90, height: 90)
                .overlay(
                    Circle()
                        .fill(AppColors.themeColor)
                        .frame(width: 24, height: 24)
                )
        }
    }
}

private extension SpeechView {

    var stopButton: some View {
        Button {
            viewModel.stopListening()
        } label: {
            Circle()
                .fill(AppColors.themeColor.opacity(0.3))
                .frame(width: 90, height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.themeColor)
                        .frame(width: 28, height: 28)
                )
        }
    }
}

private extension SpeechView {

    var completedControls: some View {
        HStack(spacing: 40) {

            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }

            Button {
                coordinator.goToIdCard()
            } label: {
                Circle()
                    .fill(AppColors.themeColor.opacity(0.3))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "checkmark")
                            .foregroundColor(.black)
                    )
            }

            Button {
                viewModel.togglePlayback()
            } label: {
                Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                    .animation(.easeInOut, value: viewModel.isPlaying)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }
}



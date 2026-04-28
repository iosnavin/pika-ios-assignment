//
//  SelfieCameraView.swift
//  PiKa
//
//  Created by Naveen on 27/04/26.
//

import SwiftUI

struct SelfieCameraView: View {
    
    @ObservedObject var coordinator: AuthCoordinator
    @StateObject private var camera = CameraManager()
    @State private var showImagePicker = false
    
    var body: some View {
        ZStack {
            
            // Camera Preview
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            VStack {
                
                // TOP BAR
                HStack {
                    
                    Spacer()
                    
                    // Progress (50%)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 2)
                            
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geo.size.width * 0.5, height: 2)
                        }
                    }
                    .frame(height: 2)
                    
                    Spacer()
                    
                    Spacer().frame(width: 40)
                }
                .padding()
                
                Spacer()
                
                // BOTTOM CONTROLS
                HStack {
                    // Gallery
                    Button {
                        showImagePicker = true
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                            .padding()
                            .background(AppColors.backgroundColor.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    // Capture
                    Button {
                        camera.capturePhoto()
                    } label: {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 55, height: 55)
                            )
                    }
                    
                    Spacer()
                    
                    // Flip Camera
                    Button {
                        camera.switchCamera()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .foregroundColor(.white)
                            .padding()
                            .background(AppColors.backgroundColor.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .onChange(of: camera.capturedImage) { _, newValue in
            guard let _ = newValue else { return }
            DispatchQueue.main.async {
                coordinator.goToSpeech(image: camera.capturedImage ?? UIImage())
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                camera.capturedImage = image
            }
        }
    }
}

//
//  IDCardScreen.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//
import SwiftUI

struct IDCardScreen: View {
    
    @StateObject var viewModel: IDCardViewModel
    @State private var animate = false
    @State private var showShare = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        ZStack {
            
            // ✅ Background (soft beige like design)
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
                
                Spacer(minLength: 20)

                // ✅ CARD (smaller + opposite tilt)
                IDCardView(
                    model: viewModel.model,
                    barcode: viewModel.barcodeImage
                )
                .frame(width: 280, height: 430)
                .rotationEffect(.degrees(6))
                .scaleEffect(animate ? 1 : 0.9)
                .opacity(animate ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
                .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 18)

                Spacer(minLength: 10)

                VStack(spacing: 6) {
                    Text("MEET \(viewModel.model.name.uppercased())")
                        .font(AppFonts.heavy(size: 30))

                    Text("Your AI Self is ready to chat")
                        .font(AppFonts.regular(size: 15))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer(minLength: 16)

                VStack(spacing: 12) {

                    Button {
                        
                    } label: {
                        HStack {
                            Text("Open Messages")
                            Image(systemName: "arrow.up.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .font(AppFonts.medium(size: 16))
                        .clipShape(Capsule())
                    }

                    Button {
                        shareImage = renderCard()
                    } label: {
                        HStack {
                            Text("Share ID Card")
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black.opacity(0.08))
                        .foregroundColor(.black.opacity(0.7))
                        .font(AppFonts.medium(size: 16))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 20)
            }
        }
        .onAppear {
            animate = true
        }
        .sheet(item: $shareImage) { img in
            ShareSheet(image: img)
        }
    }
    
    func renderCard() -> UIImage {
        IDCardView(
            model: viewModel.model,
            barcode: viewModel.barcodeImage
        )
        .frame(width: 280, height: 430)
        .asImage()
    }
}

struct ShareSheet: UIViewControllerRepresentable {

    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

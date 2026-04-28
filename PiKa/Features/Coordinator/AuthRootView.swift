//
//  AuthRootView.swift
//  PiKa
//
//  Created by Naveen on 27/04/26.
//

import SwiftUI

struct AuthRootView: View {
    
    @StateObject var coordinator = AuthCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            AuthView(viewModel: makeAuthVM())
                .keyboardDoneToolbar()
                .navigationDestination(for: AuthCoordinator.AuthRoute.self) { route in
                    switch route {
                    case .selfie:
                        SelfieCameraView(coordinator: coordinator)
                    case .speech:
                        SpeechView(coordinator: coordinator, viewModel: SpeechViewModel(text: "My best self is just ahead. The life I've always wanted is here. My goals are in reach. I love affirmations."))
                    case .idCard:
                        IDCardScreen(viewModel: makeIDCardVM())
                    }
                }
        }
    }
    
    private func makeAuthVM() -> AuthViewModel {
        let vm = AuthViewModel()
        vm.onSuccess = {
            coordinator.goToSelfie()
        }
        return vm
    }
    
    private func makeIDCardVM() -> IDCardViewModel {
        let vm = IDCardViewModel(model: IDCardModel(name: "Naveen", date: "27 April", location: "USA", status: "Alive", handle: "Pika.me/Naveen", image: coordinator.selectedImage))
        return vm
    }
}

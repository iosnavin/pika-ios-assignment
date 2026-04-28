//
//  AuthCoordinator.swift
//  PiKa
//
//  Created by Naveen on 25/04/26.
//

import Combine
import UIKit

protocol AuthCoordinatorProtocol: AnyObject {
    func goToSelfie()
}

final class AuthCoordinator: ObservableObject, AuthCoordinatorProtocol {
    
    @Published var path: [AuthRoute] = []
    @Published var selectedImage: UIImage?
    
    enum AuthRoute: Hashable {
        case selfie
        case speech
        case idCard
    }
    
    func goToSelfie() {
        path.append(.selfie)
    }
    
    func goToSpeech(image: UIImage) {
        self.selectedImage = image
        path.append(.speech)
    }
    
    func goToIdCard() {
        path.append(.idCard)
    }
}

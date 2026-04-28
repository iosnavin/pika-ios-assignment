//
//  AuthViewModel.swift
//  PiKa
//
//  Created by Naveen on 25/04/26.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    
    @Published var phoneNumber: String = ""
    
    var isValid: Bool {
        let digits = phoneNumber.filter { $0.isNumber }
        return digits.count == 10
    }
    
    var onSuccess: (() -> Void)?
    
    func onContinueTapped() {
        guard isValid else { return }
        onSuccess?()
    }
}

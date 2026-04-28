//
//  Keyboard+Extensions.swift
//  PiKa
//
//  Created by Naveen on 27/04/26.
//

import SwiftUI

struct KeyboardDoneToolbar: ViewModifier {
    
    var action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        action?() ?? hideKeyboard()
                    }
                }
            }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension View {
    func keyboardDoneToolbar(action: (() -> Void)? = nil) -> some View {
        self.modifier(KeyboardDoneToolbar(action: action))
    }
}

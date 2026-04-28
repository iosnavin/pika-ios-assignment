//
//  UIView+Extension.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import SwiftUI

extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: UUID { UUID() }
}

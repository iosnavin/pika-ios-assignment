//
//  Untitled.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import CoreImage.CIFilterBuiltins
import UIKit

final class BarcodeGenerator {

    private let context = CIContext()
    private let filter = CIFilter.code128BarcodeGenerator()

    func generate(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        guard let output = filter.outputImage else { return nil }

        let scaled = output.transformed(by: CGAffineTransform(scaleX: 3, y: 3))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}

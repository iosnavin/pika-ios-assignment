//
//  IDCardViewModel.swift
//  PiKa
//
//  Created by Naveen on 28/04/26.
//

import Combine
import UIKit

struct IDCardModel {
    let name: String
    let date: String
    let location: String
    let status: String
    let handle: String
    let image: UIImage?
}

final class IDCardViewModel: ObservableObject {

    @Published var barcodeImage: UIImage?

    let model: IDCardModel
    private let barcodeGenerator = BarcodeGenerator()

    init(model: IDCardModel) {
        self.model = model
        generateBarcode()
    }

    private func generateBarcode() {
        barcodeImage = barcodeGenerator.generate(from: model.name)
    }
}

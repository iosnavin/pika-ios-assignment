//
//  CameraPreview.swift
//  PiKa
//
//  Created by Naveen on 27/04/26.
//

import SwiftUI
import AVFoundation
import Combine
import PhotosUI

struct CameraPreview: UIViewRepresentable {
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

final class CameraManager: NSObject, ObservableObject {
    
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    @Published var capturedImage: UIImage?
    
    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        guard let currentInput = currentInput else { return }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        let newPosition: AVCaptureDevice.Position =
            currentInput.device.position == .front ? .back : .front
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: device)
        else { return }
        
        session.addInput(newInput)
        self.currentInput = newInput
        
        session.commitConfiguration()
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    var onImagePicked: (UIImage) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        var onImagePicked: (UIImage) -> Void
        
        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true)
            
            guard let item = results.first?.itemProvider,
                  item.canLoadObject(ofClass: UIImage.self)
            else { return }
            
            item.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.onImagePicked(image)
                    }
                }
            }
        }
    }
}

//
//  Camera.swift
//  Conversation
//
//  Created by Aung Ko Min on 14/2/22.
//

import SwiftUI

public struct Camera: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    let onCancel: () async -> Void
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_: UIImagePickerController, context _: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        private let parent: Camera
        
        public init(_ parent: Camera) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage ?? info[.editedImage] as? UIImage{
                parent.image = image
            }
        }
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            Task {
                await parent.onCancel()
            }
        }
    }
}



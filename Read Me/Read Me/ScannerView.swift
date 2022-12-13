//
//  ScannerView.swift
//  Read Me
//
//  Created by Ujwal Chilla on 2/8/22.
//

import VisionKit
import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    
    private let completionHandler: ([String]?) -> Void
    
    init(completion: @escaping ([String]?) -> Void) {
        
        self.completionHandler = completion
        
    }
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
        
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScannerView>) {}
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(completion: completionHandler)
        
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        private let completionHandler: ([String]?) -> Void
        
        init(completion: @escaping ([String]?) -> Void) {
            self.completionHandler = completion
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            
            let recognizer = TextRecognizer(cameraScan: scan)
            recognizer.recognizeText(withCompletionHandler: completionHandler)
            
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            completionHandler(nil)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            completionHandler(nil)
        }
        
    }
    
}

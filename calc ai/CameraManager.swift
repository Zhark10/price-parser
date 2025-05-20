import AVFoundation
import UIKit
import Photos

class CameraManager: ObservableObject {
    @Published var capturedImage: UIImage?
    var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var photoCaptureProcessor: PhotoCaptureProcessor?
    
    init() {
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.beginConfiguration()
        
        guard let captureSession = captureSession,
              let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.isHighResolutionCaptureEnabled = true
        
        if let photoOutput = photoOutput,
           captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = photoOutput else {
            completion(nil)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.isHighResolutionPhotoEnabled = true
        
        photoCaptureProcessor = PhotoCaptureProcessor { [weak self] image in
            guard let self = self, let image = image else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Сохраняем фото в галерею
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("Фото успешно сохранено в галерею")
                            self.capturedImage = image
                            completion(image)
                        } else if let error = error {
                            print("Ошибка при сохранении фото: \(error.localizedDescription)")
                            completion(nil)
                        }
                    }
                }
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureProcessor!)
    }
}

class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    private var photoData: Data?
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Ошибка при захвате фото: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Не удалось получить данные изображения")
            completion(nil)
            return
        }
        
        self.photoData = imageData
        
        if let image = UIImage(data: imageData) {
            completion(image)
        } else {
            print("Не удалось создать UIImage из данных")
            completion(nil)
        }
    }
}
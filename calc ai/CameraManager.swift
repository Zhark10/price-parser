import AVFoundation
import UIKit
import Photos

// MARK: - CameraManager
class CameraManager: ObservableObject {
    @Published var capturedImage: UIImage?
    private(set) var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var photoCaptureProcessor: PhotoCaptureProcessor?
    private var isSessionRunning = false
    
    init() {
        setupCamera()
        setupNotifications()
    }
    
    deinit {
        stopCaptureSession()
        removeNotifications()
    }
}

// MARK: - Session Management
extension CameraManager {
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.isHighResolutionCaptureEnabled = true
        
        configureSession(input: input)
    }
    
    private func configureSession(input: AVCaptureDeviceInput) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            self.captureSession?.beginConfiguration()
            
            if let session = self.captureSession {
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if let output = self.photoOutput, session.canAddOutput(output) {
                    session.addOutput(output)
                }
            }
            
            self.captureSession?.commitConfiguration()
            self.startCaptureSession()
        }
    }
    
    private func startCaptureSession() {
        guard !isSessionRunning else { return }
        captureSession?.startRunning()
        isSessionRunning = true
    }
    
    private func stopCaptureSession() {
        guard isSessionRunning else { return }
        captureSession?.stopRunning()
        isSessionRunning = false
    }
}

// MARK: - Photo Capture
extension CameraManager {
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.isHighResolutionPhotoEnabled = true
        
        photoCaptureProcessor = PhotoCaptureProcessor { [weak self] image in
            self?.handleCapturedImage(image, completion: completion)
        }
        
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureProcessor!)
    }
    
    private func handleCapturedImage(_ image: UIImage?, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.photoCaptureProcessor = nil
            
            guard let image else {
                completion(nil)
                return
            }
            
            self?.saveToPhotoLibrary(image: image, completion: completion)
        }
    }
    
    private func saveToPhotoLibrary(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.capturedImage = image
                        completion(image)
                    } else {
                        print("Save error: \(error?.localizedDescription ?? "")")
                        completion(nil)
                    }
                }
            }
        }
    }
}

// MARK: - Notifications
extension CameraManager {
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: captureSession
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: captureSession
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: captureSession
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("Capture session error: \(error.localizedDescription)")
        
        if error.code == .mediaServicesWereReset {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.stopCaptureSession()
                self?.setupCamera()
            }
        }
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        guard let reason = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? Int,
              let interruptionReason = AVCaptureSession.InterruptionReason(rawValue: reason) else { return }
        print("Session interrupted: \(interruptionReason)")
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        startCaptureSession()
    }
}

// MARK: - PhotoCaptureProcessor
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("Photo processing error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to create image from photo data")
            completion(nil)
            return
        }
        
        completion(image)
    }
}
import AVFoundation
import UIKit
import Photos

class CameraManager: ObservableObject {
    @Published var capturedImage: UIImage?
    var captureSession: AVCaptureSession?
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
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: captureSession)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: captureSession)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: captureSession)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("Ошибка захвата: \(error.localizedDescription)")
        
        // Попытка восстановить сессию
        if error.code == .mediaServicesWereReset {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.stopCaptureSession()
                self?.setupCamera()
            }
        }
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Сессия прервана с причиной: \(reason)")
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            self?.isSessionRunning = true
        }
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
        
        startCaptureSession()
    }
    
    private func startCaptureSession() {
        guard !isSessionRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            self?.isSessionRunning = true
        }
    }
    
    private func stopCaptureSession() {
        guard isSessionRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.isSessionRunning = false
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
        
        // Создаем слабую ссылку на self для предотвращения утечек памяти
        photoCaptureProcessor = PhotoCaptureProcessor { [weak self] image in
            guard let self = self else { return }
            
            // Очищаем processor после использования
            defer {
                DispatchQueue.main.async {
                    self.photoCaptureProcessor = nil
                }
            }
            
            guard let image = image else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
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
        
        // Очищаем данные после использования
        defer {
            photoData = nil
        }
        
        if let image = UIImage(data: imageData) {
            completion(image)
        } else {
            print("Не удалось создать UIImage из данных")
            completion(nil)
        }
    }
}
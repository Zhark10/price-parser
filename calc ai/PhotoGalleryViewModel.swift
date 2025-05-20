import Photos
import SwiftUI

class PhotoGalleryViewModel: NSObject, ObservableObject {
    static let shared = PhotoGalleryViewModel()
    @Published var lastImage: UIImage?
    
    override init() {
        super.init()
        fetchLastPhoto()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func fetchLastPhoto() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard let lastAsset = fetchResult.firstObject else { return }
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: lastAsset,
                             targetSize: CGSize(width: 200, height: 200),
                             contentMode: .aspectFill,
                             options: requestOptions) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.lastImage = image
            }
        }
    }
}

extension PhotoGalleryViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        fetchLastPhoto()
    }
}
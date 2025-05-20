import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let captureSession: AVCaptureSession
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = captureSession
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        return view
    }
    
    // Обязательный метод
    func updateUIView(_ uiView: PreviewView, context: Context) {
    }
}

struct MainCameraView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let session = cameraManager.captureSession {
                    CameraPreview(captureSession: session)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack {
                    Spacer()
                    HStack(spacing: 40) {
                        CameraLeftButton()
                        CameraMainButton(cameraManager: cameraManager)
                        CameraRightButton()
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct CameraLeftButton: View {
    @ObservedObject private var galleryVM = PhotoGalleryViewModel.shared
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var navigateToParser = false
    
    var body: some View {
        ZStack {
            NavigationLink("", destination: PhotoParserView(inputImage: $selectedImage), 
                         isActive: $navigateToParser)
            
            Button(action: { showingImagePicker = true }) {
                if let image = galleryVM.lastImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 62, height: 62)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    Color.backgroundCalc
                        .frame(width: 62, height: 62)
                        .background(Color.backgroundCalc)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                navigateToParser = true
            }
        }
    }
}

struct CameraMainButton: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var navigateToParser = false
    
    var body: some View {
        ZStack {
            NavigationLink("", destination: PhotoParserView(inputImage: $cameraManager.capturedImage),
                         isActive: $navigateToParser)
            
            Button(action: {
                cameraManager.capturePhoto { _ in
                    navigateToParser = true
                }
            }) {
                Image(systemName: "circle")
                    .font(.system(size: 72, weight: Font.Weight.ultraLight))
                    .foregroundColor(Color.black)
                    .frame(width: 72, height: 72)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }
}

struct CameraRightButton: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationLink(destination: CalculatorView().environmentObject(viewModel)) {
            Image("CalcIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 32)
                .foregroundColor(.white)
                .frame(width: 62, height: 62)
                .background(Color.orangeCalc)
                .clipShape(Circle())
        }
    }
}

struct MainCameraView_Previews: PreviewProvider {
    static var previews: some View {
        MainCameraView()
            .environmentObject(ViewModel())
    }
}

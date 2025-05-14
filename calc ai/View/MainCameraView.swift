import SwiftUI

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .grayCalc
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct MainCameraView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreview()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 40) {
                        CameraLeftButton()
                        CameraMainButton()
                        CameraRightButton()
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct CameraLeftButton: View {
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var navigateToParser = false
    
    var body: some View {
        ZStack {
            NavigationLink("", destination: PhotoParserView(inputImage: $selectedImage), isActive: $navigateToParser)
            
            Button(action: {
                showingImagePicker = true
            }) {
                Image(systemName: "circle")
                    .font(.system(size: 64, weight: Font.Weight.light))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                showingImagePicker = false
                navigateToParser = true
            }
        }
    }
}

struct CameraMainButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "circle")
                .font(.system(size: 76, weight: Font.Weight.light))
                .foregroundColor(.secondary.opacity(1))
                .frame(width: 82, height: 82)
                .background(Color.white)
                .clipShape(Circle())
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
                .frame(width: 64, height: 64)
                .background(Color.orangeCalc)
                .clipShape(Circle())
        }
    }
}

struct MainCameraView_Previews: PreviewProvider {
    static var previews: some View {
        MainCameraView()
            .environmentObject(ViewModel()) // Добавляем ViewModel в превью
    }
}

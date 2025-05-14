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
                    .edgesIgnoringSafeArea(.all) // Игнорируем безопасные зоны
                
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

struct CameraLeftButton: View {
    var body: some View {
        NavigationLink(destination: ContentView()) {
            Image(systemName: "circle")
                .font(.system(size: 64, weight: Font.Weight.light))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
        }
    }
}

struct CameraRightButton: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationLink(destination: CalculatorView().environmentObject(viewModel)) {
            Image(systemName: "function")
                .font(.system(size: 32, weight: Font.Weight.medium))
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

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TextRecognizerViewModel()
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        ZStack {
            // Display sum of selected numbers at the top
            VStack {
                if inputImage != nil {
                    Text("Sum: \(viewModel.selectedNumbersSum)")
                        .font(.title)
                        .padding()
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .zIndex(1) // Ensure sum is displayed above other content

             if let image = inputImage {
                 GeometryReader { geometry in
                     ZStack {
                         // Изображение по центру экрана
                         Image(uiImage: image)
                             .resizable()
                             .scaledToFit()
                             .frame(
                                 width: min(image.size.width, geometry.size.width),
                                 height: min(image.size.height, geometry.size.height)
                             )
                             .position(x: geometry.size.width/2, y: geometry.size.height/2)
                             .overlay(
                                 NumberOverlay(
                                     numberBoxes: viewModel.numberBoxes,
                                     image: image,
                                     parentSize: geometry.size,
                                     onNumberTap: { id in // Pass the callback
                                        viewModel.toggleSelection(for: id)
                                     }
                                 )
                             )

                         // Кнопка закрытия
                         Button(action: {
                             inputImage = nil
                             viewModel.numberBoxes = []
                         }) {
                             Image(systemName: "xmark.circle.fill")
                                 .font(.system(size: 30))
                                 .foregroundColor(.white)
                                 .background(Circle().fill(Color.black.opacity(0.7)))
                                 .padding(25)
                         }
                         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                     }
                 }
            } else {
                // Экран выбора изображения
                VStack {
                    Text("Tap to select image")
                        .font(.title)
                        .foregroundColor(.gray)

                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { newImage in
            if let image = newImage {
                viewModel.recognizeText(in: image)
            }
        }
    }
}

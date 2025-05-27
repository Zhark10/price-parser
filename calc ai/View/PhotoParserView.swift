import SwiftUI

struct PhotoParserView: View {
    @StateObject private var viewModel = TextRecognizerViewModel()
    @Binding var inputImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = inputImage {
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
                                onNumberTap: { id in
                                    viewModel.toggleSelection(for: id)
                                }
                            )
                        )
                    
                    VStack {
                        Text("Sum: \(viewModel.selectedNumbersSum)")
                            .font(.title)
                            .padding()
                        Spacer()

                        // Calculator Operation Buttons
                        HStack(spacing: 12) {
                            ForEach([Buttons.plus, Buttons.minus, Buttons.multiple, Buttons.divide, Buttons.back], id: \.self) { button in
                                Button {
                                    viewModel.handleOperation(button)
                                } label: {
                                    Text(button.rawValue)
                                        .frame(width: 62, height: 62)
                                        .foregroundColor(button.buttonFontColor)
                                        .background(button.buttonColor)
                                        .font(.system(size: 30))
                                        .cornerRadius(31) // Half of width/height for perfect circle
                                        .opacity(isButtonSelected(button) ? 0.7 : 1.0)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .zIndex(1)
                }
            }
        }
        .navigationBarTitle("Photo Parser", displayMode: .inline)
        .onAppear {
            if let image = inputImage {
                viewModel.recognizeText(in: image)
            }
        }
    }

    // Helper function to check if a button is selected
    private func isButtonSelected(_ button: Buttons) -> Bool {
        return viewModel.selectedButton == button
    }
}

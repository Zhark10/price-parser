import SwiftUI

struct NumberOverlay: View {
    var numberBoxes: [TextRecognizerViewModel.NumberBox]
    var image: UIImage
    var parentSize: CGSize
    var onNumberTap: (UUID) -> Void // Add this line

    private var imageScale: CGFloat {
        let widthScale = parentSize.width / image.size.width
        let heightScale = parentSize.height / image.size.height
        return min(widthScale, heightScale)
    }

    private var imageFrame: CGRect {
        let scaledWidth = image.size.width * imageScale
        let scaledHeight = image.size.height * imageScale
        return CGRect(
            x: (parentSize.width - scaledWidth) / 2,
            y: (parentSize.height - scaledHeight) / 2,
            width: scaledWidth,
            height: scaledHeight
        )
    }

    var body: some View {
        ZStack {
            ForEach(numberBoxes) { box in
                let convertedRect = convertBoundingBox(originalImagePixelRect: box.boundingBox)

                // Текст с цифрой
                Text(box.number)
                    .frame(width: convertedRect.width, height: convertedRect.height)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(box.isSelected ? .blue : .red) // Change color based on selection
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(3)
                    .border(Color.gray) // Add this line for the gray border
                    .position(x: convertedRect.midX, y: convertedRect.midY)
                    .onTapGesture { // Add this modifier
                        onNumberTap(box.id)
                    }
            }
        }
    }

    private func convertBoundingBox(originalImagePixelRect: CGRect) -> CGRect {
        // originalImagePixelRect - это рамка в пиксельных координатах оригинального изображения (система UIKit, начало в верхнем левом углу)

        // Масштабирование к текущему размеру отображаемого изображения и смещение относительно imageFrame
        return CGRect(
            x: originalImagePixelRect.origin.x * imageScale + imageFrame.origin.x,
            y: originalImagePixelRect.origin.y * imageScale + imageFrame.origin.y,
            width: originalImagePixelRect.width * imageScale,
            height: originalImagePixelRect.height * imageScale
        )
    }
}

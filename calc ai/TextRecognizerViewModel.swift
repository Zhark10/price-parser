import UIKit
import Vision

class TextRecognizerViewModel: ObservableObject {
    @Published var recognizedNumbers = ""
    @Published var errorMessage = ""
    @Published var numberBoxes: [NumberBox] = []

    struct NumberBox: Identifiable {
        let id = UUID()
        let number: String
        let boundingBox: CGRect
    }

    func recognizeText(in image: UIImage) {
        guard let cgImage = image.cgImage else {
            errorMessage = "Failed to process image"
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    self.errorMessage = "No text recognized"
                    return
                }

                self.processObservations(observations, for: image)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false // Улучшаем распознавание цифр
        request.customWords = ["0","1","2","3","4","5","6","7","8","9"] // Приоритет цифрам

        do {
            try requestHandler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func processObservations(_ observations: [VNRecognizedTextObservation], for image: UIImage) {
        let imageSize = image.size
        var boxes = [NumberBox]()

        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }

            // Ищем любые цифры в распознанном тексте
            let numbers = candidate.string.components(separatedBy: .decimalDigits.inverted).joined()
            guard !numbers.isEmpty else { continue }

            // Конвертируем координаты
            guard let box = try? candidate.boundingBox(for: candidate.string.startIndex..<candidate.string.endIndex) else {
                continue
            }

            let boundingBox = CGRect(
                x: box.topLeft.x * imageSize.width,
                y: (1 - box.topLeft.y) * imageSize.height, // Инвертируем Y
                width: (box.topRight.x - box.topLeft.x) * imageSize.width,
                height: (box.topLeft.y - box.bottomLeft.y) * imageSize.height
            )

            boxes.append(NumberBox(number: numbers, boundingBox: boundingBox))
        }

        self.numberBoxes = boxes
        self.recognizedNumbers = boxes.map { $0.number }.joined(separator: "\n")
    }
}

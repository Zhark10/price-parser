import UIKit
import Vision

class TextRecognizerViewModel: ObservableObject {
    @Published var recognizedNumbers = ""
    @Published var errorMessage = ""
    @Published var numberBoxes: [NumberBox] = []
    @Published var selectedNumbersSum: Int = 0

    struct NumberBox: Identifiable {
        let id = UUID()
        let number: String
        let boundingBox: CGRect
        var isSelected: Bool = false
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

            // Ищем целые и дробные числа (с точкой или запятой)
            let pattern = "[0-9]+([.,][0-9]+)?"
            let regex = try? NSRegularExpression(pattern: pattern)
            let matches = regex?.matches(in: candidate.string, range: NSRange(candidate.string.startIndex..., in: candidate.string)) ?? []

            for match in matches {
                guard let range = Range(match.range, in: candidate.string) else { continue }
                let numberString = candidate.string[range].replacingOccurrences(of: ",", with: ".")
                // Конвертируем координаты для найденного числа
                guard let box = try? candidate.boundingBox(for: range) else { continue }
                let boundingBox = CGRect(
                    x: box.topLeft.x * imageSize.width,
                    y: (1 - box.topLeft.y) * imageSize.height,
                    width: (box.topRight.x - box.topLeft.x) * imageSize.width + 20, // TODO: ... точки появляются, когда текст не влазит в рамку
                    height: (box.topLeft.y - box.bottomLeft.y) * imageSize.height
                )
                boxes.append(NumberBox(number: numberString, boundingBox: boundingBox))
            }
        }

        self.numberBoxes = boxes
        self.recognizedNumbers = boxes.map { $0.number }.joined(separator: "\n")
        updateSelectedNumbersSum() // Add this line
    }

    func toggleSelection(for numberBoxId: UUID) {
        if let index = numberBoxes.firstIndex(where: { $0.id == numberBoxId }) {
            numberBoxes[index].isSelected.toggle()
            updateSelectedNumbersSum()
        }
    }

    private func updateSelectedNumbersSum() {
        selectedNumbersSum = Int(numberBoxes.filter { $0.isSelected }.compactMap { Double($0.number) }.reduce(0, +))
    }
}

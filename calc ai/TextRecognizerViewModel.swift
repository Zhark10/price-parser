import UIKit
import Vision

class TextRecognizerViewModel: ObservableObject {
    @Published var recognizedNumbers = ""
    @Published var errorMessage = ""
    @Published var numberBoxes: [NumberBox] = []
    @Published var selectedNumbersSum: Int = 0
    @Published var currentOperation: Operation = .addition  // Default operation is addition (+)
    @Published var storedValue: Double = 0.0
    @Published var selectedButton: Buttons = .plus  // Default selected button is plus (+)

    struct NumberBox: Identifiable {
        let id = UUID()
        let number: String
        let boundingBox: CGRect
        var isSelected: Bool = false
    }

    // MARK: Operation Methods
    func handleOperation(_ button: Buttons) {
        let currentValue = Double(selectedNumbersSum)

        switch button {
        case .plus, .minus, .multiple, .divide:
            // Only store the value and reset selections if it's not just changing operations
            if button != selectedButton {
                // When changing operations, just update the operation, don't reset selectedNumbersSum
                storedValue = currentValue

                // Update selected button and set corresponding operation
                selectedButton = button
                currentOperation = button.toOperation()

                // Don't reset selectedNumbersSum when switching operations
            }

        case .clear:
            // AC just resets the selected numbers, not the operation
            // Deselect all number boxes
            for index in 0..<numberBoxes.count {
                if numberBoxes[index].isSelected {
                    toggleSelection(for: numberBoxes[index].id)
                }
            }
            // Reset sum but don't reset currentOperation or selectedButton
            selectedNumbersSum = 0

        default:
            break
        }
    }

    // MARK: Text Recognition Methods
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
                    width: (box.topRight.x - box.topLeft.x) * imageSize.width,
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
            // Get the value of the number being toggled
            let numberValue = Double(numberBoxes[index].number) ?? 0

            // Toggle the selection state
            numberBoxes[index].isSelected.toggle()

            if numberBoxes[index].isSelected { // If number is being selected
                // First get the raw sum without this number
                let otherSelectedNumbers = numberBoxes.filter { $0.isSelected && $0.id != numberBoxId }
                let rawSum = otherSelectedNumbers.compactMap { Double($0.number) }.reduce(0, +)

                // If we have stored value and an operation, apply it
                if storedValue != 0 {
                    // Apply the operation based on the selected button
                    switch currentOperation {
                    case .addition:
                        selectedNumbersSum = Int(storedValue + numberValue)
                    case .subtract:
                        selectedNumbersSum = Int(storedValue - numberValue)
                    case .multiply:
                        selectedNumbersSum = Int(storedValue * numberValue)
                    case .divide:
                        if numberValue != 0 {
                            selectedNumbersSum = Int(storedValue / numberValue)
                        }
                    default:
                        selectedNumbersSum = Int(rawSum + numberValue)
                    }

                    // Reset stored value after operation is applied
                    storedValue = 0
                } else {
                    // No stored operation, just add the new number to the sum
                    selectedNumbersSum = Int(rawSum + numberValue)
                }
            } else { // If number is being deselected
                // Just recalculate the sum of all selected numbers
                updateSelectedNumbersSum()
            }
        }
    }

    private func updateSelectedNumbersSum() {
        selectedNumbersSum = Int(numberBoxes.filter { $0.isSelected }.compactMap { Double($0.number) }.reduce(0, +))
    }
}

import SwiftUI


// MARK: Extension: Button to Operation
extension Buttons {
    func toOperation() -> Operation {
        switch self {
        case .plus:
            return .addition
        case .minus:
            return .subtract
        case .multiple:
            return .multiply
        case .divide:
            return .divide
        default:
            return .none
        }
    }
}

import Foundation

enum ImagesCountRange: String, CaseIterable, Identifiable {
    case low
    case medium
    case high
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .low: return "1–3"
        case .medium: return "3–5"
        case .high: return "5–10"
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .low: return 1...3
        case .medium: return 3...5
        case .high: return 5...10
        }
    }
}

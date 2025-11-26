import SwiftUI
import CoreLocation

struct ImageMetadata {
    let coordinate: CLLocationCoordinate2D
    let date: Date
}

struct ImageGenerationParams {
    let count: Int
    let size: CGSize
    let metadata: ImageMetadata
}

enum ImageSize: Double {
    case small = 100
}


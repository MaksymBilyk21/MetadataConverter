import Foundation
import CoreLocation

struct MapPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var startDate: Date
    var address: String = "Loading..."
}

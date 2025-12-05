import SwiftUI
import Combine
import CoreLocation
import Photos

final class CreateImageViewModel: NSObject, ObservableObject {
    @Published var size: ImageSize = .small
    
    @Published var generatedImages: [GeneratedImage] = []
    @Published var selectedImage: GeneratedImage?
    @Published var errorMessage: String?
    
    @Published var isShowingMap: Bool = false
    @Published var showToast: Bool = false
    
    @Published var geocoder = CLGeocoder()
    @Published var mapPoints: [MapPoint] = []
    @Published var firstImageDate: Date = Date()
    @Published var selectedImagesRange: ImagesCountRange = .low
    @Published var currentLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    private let imageGenerator: ImageGenerating
    
    init(generator: ImageGenerating = ImageGenerator()) {
        self.imageGenerator = generator
        super.init()
        setupLocationManager()
    }
    
    var groupedImages: [(point: MapPoint, images: [GeneratedImage])] {
        let dict = Dictionary(grouping: generatedImages, by: { $0.pointId })
        
        return mapPoints.compactMap { point in
            guard let imgs = dict[point.id], !imgs.isEmpty else { return nil }
            return (point: point, images: imgs.sorted { $0.date < $1.date })
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// MARK: - Save images
extension CreateImageViewModel {
    func saveToPhotos(_ generated: GeneratedImage) {
        PHPhotoLibrary.shared().performChanges({
            let options = PHAssetResourceCreationOptions()
            options.uniformTypeIdentifier = "public.jpeg"
            
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo,
                                data: generated.jpegData,
                                options: options)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to save image: \(error.localizedDescription)"
                } else if success {
                    self.errorMessage = nil
                    
                    self.showToast = true
                    
                    
                }
            }
        })
    }
    
    func saveAllToPhotos() {
        guard !generatedImages.isEmpty else { return }
        
        let items = generatedImages
        
        PHPhotoLibrary.shared().performChanges({
            for item in items {
                let options = PHAssetResourceCreationOptions()
                options.uniformTypeIdentifier = "public.jpeg"
                
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo,
                                    data: item.jpegData,
                                    options: options)
            }
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Saving failed: \(error.localizedDescription)"
                    return
                }
                
                guard success else {
                    self.errorMessage = "Saving failed: unknown error."
                    return
                }
                
                self.errorMessage = nil
                self.showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showToast = false
                }
            }
        })
    }
}

// MARK: - Map Methods
extension CreateImageViewModel {
    func addPoint(_ coordinate: CLLocationCoordinate2D) {
        let newPoint = MapPoint(
            coordinate: coordinate,
            startDate: Date()
        )
        
        mapPoints.append(newPoint)
        
        let index = mapPoints.count - 1
        fetchAddress(for: coordinate) { [weak self] address in
            guard let self = self else { return }
            self.mapPoints[index].address = address
        }
    }
    
    private func fetchAddress(for coordinate: CLLocationCoordinate2D,
                              completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                let city = place.locality ?? ""
                let country = place.country ?? ""
                
                let result = "\(city), \(country)"
                completion(result)
            } else {
                completion("Unknown location")
            }
        }
    }
    
    func generateImagesForAllPoints() {
        guard !mapPoints.isEmpty else {
            errorMessage = "Add at least one point on the map first."
            return
        }
        
        var allGenerated: [GeneratedImage] = []
        var currentDate = firstImageDate
        
        for point in mapPoints {
            let imagesCount = Int.random(in: selectedImagesRange.range)
            
            for _ in 0..<imagesCount {
                let metadata = ImageMetadata(
                    coordinate: point.coordinate,
                    date: currentDate
                )
                
                let params = ImageGenerationParams(
                    count: 1,
                    size: CGSize(width: size.rawValue, height: size.rawValue),
                    metadata: metadata,
                    pointId: UUID()
                )
                
                do {
                    let generated = try imageGenerator.generateImages(with: params)
                    
                    for img in generated {
                        let item = GeneratedImage(
                            uiImage: img.uiImage,
                            jpegData: img.jpegData,
                            pointId: point.id,
                            date: metadata.date
                        )
                        allGenerated.append(item)
                    }
                } catch {
                    print("Generation failed: \(error)")
                }
                
                let deltaMinutes = Int.random(in: 1...120)
                currentDate = Calendar.current.date(
                    byAdding: .minute,
                    value: deltaMinutes,
                    to: currentDate
                ) ?? currentDate
            }
        }
        
        generatedImages = allGenerated
    }
}

extension CreateImageViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager] error: \(error)")
    }
}

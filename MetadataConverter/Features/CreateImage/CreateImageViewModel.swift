import SwiftUI
import Combine
import CoreLocation
import Photos

final class CreateImageViewModel: ObservableObject {
    @Published var coordinates: String = ""
    @Published var time: String = ""
    @Published var count: Int = 1
    @Published var size: ImageSize = .small
    
    @Published var generatedImages: [GeneratedImage] = []
    @Published var selectedImage: GeneratedImage?
    @Published var errorMessage: String?
    
    @Published var isShowingDatePicker: Bool = false
    
    @Published var selectedDate: Date = Date() {
        didSet {
            updateTimeFromDate()
        }
    }
    
    private let imageGenerator: ImageGenerating
    
    init(generator: ImageGenerator = ImageGenerator()) {
        self.imageGenerator = generator
        updateTimeFromDate()
    }
    
    private func updateTimeFromDate() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        time = formatter.string(from: selectedDate)
    }
}

// MARK: - Generate images
extension CreateImageViewModel {
    func generateImages() {
        guard let coordinate = parseCoordinates(from: coordinates) else {
            errorMessage = "Invalid coordinate format. Use: 49.8397, 24.0297"
            return
        }
        
        let metadata = ImageMetadata(
            coordinate: coordinate,
            date: selectedDate
        )
        
        let params = ImageGenerationParams(
            count: count,
            size: CGSize(width: size.rawValue, height: size.rawValue),
            metadata: metadata
        )
        
        do {
            let result = try imageGenerator.generateImages(with: params)
            generatedImages = result
            errorMessage = nil
        } catch {
            errorMessage = "Image creation failed: \(error.localizedDescription)"
        }
    }
    
    func generateRandomImages() {
        let lat = Double.random(in: -90...90)
        let lon = Double.random(in: -180...180)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        coordinates = "\(lat), \(lon)"
        
        let daysBack = Int.random(in: 0...365)
        if let randomDate = Calendar.current.date(byAdding: .day,
                                                  value: -daysBack,
                                                  to: Date()) {
            selectedDate = randomDate
        }
        
        let metadata = ImageMetadata(
            coordinate: coordinate,
            date: selectedDate
        )
        
        let params = ImageGenerationParams(
            count: count,
            size: CGSize(width: size.rawValue, height: size.rawValue),
            metadata: metadata
        )
        
        do {
            let result = try imageGenerator.generateImages(with: params)
            generatedImages = result
            errorMessage = nil
        } catch {
            errorMessage = "Image creation failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helpers
    private func parseCoordinates(from string: String) -> CLLocationCoordinate2D? {
        let parts = string
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        guard parts.count == 2,
              let lat = Double(parts[0]),
              let lon = Double(parts[1]),
              (-90...90).contains(lat),
              (-180...180).contains(lon) else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func saveToPhotos(_ generated: GeneratedImage) {
        PHPhotoLibrary.shared().performChanges({
            let options = PHAssetResourceCreationOptions()
            options.uniformTypeIdentifier = "public.jpeg"
            
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: generated.jpegData, options: options)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to save image: \(error.localizedDescription)"
                } else if success {
                    self.errorMessage = nil
                }
            }
        })
    }
}

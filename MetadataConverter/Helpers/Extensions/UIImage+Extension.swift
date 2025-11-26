import UIKit
import ImageIO
import CoreLocation
import MobileCoreServices

protocol ImageGenerating {
    func generateImages(with params: ImageGenerationParams) throws -> [GeneratedImage]
}

// MARK: - UIImage + metadata
extension UIImage {
    func jpegDataAddingMetadata(gps: [String: Any], exif: [String: Any]) -> Data? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else { return nil }
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let uniformType = CGImageSourceGetType(source) else { return nil }
        
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, options) as? [String: Any] else {
            return nil
        }
        
        var mutableMetadata = metadata
        mutableMetadata[kCGImagePropertyGPSDictionary as String] = gps
        mutableMetadata[kCGImagePropertyExifDictionary as String] = exif
        
        let outputData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(outputData, uniformType, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImageFromSource(destination, source, 0, mutableMetadata as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        return outputData as Data
    }
}


// MARK: - Helpers for GPS / EXIF
private let gpsDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy:MM:dd"
    formatter.timeZone = .current
    return formatter
}()

private let gpsTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    formatter.timeZone = .current
    return formatter
}()

private func makeGPSMetadata(from coordinate: CLLocationCoordinate2D,
                             date: Date) -> [String: Any] {
    var gps: [String: Any] = [:]
    
    gps[kCGImagePropertyGPSLatitude as String] = abs(coordinate.latitude)
    gps[kCGImagePropertyGPSLatitudeRef as String] = coordinate.latitude >= 0 ? "N" : "S"
    
    gps[kCGImagePropertyGPSLongitude as String] = abs(coordinate.longitude)
    gps[kCGImagePropertyGPSLongitudeRef as String] = coordinate.longitude >= 0 ? "E" : "W"
    
    gps[kCGImagePropertyGPSAltitudeRef as String] = 0
    gps[kCGImagePropertyGPSTimeStamp as String] = gpsTimeFormatter.string(from: date)
    gps[kCGImagePropertyGPSDateStamp as String] = gpsDateFormatter.string(from: date)
    
    return gps
}

private func makeExifMetadata(from date: Date) -> [String: Any] {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
    
    return [
        kCGImagePropertyExifDateTimeOriginal as String: formatter.string(from: date),
        kCGImagePropertyExifDateTimeDigitized as String: formatter.string(from: date)
    ]
}

private func makeBlankImage(size: CGSize, color: UIColor) -> UIImage? {
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 0
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    
    return renderer.image { ctx in
        color.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
    }
}

private func randomFlatColor() -> UIColor {
    let colors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemYellow,
        .systemPurple,
        .systemPink,
        .systemTeal
    ]
    return colors.randomElement() ?? .systemGray
}

// MARK: - ImageGenerator
final class ImageGenerator: ImageGenerating {
    func generateImages(with params: ImageGenerationParams) throws -> [GeneratedImage] {
        let gps = makeGPSMetadata(from: params.metadata.coordinate,
                                  date: params.metadata.date)
        let exif = makeExifMetadata(from: params.metadata.date)
        
        var result: [GeneratedImage] = []
        
        for _ in 0..<params.count {
            guard let baseImage = makeBlankImage(size: params.size,
                                                 color: randomFlatColor()) else {
                continue
            }
            
            guard let data = baseImage.jpegDataAddingMetadata(gps: gps, exif: exif) else {
                if let fallbackData = baseImage.jpegData(compressionQuality: 1.0) {
                    let uiImage = UIImage(data: fallbackData) ?? baseImage
                    result.append(GeneratedImage(uiImage: uiImage, jpegData: fallbackData))
                }
                continue
            }
            
            let uiImage = UIImage(data: data) ?? baseImage
            result.append(GeneratedImage(uiImage: uiImage, jpegData: data))
        }
        
        return result
    }
}

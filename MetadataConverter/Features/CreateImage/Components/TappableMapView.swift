import SwiftUI
import MapKit

struct TappableMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var points: [MapPoint]
    
    var onTapCoordinate: ((CLLocationCoordinate2D) -> Void)?
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TappableMapView
        
        init(parent: TappableMapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            if let handler = parent.onTapCoordinate {
                handler(coordinate)
            } else {
                let newPoint = MapPoint(
                    coordinate: coordinate,
                    startDate: Date()
                )
                parent.points.append(newPoint)
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true
        
        mapView.setRegion(region, animated: false)
        
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tap)
        
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.layer.backgroundColor = UIColor.systemBackground.cgColor
        trackingButton.layer.cornerRadius = 6
        
        mapView.addSubview(trackingButton)
        
        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            trackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16)
        ])
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        let annotations = points.map { point -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = point.coordinate
            return annotation
        }
        
        uiView.addAnnotations(annotations)
    }
}

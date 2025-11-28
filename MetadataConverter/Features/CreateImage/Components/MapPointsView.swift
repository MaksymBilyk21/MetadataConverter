import SwiftUI
import MapKit
import Combine

struct MapPointsView: View {
    @EnvironmentObject var viewModel: CreateImageViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297),
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )
    
    @State private var didCenterOnUser = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TappableMapView(
                region: $region,
                points: $viewModel.mapPoints,
                onTapCoordinate: { coordinate in
                    viewModel.addPoint(coordinate)
                }
            )
            .frame(height: 350)
            .onAppear {
                if let first = viewModel.mapPoints.first {
                    region = MKCoordinateRegion(
                        center: first.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
            .onReceive(viewModel.$currentLocation.compactMap { $0 }) { coord in
                guard !didCenterOnUser else { return }
                region.center = coord
                didCenterOnUser = true
            }
            
            Form {
                Section("First photo time") {
                    DatePicker(
                        "Start date",
                        selection: $viewModel.firstImageDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section("Count range") {
                    Picker("Count", selection: $viewModel.selectedImagesRange) {
                        ForEach(ImagesCountRange.allCases) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 16)
                }
                
                if let current = viewModel.currentLocation {
                    Section {
                        Button {
                            viewModel.addPoint(current)
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Add current location")
                            }
                        }
                    }
                }
                
                Section("Points") {
                    ForEach(viewModel.mapPoints) { point in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.address)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.mono27282C)
                            
                            Text("Lat: \(point.coordinate.latitude)")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.mono41454E)
                            
                            Text("Lon: \(point.coordinate.longitude)")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.mono41454E)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete { indexSet in
                        viewModel.mapPoints.remove(atOffsets: indexSet)
                    }
                }
                .opacity(viewModel.mapPoints.isEmpty ? 0 : 1)
            }
        }
        .navigationTitle("Select points")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    viewModel.generateImagesForAllPoints()
                    dismiss()
                }
            }
        }
    }
}

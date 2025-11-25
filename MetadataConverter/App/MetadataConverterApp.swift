import SwiftUI

@main
struct MetadataConverterApp: App {
    @StateObject private var navigationManager: NavigationManager
    
    init() {
        _navigationManager = StateObject(wrappedValue: NavigationManager())
    }
    
    var body: some Scene {
        WindowGroup {
            switch navigationManager.appState {
            case .home: CreateImageView()
                
            }
        }
        .environmentObject(navigationManager)
    }
}

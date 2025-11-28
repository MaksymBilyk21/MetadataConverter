import Foundation
import SwiftUI
import Combine

protocol PathItem: Hashable, Codable {}

enum AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        UUID().uuidString
    }
    
    case home
}

enum ScreenNavigation: Hashable {
    case home
}

final class NavigationManager: ObservableObject {
    @Published var appState: AppState = .home
    @Published public var homePath = NavigationPath()

    init() {}
    
    public func append(_ screen: ScreenNavigation) {
        switch appState {
        case .home:
            homePath.append(screen)
        }
    }
    
    public func removeLast(_ k: Int = 1) {
        switch appState {
        case .home:
            homePath.removeLastIfHave(k)
        }
    }
}

extension View {
    func screenNavigation() -> some View { self
        .navigationDestination(for: ScreenNavigation.self) { screen in
            switch screen {
            case .home: CreateImageView()
            }
        }
    }
}

extension NavigationPath {
    mutating func removeLastIfHave(_ count: Int) {
        if self.count < count {
            self.removeLast(count - 1)
        } else {
            self.removeLast(count)
        }
    }
}

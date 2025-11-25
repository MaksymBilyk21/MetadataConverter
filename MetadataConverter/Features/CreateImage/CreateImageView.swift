import SwiftUI

struct CreateImageView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var viewModel: CreateImageViewModel = CreateImageViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationManager.homePath) {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Hello, world!")
                
                Button {
                    
                } label: {
                    Text("Press me")
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .screenNavigation()
        }
    }
}

#Preview {
    CreateImageView()
        .environmentObject(NavigationManager())
}

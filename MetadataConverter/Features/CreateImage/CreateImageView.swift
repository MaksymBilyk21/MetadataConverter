import SwiftUI

struct CreateImageView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var viewModel: CreateImageViewModel = CreateImageViewModel()
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack(path: $navigationManager.homePath) {
            mainContainer
                .screenNavigation()
        }
    }
}

// MARK: - UI components
private extension CreateImageView {
    private var mainContainer: some View {
        VStack {
            imagesLayout
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $viewModel.isShowingMap) {
            NavigationStack {
                MapPointsView()
                    .environmentObject(viewModel)
            }
        }
        .overlay(alignment: .top) {
            if viewModel.showToast {
                Text("Saved to Photos")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.showToast)
            }
        }
    }
    
    private var imagesLayout: some View {
        Group {
            if viewModel.generatedImages.isEmpty {
                Spacer()
                
                VStack {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    
                    Text("There is no generated images yet.")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.mono27282C)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        viewModel.isShowingMap.toggle()
                    } label: {
                        Text("Open map")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.main9E67E9)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.main9E67E9, lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
                
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.groupedImages, id: \.point.id) { section in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(section.point.address)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(.mono27282C)
                                
                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(section.images) { item in
                                        Image(uiImage: item.uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                            .contextMenu {
                                                Button("Save to Photos") {
                                                    viewModel.saveToPhotos(item)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
            
            if !viewModel.groupedImages.isEmpty {
                HStack {
                    Button {
                        viewModel.saveAllToPhotos()
                    } label: {
                        Text("Save all to Photos")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.mono27282C)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.red, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    Button {
                        viewModel.isShowingMap.toggle()
                    } label: {
                        Text("Open map")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.main9E67E9)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.main9E67E9, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    CreateImageView()
        .environmentObject(NavigationManager())
}

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
            CustomTextField(text: $viewModel.coordinates)
            
            dateLabel
            
            countPicker
            
            imagesLayout
            
            Spacer()
            
            Button {
                viewModel.generateImages()
            } label: {
                Text("Generate")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.mono27282C)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.main9E67E9.opacity(0.5)), lineWidth: 1)
                    )
            }
            
            Button {
                viewModel.generateRandomImages()
            } label: {
                Text("Generate randomly")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.mono27282C)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.main9E67E9)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $viewModel.isShowingDatePicker) {
            VStack {
                HStack {
                    Button("Cancel") {
                        viewModel.isShowingDatePicker = false
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        viewModel.isShowingDatePicker = false
                    }
                }
                .padding()
                
                Divider()
                
                DatePicker(
                    "",
                    selection: $viewModel.selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 250)
                
                Spacer()
            }
            .presentationDetents([.height(320), .medium])
        }
    }
    
    private var dateLabel: some View {
        Button {
            viewModel.isShowingDatePicker = true
        } label: {
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("Select date & time")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.mono41454E)
                    
                    Text(formattedDisplayDate(viewModel.selectedDate))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.main9E67E9)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var countPicker: some View {
        Picker("Count", selection: $viewModel.count) {
            Text("1").tag(1)
            Text("3").tag(3)
            Text("5").tag(5)
            Text("10").tag(10)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
    
    private var imagesLayout: some View {
        Group {
            if viewModel.generatedImages.isEmpty {
                Text("There is no generated images yet.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.mono27282C)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(viewModel.generatedImages) { item in
                            Image(uiImage: item.uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 80)
                                .cornerRadius(8)
                                .contextMenu {
                                    Button {
                                        viewModel.saveToPhotos(item)
                                    } label: {
                                        Label("Save to Photos", systemImage: "photo")
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }
    
}

// MARK: - Methods
private extension CreateImageView {
    private func formattedDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    CreateImageView()
        .environmentObject(NavigationManager())
}

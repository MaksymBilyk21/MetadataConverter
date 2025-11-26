import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String = "Enter coordinates here..."
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.mono41454E)
                .frame(width: 16, height: 16)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.mono41454E)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.monoEEEEEE)
        )
        .padding(.horizontal, 16)
    }
}

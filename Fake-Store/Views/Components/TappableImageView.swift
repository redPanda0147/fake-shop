import SwiftUI

struct TappableImageView: View {
    let imageURL: String
    let height: CGFloat
    let onTap: () -> Void
    @State private var showFullScreenImages = false
    
    init(imageURL: String, height: CGFloat = 160, onTap: @escaping () -> Void = {}) {
        self.imageURL = imageURL
        self.height = height
        self.onTap = onTap
    }
    
    var body: some View {
        CachedImageView(url: imageURL)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .clipped()
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    TappableImageView(
        imageURL: "https://placeimg.com/640/480/tech"
    )
    .padding()
} 
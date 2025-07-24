import SwiftUI

struct FullScreenImageViewer: View {
    let images: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    
    @State private var currentIndex: Int
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    init(images: [String], initialIndex: Int = 0, isPresented: Binding<Bool>) {
        self.images = images
        self.initialIndex = initialIndex
        self._isPresented = isPresented
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: isPresented)
            
            if isPresented {
                VStack {
                    // Header with close button and counter
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 32, height: 32)
                                )
                        }
                        
                        Spacer()
                        
                        // Page indicator dots (only show if multiple images)
                        if images.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(0..<images.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                    .padding()
                    .zIndex(1)
                    
                    // Image viewer
                    TabView(selection: $currentIndex) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                            ZoomableImageView(
                                url: imageUrl,
                                scale: $scale,
                                offset: $offset,
                                lastScale: $lastScale,
                                lastOffset: $lastOffset
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    .onChange(of: currentIndex) { _ in
                        // Reset zoom when changing images
                        withAnimation(.easeOut(duration: 0.3)) {
                            scale = 1.0
                            offset = .zero
                            lastScale = 1.0
                            lastOffset = .zero
                            // Note: isZoomed will be reset in each ZoomableImageView
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            currentIndex = initialIndex
        }
    }
}

struct ZoomableImageView: View {
    let url: String
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastScale: CGFloat
    @Binding var lastOffset: CGSize
    
    @StateObject private var imageLoader = ImageLoader()
    @State private var isImageLoaded = false
    @State private var isZoomed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = imageLoader.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .opacity(isImageLoaded ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isImageLoaded = true
                            }
                        }
                        .gesture(
                            // Magnification gesture for zoom
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    scale = min(max(newScale, 1.0), 4.0)
                                    isZoomed = scale > 1.0
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale < 1.2 {
                                        withAnimation(.spring()) {
                                            scale = 1.0
                                            offset = .zero
                                            lastScale = 1.0
                                            lastOffset = .zero
                                            isZoomed = false
                                        }
                                    }
                                }
                        )
                        .simultaneousGesture(
                            // Drag gesture for panning - only when zoomed in
                            DragGesture()
                                .onChanged { value in
                                    // Only handle panning when zoomed in (scale > 1.0)
                                    if isZoomed {
                                        let newOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                        
                                        // Limit panning to image bounds
                                        let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
                                        let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                                        
                                        offset = CGSize(
                                            width: min(max(newOffset.width, -maxOffsetX), maxOffsetX),
                                            height: min(max(newOffset.height, -maxOffsetY), maxOffsetY)
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .onTapGesture(count: 2) {
                            // Double tap to zoom
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastScale = 1.0
                                    lastOffset = .zero
                                    isZoomed = false
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                    isZoomed = true
                                }
                            }
                        }
                        .onChange(of: scale) { newScale in
                            // Update zoom state when scale changes
                            isZoomed = newScale > 1.0
                        }
                } else {
                    // Loading state
                    ZStack {
                        Color.black.opacity(0.3)
                        
                        if imageLoader.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .onAppear {
            imageLoader.load(from: url)
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}

#Preview {
    @State var isPresented = true
    
    return FullScreenImageViewer(
        images: [
            "https://placeimg.com/640/480/tech",
            "https://placeimg.com/640/480/tech/2",
            "https://placeimg.com/640/480/tech/3"
        ],
        initialIndex: 0,
        isPresented: $isPresented
    )
} 
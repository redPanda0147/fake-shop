import SwiftUI

struct LoadingView: View {
    let message: String
    let isFullScreen: Bool
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    
    init(message: String = "Loading...", isFullScreen: Bool = false) {
        self.message = message
        self.isFullScreen = isFullScreen
    }
    
    var body: some View {
        ZStack {
            if isFullScreen {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 24) {
                // Animated loading indicator
                ZStack {
                    // Background circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.2),
                                    Color.blue.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseScale)
                    
                    // Main progress indicator
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    
                    // Rotating dots around the progress indicator
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .offset(y: -35)
                            .rotationEffect(.degrees(Double(index) * 45 + (isAnimating ? 360 : 0)))
                    }
                }
                
                // Message with typing animation
                VStack(spacing: 8) {
                    Text(message)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1.0 : 0.7)
                    
                    // Animated dots
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 4, height: 4)
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                }
                
                // Subtle hint text
                if isFullScreen {
                    Text("Please wait while we prepare your content")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(0.8)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(isAnimating ? 1.0 : 0.95)
            .opacity(isAnimating ? 1.0 : 0.8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
            
            // Pulse animation for background circle
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.1
            }
        }
    }
}

struct LoadingPlaceholderRow: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Animated image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemGray6),
                            Color(.systemGray5),
                            Color(.systemGray6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .opacity(isAnimating ? 0.6 : 1.0)
            
            VStack(alignment: .leading, spacing: 8) {
                // Animated title placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(height: 16)
                    .frame(maxWidth: 120)
                    .opacity(isAnimating ? 0.6 : 1.0)
                
                // Animated subtitle placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(height: 12)
                    .frame(maxWidth: 80)
                    .opacity(isAnimating ? 0.6 : 1.0)
                
                // Animated price placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
                    .frame(height: 12)
                    .frame(maxWidth: 60)
                    .opacity(isAnimating ? 0.6 : 1.0)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// Shimmer effect
struct Shimmering: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .animation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                value: phase
            )
            .onAppear {
                phase = 0.8
            }
    }
    
    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat
        
        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }
        
        func body(content: Content) -> some View {
            content
                .overlay(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: phase - 0.3),
                            .init(color: .white.opacity(0.7), location: phase - 0.15),
                            .init(color: .white.opacity(0.7), location: phase),
                            .init(color: .clear, location: phase + 0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .mask(content)
        }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(Shimmering())
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView(message: "Loading products...")
        LoadingView(message: "Loading products...", isFullScreen: true)
        LoadingPlaceholderRow()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 

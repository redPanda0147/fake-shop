//
//  ContentView.swift
//  Fake-Store
//
//  Created by Nadim Sheikh on 23/07/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                SplashScreenView(isLoading: $isLoading)
            } else {
                ProductListView()
            }
        }
    }
}

struct SplashScreenView: View {
    @Binding var isLoading: Bool
    @State private var scale = 0.7
    @State private var opacity = 0.0
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Decorative circles
            Circle()
                .fill(AppColor.primary.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: -120, y: -150)
            
            Circle()
                .fill(AppColor.secondary.opacity(0.1))
                .frame(width: 250, height: 250)
                .offset(x: 130, y: 200)
            
            // Main content
            VStack(spacing: 30) {
                // Logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppColor.primary.opacity(0.9),
                                    AppColor.primary
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: AppColor.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "cart.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.0).repeatCount(1)) {
                                rotation = 10
                            }
                        }
                }
                
                VStack(spacing: 12) {
                    Text("Fake Store")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.primary)
                    
                    Text("Premium Shopping Experience")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColor.secondaryText)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                // Simulate loading time
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        opacity = 0.0
                        scale = 1.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

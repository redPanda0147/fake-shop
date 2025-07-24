//
//  Fake_StoreApp.swift
//  Fake-Store
//
//  Created by Nadim Sheikh on 23/07/25.
//

import SwiftUI
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure app appearance
        configureAppAppearance()
        return true
    }
    
    private func configureAppAppearance() {
        // Set global appearance for navigation bars, tab bars, etc.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: "0d031b").opacity(0.05))
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "0d031b"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color(hex: "0d031b"))]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tint color for all views
        UIView.appearance().tintColor = UIColor(Color(hex: "0d031b"))
    }
}

@main
struct Fake_StoreApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
                .task {
                    // Initialize StoreKit products
                    await purchaseManager.requestProducts()
                }
        }
    }
}

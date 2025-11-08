//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// The background gradient shown on the launch, splash and onboarding screens.
struct AuthenticationStartScreenBackgroundImage: View {
    @State private var animateGradient = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    private var baseGradientColors: [Color] {
        if isDarkMode {
            return [
                Color(red: 0.1, green: 0.15, blue: 0.3),
                Color(red: 0.2, green: 0.1, blue: 0.35),
                Color(red: 0.15, green: 0.25, blue: 0.4),
                Color(red: 0.25, green: 0.15, blue: 0.45)
            ]
        } else {
            return [
                Color(red: 0.2, green: 0.3, blue: 0.6),
                Color(red: 0.4, green: 0.2, blue: 0.7),
                Color(red: 0.3, green: 0.5, blue: 0.8),
                Color(red: 0.5, green: 0.3, blue: 0.9)
            ]
        }
    }
    
    private var radialGradientColor: Color {
        if isDarkMode {
            return Color(red: 0.4, green: 0.25, blue: 0.6).opacity(0.4)
        } else {
            return Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3)
        }
    }
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: baseGradientColors,
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(
                Animation.easeInOut(duration: 8.0)
                    .repeatForever(autoreverses: true),
                value: animateGradient
            )
            
            // Animated radial gradient overlay
            RadialGradient(
                colors: [
                    radialGradientColor,
                    Color.clear
                ],
                center: animateGradient ? .topTrailing : .bottomLeading,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()
            .animation(
                Animation.easeInOut(duration: 6.0)
                    .repeatForever(autoreverses: true),
                value: animateGradient
            )
            
            // Decorative geometric shapes
            GeometryReader { geometry in
                // Large circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.width * 1.2)
                    .offset(
                        x: animateGradient ? geometry.size.width * 0.3 : geometry.size.width * 0.1,
                        y: animateGradient ? geometry.size.height * 0.2 : geometry.size.height * 0.4
                    )
                    .blur(radius: 60)
                    .animation(
                        Animation.easeInOut(duration: 10.0)
                            .repeatForever(autoreverses: true),
                        value: animateGradient
                    )
                
                // Medium circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                isDarkMode ? 
                                    Color(red: 0.5, green: 0.3, blue: 0.6).opacity(0.3) :
                                    Color(red: 0.8, green: 0.5, blue: 0.9).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(
                        x: animateGradient ? geometry.size.width * 0.7 : geometry.size.width * 0.5,
                        y: animateGradient ? geometry.size.height * 0.7 : geometry.size.height * 0.5
                    )
                    .blur(radius: 40)
                    .animation(
                        Animation.easeInOut(duration: 12.0)
                            .repeatForever(autoreverses: true),
                        value: animateGradient
                    )
                
                // Small accent circles
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(isDarkMode ? Color.white.opacity(0.1) : Color.white.opacity(0.15))
                        .frame(width: CGFloat(100 + index * 50))
                        .offset(
                            x: animateGradient ? 
                                geometry.size.width * (0.2 + CGFloat(index) * 0.2) :
                                geometry.size.width * (0.3 + CGFloat(index) * 0.15),
                            y: animateGradient ?
                                geometry.size.height * (0.3 + CGFloat(index) * 0.15) :
                                geometry.size.height * (0.2 + CGFloat(index) * 0.2)
                        )
                        .blur(radius: 30)
                        .animation(
                            Animation.easeInOut(duration: Double(8 + index * 2))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5),
                            value: animateGradient
                        )
                }
            }
            
            // Subtle noise texture overlay for depth
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            isDarkMode ? 
                                Color.black.opacity(0.1) :
                                Color.black.opacity(0.05),
                            Color.clear,
                            isDarkMode ?
                                Color.white.opacity(0.02) :
                                Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()
        }
        .onAppear {
            animateGradient = true
        }
        .accessibilityHidden(true)
    }
}

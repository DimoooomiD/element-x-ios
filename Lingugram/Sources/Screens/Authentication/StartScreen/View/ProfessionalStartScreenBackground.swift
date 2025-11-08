//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// Professional theme-independent background for the start screen
struct ProfessionalStartScreenBackground: View {
    @State private var animateGradient = false
    
    // Professional color palette - theme independent
    private let primaryGradient: [Color] = [
        Color(red: 0.15, green: 0.25, blue: 0.45), // Deep professional blue
        Color(red: 0.25, green: 0.35, blue: 0.55), // Medium blue
        Color(red: 0.35, green: 0.45, blue: 0.65), // Lighter blue
        Color(red: 0.20, green: 0.30, blue: 0.50) // Balanced blue
    ]
    
    private let accentGradient: [Color] = [
        Color(red: 0.40, green: 0.50, blue: 0.70).opacity(0.6),
        Color(red: 0.30, green: 0.40, blue: 0.60).opacity(0.4)
    ]
    
    var body: some View {
        ZStack {
            // Base professional gradient
            LinearGradient(colors: primaryGradient,
                           startPoint: animateGradient ? .topLeading : .bottomTrailing,
                           endPoint: animateGradient ? .bottomTrailing : .topLeading)
                .ignoresSafeArea()
                .animation(Animation.easeInOut(duration: 10.0)
                    .repeatForever(autoreverses: true),
                    value: animateGradient)
            
            // Subtle radial overlay for depth
            RadialGradient(colors: accentGradient,
                           center: animateGradient ? .topTrailing : .bottomLeading,
                           startRadius: 150,
                           endRadius: 800)
                .ignoresSafeArea()
                .animation(Animation.easeInOut(duration: 8.0)
                    .repeatForever(autoreverses: true),
                    value: animateGradient)
            
            // Professional geometric patterns
            GeometryReader { geometry in
                // Large subtle circle
                Circle()
                    .fill(
                        RadialGradient(colors: [
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300)
                    )
                    .frame(width: 600, height: 600)
                    .offset(x: animateGradient ? geometry.size.width * 0.2 : geometry.size.width * 0.1,
                            y: animateGradient ? geometry.size.height * 0.15 : geometry.size.height * 0.25)
                    .blur(radius: 80)
                    .animation(Animation.easeInOut(duration: 12.0)
                        .repeatForever(autoreverses: true),
                        value: animateGradient)
                
                // Medium accent circle
                Circle()
                    .fill(
                        RadialGradient(colors: [
                            Color.white.opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200)
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: animateGradient ? geometry.size.width * 0.75 : geometry.size.width * 0.65,
                            y: animateGradient ? geometry.size.height * 0.75 : geometry.size.height * 0.65)
                    .blur(radius: 60)
                    .animation(Animation.easeInOut(duration: 14.0)
                        .repeatForever(autoreverses: true),
                        value: animateGradient)
                
                // Small accent dots
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: CGFloat(80 + index * 40))
                        .offset(x: animateGradient ?
                            geometry.size.width * (0.15 + CGFloat(index) * 0.2) :
                            geometry.size.width * (0.2 + CGFloat(index) * 0.15),
                            y: animateGradient ?
                                geometry.size.height * (0.25 + CGFloat(index) * 0.12) :
                                geometry.size.height * (0.2 + CGFloat(index) * 0.15))
                        .blur(radius: 25)
                        .animation(Animation.easeInOut(duration: Double(9 + index * 2))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.4),
                            value: animateGradient)
                }
            }
            
            // Subtle professional overlay
            Rectangle()
                .fill(
                    LinearGradient(colors: [
                        Color.black.opacity(0.03),
                        Color.clear,
                        Color.white.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                )
                .ignoresSafeArea()
        }
        .onAppear {
            animateGradient = true
        }
        .accessibilityHidden(true)
    }
}

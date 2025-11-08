//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// Professional animated background matching LinguaFlow Pro website style
struct LanguageLearningBackground: View {
    @State private var animationPhase: Double = 0
    @State private var animationTask: Task<Void, Never>?
    
    // Comprehensive emoji collection matching the website
    private let emojis: [String] = [
        // Study & Learning Emojis
        "🌍", "📚", "🎯", "🚀", "💡", "⭐", "📖", "✏️", "🎓", "🧠",
        "📝", "🔍", "💭", "🎨", "📊", "🏆", "🎪", "🔬", "📐", "🎵",
        // Country Flags
        "🇪🇸", "🇫🇷", "🇩🇪", "🇯🇵", "🇨🇳", "🇸🇦", "🇮🇹", "🇷🇺", "🇰🇷", "🇧🇷",
        "🇮🇳", "🇬🇧", "🇨🇦", "🇦🇺", "🇳🇱", "🇸🇪", "🇳🇴", "🇩🇰", "🇫🇮", "🇵🇱",
        "🇺🇸", "🇲🇽", "🇵🇹", "🇬🇷", "🇹🇷",
        // Achievement & Success
        "🏅", "🥇", "🥈", "🥉", "🎖️", "🏵️", "🎗️", "🎀", "🎁", "🎊",
        "🎉", "🎈", "🎂", "🍰", "🍭"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base dark background matching website (#0f172a)
                Color(red: 0.06, green: 0.09, blue: 0.16)
                    .ignoresSafeArea()
                
                // Radial gradients matching website style
                RadialGradient(
                    colors: [
                        Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1), // #6366f1
                        Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.1), // #8b5cf6
                        Color.clear
                    ],
                    center: UnitPoint(
                        x: 0.2 + sin(animationPhase * 0.05) * 0.1,
                        y: 0.5 + cos(animationPhase * 0.05) * 0.1
                    ),
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [
                        Color(red: 0.80, green: 0.20, blue: 0.20).opacity(0.1), // #8b5cf6 variant
                        Color(red: 0.02, green: 0.71, blue: 0.83).opacity(0.1), // #06b6d4
                        Color.clear
                    ],
                    center: UnitPoint(
                        x: 0.8 + cos(animationPhase * 0.05) * 0.1,
                        y: 0.2 + sin(animationPhase * 0.05) * 0.1
                    ),
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [
                        Color(red: 0.02, green: 0.71, blue: 0.83).opacity(0.1), // #06b6d4
                        Color(red: 0.23, green: 0.51, blue: 0.96).opacity(0.1), // #3b82f6
                        Color.clear
                    ],
                    center: UnitPoint(
                        x: 0.4 + sin(animationPhase * 0.03) * 0.1,
                        y: 0.8 + cos(animationPhase * 0.03) * 0.1
                    ),
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()
                
                // Floating emojis with website-style animations
                ForEach(0..<emojis.count, id: \.self) { index in
                    FloatingEmoji(
                        emoji: emojis[index],
                        index: index,
                        totalCount: emojis.count,
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height,
                        animationPhase: animationPhase
                    )
                }
            }
        }
        .onAppear {
            // Reset animation phase and start immediately with visible animation
            animationPhase = 0
            startAnimation()
        }
        .onDisappear {
            // Cancel animation task when view disappears
            animationTask?.cancel()
            animationTask = nil
        }
    }
    
    private func startAnimation() {
        // Cancel any existing task
        animationTask?.cancel()
        
        // Start new animation task with faster updates
        animationTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
                await MainActor.run {
                    animationPhase += 0.02 // Faster increment for visible movement
                    // Keep phase in reasonable range to prevent overflow
                    if animationPhase > 2 * .pi * 10 {
                        animationPhase = animationPhase.truncatingRemainder(dividingBy: 2 * .pi * 10)
                    }
                }
            }
        }
    }
}

/// Individual floating emoji with gentle vertical float only
private struct FloatingEmoji: View {
    let emoji: String
    let index: Int
    let totalCount: Int
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let animationPhase: Double
    
    private var baseSize: CGFloat {
        CGFloat(18 + (index % 5) * 3) // Smaller sizes: 18 to 30
    }
    
    // Gentle animation speeds - only vertical float
    private var animationSpeed: Double {
        // Varied speeds for natural floating
        let category = index % 7
        switch category {
        case 0: return 0.15 // Slow
        case 1: return 0.2
        case 2: return 0.18
        case 3: return 0.22
        case 4: return 0.16
        case 5: return 0.19
        default: return 0.21
        }
    }
    
    private var pathOffset: Double {
        Double(index) * 0.5 // Wider spacing
    }
    
    // Increased opacity for better visibility
    private var baseOpacity: Double {
        0.35 + sin(Double(index) * 0.4) * 0.15 // Range: 0.2 to 0.5
    }
    
    // Completely random distribution across entire screen - more widespread
    private var initialX: CGFloat {
        // Use multiple sine/cosine functions with different frequencies and prime numbers for better randomness
        let seed1 = sin(Double(index) * 0.847 + Double(index % 7) * 1.234 + Double(index % 23) * 0.567)
        let seed2 = cos(Double(index) * 0.623 + Double(index % 11) * 0.891 + Double(index % 29) * 0.789)
        let seed3 = sin(Double(index) * 1.127 + Double(index % 13) * 0.456 + Double(index % 31) * 0.345)
        let seed4 = cos(Double(index) * 0.934 + Double(index % 17) * 1.123 + Double(index % 37) * 0.678)
        
        // Combine seeds for more random-like distribution
        let combined = (seed1 + seed2 * 0.7 + seed3 * 0.5 + seed4 * 0.3) / 2.5
        
        // Map to screen width with minimal padding for maximum spread
        let padding: CGFloat = 10
        let availableWidth = screenWidth - (padding * 2)
        let normalized = (combined + 1.0) / 2.0 // Normalize from [-1,1] to [0,1]
        return padding + CGFloat(normalized) * availableWidth
    }
    
    private var initialY: CGFloat {
        // Use different seed combinations for Y to ensure independence from X
        let seed1 = cos(Double(index) * 0.731 + Double(index % 5) * 1.567 + Double(index % 19) * 0.432)
        let seed2 = sin(Double(index) * 0.934 + Double(index % 17) * 0.723 + Double(index % 41) * 0.654)
        let seed3 = cos(Double(index) * 1.245 + Double(index % 19) * 0.389 + Double(index % 43) * 0.876)
        let seed4 = sin(Double(index) * 0.567 + Double(index % 3) * 1.234 + Double(index % 47) * 0.543)
        
        // Combine seeds for more random-like distribution
        let combined = (seed1 + seed2 * 0.8 + seed3 * 0.6 + seed4 * 0.4) / 2.8
        
        // Map to screen height with minimal padding for maximum spread
        let padding: CGFloat = 20
        let availableHeight = screenHeight - (padding * 2)
        let normalized = (combined + 1.0) / 2.0 // Normalize from [-1,1] to [0,1]
        return padding + CGFloat(normalized) * availableHeight
    }
    
    var body: some View {
        Text(emoji)
            .font(.system(size: baseSize))
            .opacity(baseOpacity)
            .position(x: initialX, y: currentY)
    }
    
    private var currentY: CGFloat {
        // Gentle vertical floating - visible movement
        let phase = animationPhase * animationSpeed + pathOffset
        // Vertical movement: -25px to +25px for visible float
        let verticalMovement = sin(phase) * 25
        return initialY + CGFloat(verticalMovement)
    }
}


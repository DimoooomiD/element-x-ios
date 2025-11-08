//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// Configuration for the language learning animated background.
struct LanguageBackgroundConfig {
    /// Number of emojis to show (nil = all).
    var emojiCount: Int? = nil
    /// Normalized vertical range [0, 1] where emojis may appear.
    var verticalStart: CGFloat = 0.35
    var verticalEnd: CGFloat = 0.75
    /// Horizontal padding on both sides in points.
    var horizontalPadding: CGFloat = 32
    /// Fraction of the screen width to keep clear in the horizontal center (0-1).
    /// Example: 0.4 leaves 40% of the center empty to avoid the main content.
    var centerGapFraction: CGFloat = 0.38
    /// Multiplier for animation speed (1.0 = default).
    var speedMultiplier: Double = 1.0
    /// Spread emojis uniformly across the available region.
    var uniformDistribution: Bool = false
    /// Spread emojis randomly across the region (ignores lanes). Stable per index.
    var randomDistribution: Bool = false
    
    static let `default` = LanguageBackgroundConfig()
}

/// Professional animated background matching LinguaFlow Pro website style
struct LanguageLearningBackground: View {
    let config: LanguageBackgroundConfig
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationPhase: Double = 0
    @State private var animationTask: Task<Void, Never>?
    
    // Expanded emoji collection for language learning theme
    private let emojis: [String] = [
        // Study & Learning Emojis
        "🌍", "📚", "🎯", "💡", "📖", "🎓", "✏️", "📝", "📊", "📋",
        // Country Flags
        "🇪🇸", "🇫🇷", "🇩🇪", "🇯🇵", "🇬🇧", "🇺🇸", "🇮🇹", "🇵🇹", "🇷🇺", "🇨🇳", "🇰🇷", "🇧🇷", "🇲🇽", "🇮🇳",
        // Achievement & Success
        "🏅", "🥇", "🏆", "🎉", "⭐", "✨", "🌟", "💫",
        // Communication & Language
        "💬", "🗣️", "👥", "🤝", "🌐", "🔤", "🔠", "📱", "💻",
        // Learning Tools
        "🎧", "🎤", "📹", "🎬", "🎨", "🧠", "💭", "🔍", "📌"
    ]
    
    init(config: LanguageBackgroundConfig = .default) {
        self.config = config
    }
    
    private var renderEmojis: [String] {
        if let limit = config.emojiCount, limit > 0 {
            // Only use unique emojis, never repeat
            return Array(emojis.prefix(min(limit, emojis.count)))
        }
        return emojis
    }
    
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
                ForEach(0..<renderEmojis.count, id: \.self) { index in
                    FloatingEmoji(
                        emoji: renderEmojis[index],
                        index: index,
                        totalCount: renderEmojis.count,
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height,
                        animationPhase: animationPhase,
                        horizontalPadding: config.horizontalPadding,
                        verticalStart: config.verticalStart,
                        verticalEnd: config.verticalEnd,
                        centerGapFraction: config.centerGapFraction,
                        uniformDistribution: config.uniformDistribution,
                        randomDistribution: config.randomDistribution,
                        reduceMotion: reduceMotion,
                        speedMultiplier: config.speedMultiplier
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
        guard !reduceMotion else { return }
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

/// Circle packing structure for emoji positioning
private struct EmojiCircle {
    let centerX: CGFloat
    let centerY: CGFloat
    let radius: CGFloat
}

/// Individual floating emoji with gentle vertical float only
private struct FloatingEmoji: View {
    let emoji: String
    let index: Int
    let totalCount: Int
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let animationPhase: Double
    let horizontalPadding: CGFloat
    let verticalStart: CGFloat
    let verticalEnd: CGFloat
    let centerGapFraction: CGFloat
    let uniformDistribution: Bool
    let randomDistribution: Bool
    let reduceMotion: Bool
    let speedMultiplier: Double
    
    private var baseSize: CGFloat {
        CGFloat(18 + (index % 5) * 3) // Smaller sizes: 18 to 30
    }
    
    // Circle radius for collision detection (emoji size + padding)
    private var circleRadius: CGFloat {
        baseSize * 0.5 + 20 // Half emoji size + padding
    }
    
    // Gentle animation speeds - only vertical float
    private var animationSpeed: Double {
        // Varied speeds for natural floating
        let category = index % 7
        switch category {
        case 0: return 0.15 * speedMultiplier // Slow
        case 1: return 0.20 * speedMultiplier
        case 2: return 0.18 * speedMultiplier
        case 3: return 0.22 * speedMultiplier
        case 4: return 0.16 * speedMultiplier
        case 5: return 0.19 * speedMultiplier
        default: return 0.21 * speedMultiplier
        }
    }
    
    private var pathOffset: Double {
        Double(index) * 0.5 // Wider spacing
    }
    
    // Increased opacity for better visibility
    private var baseOpacity: Double {
        0.35 + sin(Double(index) * 0.4) * 0.15 // Range: 0.2 to 0.5
    }
    
    // Circle packing algorithm to position emojis without collisions
    private var initialPosition: (x: CGFloat, y: CGFloat) {
        // Calculate available area
        let minX = horizontalPadding
        let maxX = screenWidth - horizontalPadding
        let availableWidth = max(0, maxX - minX)
        
        let start = max(0, min(1, verticalStart))
        let end = max(0, min(1, verticalEnd))
        let minV = min(start, end)
        let maxV = max(start, end)
        let minY = minV * screenHeight
        let maxY = maxV * screenHeight
        let availableHeight = max(0, maxY - minY)
        
        // Generate positions for all previous emojis (deterministic)
        var placedCircles: [EmojiCircle] = []
        
        for i in 0..<index {
            let prevSize = CGFloat(18 + (i % 5) * 3)
            let prevRadius = prevSize * 0.5 + 20
            
            // Try to find a non-colliding position for this emoji
            var attempts = 0
            var foundPosition = false
            var candidateX: CGFloat = 0
            var candidateY: CGFloat = 0
            
            while attempts < 100 && !foundPosition {
                // Deterministic pseudo-random based on index and attempt
                let seedX = sin(Double(i) * 17.217 + Double(attempts) * 0.1) * 10000.0
                let seedY = cos(Double(i) * 23.731 + Double(attempts) * 0.1) * 10000.0
                let fracX = CGFloat(seedX - floor(seedX))
                let fracY = CGFloat(seedY - floor(seedY))
                
                candidateX = minX + fracX * availableWidth
                candidateY = minY + fracY * availableHeight
                
                // Ensure circle stays within bounds
                candidateX = max(minX + prevRadius, min(maxX - prevRadius, candidateX))
                candidateY = max(minY + prevRadius, min(maxY - prevRadius, candidateY))
                
                // Check collision with all previously placed circles
                var collides = false
                for existing in placedCircles {
                    let dx = candidateX - existing.centerX
                    let dy = candidateY - existing.centerY
                    let distance = sqrt(dx * dx + dy * dy)
                    if distance < (prevRadius + existing.radius) {
                        collides = true
                        break
                    }
                }
                
                if !collides {
                    foundPosition = true
                } else {
                    attempts += 1
                }
            }
            
            if foundPosition {
                placedCircles.append(EmojiCircle(centerX: candidateX, centerY: candidateY, radius: prevRadius))
            } else {
                // Fallback: place at a safe distance from previous
                let fallbackX = minX + CGFloat(i) * (availableWidth / CGFloat(max(totalCount, 1)))
                let fallbackY = minY + CGFloat(i % 5) * (availableHeight / 4.0)
                placedCircles.append(EmojiCircle(centerX: fallbackX, centerY: fallbackY, radius: prevRadius))
            }
        }
        
        // Now find position for current emoji
        var attempts = 0
        var foundPosition = false
        var finalX: CGFloat = 0
        var finalY: CGFloat = 0
        
        while attempts < 150 && !foundPosition {
            // Deterministic pseudo-random based on index and attempt
            let seedX = sin(Double(index) * 17.217 + Double(attempts) * 0.1) * 10000.0
            let seedY = cos(Double(index) * 23.731 + Double(attempts) * 0.1) * 10000.0
            let fracX = CGFloat(seedX - floor(seedX))
            let fracY = CGFloat(seedY - floor(seedY))
            
            finalX = minX + fracX * availableWidth
            finalY = minY + fracY * availableHeight
            
            // Ensure circle stays within bounds
            finalX = max(minX + circleRadius, min(maxX - circleRadius, finalX))
            finalY = max(minY + circleRadius, min(maxY - circleRadius, finalY))
            
            // Check collision with all previously placed circles
            var collides = false
            for existing in placedCircles {
                let dx = finalX - existing.centerX
                let dy = finalY - existing.centerY
                let distance = sqrt(dx * dx + dy * dy)
                if distance < (circleRadius + existing.radius) {
                    collides = true
                    break
                }
            }
            
            if !collides {
                foundPosition = true
            } else {
                attempts += 1
            }
        }
        
        if !foundPosition {
            // Fallback: place at a safe position
            finalX = minX + CGFloat(index) * (availableWidth / CGFloat(max(totalCount, 1)))
            finalY = minY + CGFloat(index % 5) * (availableHeight / 4.0)
        }
        
        return (finalX, finalY)
    }
    
    private var initialX: CGFloat {
        initialPosition.x
    }
    
    private var initialY: CGFloat {
        initialPosition.y
    }
    
    var body: some View {
        Text(emoji)
            .font(.system(size: baseSize))
            .opacity(baseOpacity)
            .position(x: initialX, y: currentY)
    }
    
    private var currentY: CGFloat {
        guard !reduceMotion else { return initialY }
        // Gentle vertical floating - visible movement
        let phase = animationPhase * animationSpeed + pathOffset
        // Vertical movement amplitude
        let verticalMovement = sin(phase) * 20
        return initialY + CGFloat(verticalMovement)
    }
}


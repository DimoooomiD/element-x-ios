//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

struct LibraryScreenViewState: BindableState {
    var languagePackages: [LanguageLearningPackage] = [
        LanguageLearningPackage(
            id: "spanish-basics",
            title: "Spanish Basics",
            description: "Learn essential Spanish vocabulary and phrases for everyday conversations",
            price: "$9.99",
            duration: "3 months",
            lessons: 30,
            level: "Beginner",
            icon: "🇪🇸"
        ),
        LanguageLearningPackage(
            id: "french-intermediate",
            title: "French Intermediate",
            description: "Advance your French skills with grammar, conversation, and cultural insights",
            price: "$14.99",
            duration: "6 months",
            lessons: 50,
            level: "Intermediate",
            icon: "🇫🇷"
        ),
        LanguageLearningPackage(
            id: "german-complete",
            title: "German Complete",
            description: "Master German from basics to advanced with comprehensive lessons",
            price: "$19.99",
            duration: "12 months",
            lessons: 100,
            level: "All Levels",
            icon: "🇩🇪"
        ),
        LanguageLearningPackage(
            id: "japanese-basics",
            title: "Japanese Basics",
            description: "Start your Japanese journey with Hiragana, Katakana, and essential phrases",
            price: "$12.99",
            duration: "4 months",
            lessons: 40,
            level: "Beginner",
            icon: "🇯🇵"
        ),
        LanguageLearningPackage(
            id: "italian-conversation",
            title: "Italian Conversation",
            description: "Learn to speak Italian naturally with real-world conversation practice",
            price: "$11.99",
            duration: "5 months",
            lessons: 45,
            level: "Beginner to Intermediate",
            icon: "🇮🇹"
        )
    ]
}

struct LanguageLearningPackage: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: String
    let duration: String
    let lessons: Int
    let level: String
    let icon: String
}

enum LibraryScreenViewAction {
    case dismiss
    case purchasePackage(packageId: String)
}

enum LibraryScreenViewModelAction {
    case dismiss
    case purchaseInitiated(packageId: String)
}


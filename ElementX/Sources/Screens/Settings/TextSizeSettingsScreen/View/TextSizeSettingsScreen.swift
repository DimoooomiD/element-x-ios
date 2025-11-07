//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct TextSizeSettingsScreen: View {
    @Bindable var context: TextSizeSettingsScreenViewModel.Context
    
    private let minTextSize: Double = 0.8
    private let maxTextSize: Double = 1.5
    private let defaultTextSize: Double = 1.0
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 20) {
                    // Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Text Size")
                                .font(.compound.headingSMSemibold)
                                .foregroundStyle(.compound.textPrimary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1fx", context.chatRoomTextSize))
                                .font(.compound.bodyMDSemibold)
                                .foregroundStyle(.compound.textSecondary)
                        }
                        
                        Slider(value: $context.chatRoomTextSize, in: minTextSize...maxTextSize, step: 0.1)
                            .tint(.compound.bgActionPrimaryRest)
                        
                        HStack {
                            Text("Smaller")
                                .font(.compound.bodySM)
                                .foregroundStyle(.compound.textSecondary)
                            
                            Spacer()
                            
                            Text("Larger")
                                .font(.compound.bodySM)
                                .foregroundStyle(.compound.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section {
                // Preview section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preview")
                        .font(.compound.headingSMSemibold)
                        .foregroundStyle(.compound.textPrimary)
                    
                    // Chat message preview
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Alice")
                                .font(.compound.bodySMSemibold)
                                .foregroundStyle(.compound.textSecondary)
                            
                            Spacer()
                            
                            Text("10:30 AM")
                                .font(.compound.bodyXS)
                                .foregroundStyle(.compound.textSecondary)
                        }
                        
                        Text("This is a preview of how messages will appear in chat rooms with the selected text size.")
                            .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize * context.chatRoomTextSize))
                            .foregroundStyle(.compound.textPrimary)
                            .lineSpacing(4)
                    }
                    .padding(12)
                    .background(Color.compound.bgCanvasDefaultLevel1)
                    .cornerRadius(8)
                    
                    // Another preview message
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bob")
                                .font(.compound.bodySMSemibold)
                                .foregroundStyle(.compound.textSecondary)
                            
                            Spacer()
                            
                            Text("10:31 AM")
                                .font(.compound.bodyXS)
                                .foregroundStyle(.compound.textSecondary)
                        }
                        
                        Text("You can adjust the slider above to see how the text size changes in real-time.")
                            .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize * context.chatRoomTextSize))
                            .foregroundStyle(.compound.textPrimary)
                            .lineSpacing(4)
                    }
                    .padding(12)
                    .background(Color.compound.bgCanvasDefaultLevel1)
                    .cornerRadius(8)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Preview")
                    .font(.compound.bodySM)
                    .foregroundStyle(.compound.textSecondary)
            }
        }
        .compoundList()
        .navigationTitle("Text Size")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBloom(hasSearchBar: false)
        .observeThemeChanges() // Synchronous update for immediate response
    }
}


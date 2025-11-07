//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct LibraryScreen: View {
    let context: LibraryScreenViewModel.Context
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(context.viewState.languagePackages) { package in
                    LanguagePackageRow(package: package) {
                        context.send(viewAction: .purchasePackage(packageId: package.id))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.compound.bgCanvasDefault.ignoresSafeArea())
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.inline)
        .observeThemeChanges(useAsyncUpdates: true) // Async to avoid interfering with tab selection
    }
}

struct LanguagePackageRow: View {
    let package: LanguageLearningPackage
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Text(package.icon)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(package.title)
                        .font(.compound.headingSMSemibold)
                        .foregroundStyle(.compound.textPrimary)
                    
                    Text(package.description)
                        .font(.compound.bodyMD)
                        .foregroundStyle(.compound.textSecondary)
                        .lineLimit(3)
                    
                    HStack(spacing: 16) {
                        Label {
                            Text("\(package.lessons) lessons")
                                .font(.compound.bodySM)
                                .foregroundStyle(.compound.textSecondary)
                        } icon: {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.compound.iconSecondary)
                        }
                        
                        Label {
                            Text(package.duration)
                                .font(.compound.bodySM)
                                .foregroundStyle(.compound.textSecondary)
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundStyle(.compound.iconSecondary)
                        }
                        
                        Label {
                            Text(package.level)
                                .font(.compound.bodySM)
                                .foregroundStyle(.compound.textSecondary)
                        } icon: {
                            CompoundIcon(\.userProfile)
                                .foregroundStyle(.compound.iconSecondary)
                        }
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
            }
            
            HStack {
                Text(package.price)
                    .font(.compound.headingMDBold)
                    .foregroundStyle(.compound.textPrimary)
                
                Spacer()
                
                Button {
                    onPurchase()
                } label: {
                    Text("Purchase")
                        .font(.compound.bodySMSemibold)
                        .foregroundStyle(.compound.textOnSolidPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.compound.bgActionPrimaryRest)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.compound.bgCanvasDefaultLevel1)
        .cornerRadius(12)
    }
}


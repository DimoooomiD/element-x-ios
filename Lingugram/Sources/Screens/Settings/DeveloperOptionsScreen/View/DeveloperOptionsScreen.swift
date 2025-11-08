//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SFSafeSymbols
import SwiftUI

struct DeveloperOptionsScreen: View {
    @Bindable var context: DeveloperOptionsScreenViewModel.Context
    
    @State private var showConfetti = false
    @State private var elementCallURLOverrideString: String
    @State private var isSDKTracePacksExpanded = false
    
    init(context: DeveloperOptionsScreenViewModel.Context) {
        self.context = context
        elementCallURLOverrideString = context.elementCallBaseURLOverride?.absoluteString ?? ""
    }
    
    var body: some View {
        Form {
            Section("Logging") {
                ListRow(label: .default(title: "Log level",
                                        description: "Requires app reboot",
                                        icon: ColoredIcon(symbol: .docTextMagnifyingglass, color: .blue)),
                        kind: .picker(selection: $context.logLevel,
                                      items: logLevels.map { (title: $0.title, tag: $0) }))
                
                ListRow(label: .default(title: "SDK trace packs",
                                        icon: ColoredIcon(symbol: .docOnDoc, color: .gray)),
                        details: .icon(chevronIconView),
                        kind: .button {
                            withAnimation {
                                isSDKTracePacksExpanded.toggle()
                            }
                        })
                
                if isSDKTracePacksExpanded {
                    ForEach(TraceLogPack.allCases, id: \.self) { pack in
                        ListRow(label: .default(title: pack.title,
                                                icon: ColoredIcon(symbol: .docOnDoc, color: .gray)),
                                kind: .toggle($context.traceLogPacks[pack]))
                    }
                }
            }
            
            Section("Spaces") {
                ListRow(label: .default(title: "Space settings",
                                        icon: ColoredIcon(symbol: .squareGrid2x2, color: .purple)),
                        kind: .toggle($context.spaceSettingsEnabled))
            }
            
            Section("Room List") {
                ListRow(label: .default(title: "Public search",
                                        icon: ColoredIcon(symbol: .magnifyingglass, color: .blue)),
                        kind: .toggle($context.publicSearchEnabled))
                
                ListRow(label: .default(title: "Hide grey dots",
                                        icon: ColoredIcon(symbol: .circle, color: .gray)),
                        kind: .toggle($context.hideUnreadMessagesBadge))
                
                ListRow(label: .default(title: "Fuzzy searching",
                                        icon: ColoredIcon(symbol: .textMagnifyingglass, color: .green)),
                        kind: .toggle($context.fuzzyRoomListSearchEnabled))
                
                ListRow(label: .default(title: "Low priority filter",
                                        icon: ColoredIcon(symbol: .line3HorizontalDecrease, color: .orange)),
                        kind: .toggle($context.lowPriorityFilterEnabled))
                
                ListRow(label: .default(title: "Latest event sorter",
                                        description: "Requires app reboot",
                                        icon: ColoredIcon(symbol: .arrowUpArrowDown, color: .cyan)),
                        kind: .toggle($context.latestEventSorterEnabled))
            }
            
            Section("Timeline") {
                ListRow(label: .default(title: "Link previews",
                                        description: "Follows the timeline media visibility settings. Can leak the device IP address when loading link metadata.",
                                        icon: ColoredIcon(symbol: .link, color: .blue)),
                        kind: .toggle($context.linkPreviewsEnabled))
            }
                        
            Section("Join rules") {
                ListRow(label: .default(title: "Knocking",
                                        description: "Ask to join rooms",
                                        icon: ColoredIcon(symbol: .handRaised, color: .green)),
                        kind: .toggle($context.knockingEnabled))
            }
            
            Section {
                ListRow(label: .default(title: "Exclude insecure devices when sending/receiving messages",
                                        description: "Requires app reboot",
                                        icon: ColoredIcon(symbol: .lockShield, color: .red)),
                        kind: .toggle($context.enableOnlySignedDeviceIsolationMode))
            } header: {
                Text("Trust and Decoration")
            } footer: {
                Text("This setting controls how end-to-end encryption (E2EE) keys are exchanged. Enabling it will prevent the inclusion of devices that have not been explicitly verified by their owners.")
            }

            Section {
                ListRow(label: .default(title: "Share encrypted history with new members",
                                        description: "Requires app reboot",
                                        icon: ColoredIcon(symbol: .key, color: .yellow)),
                        kind: .toggle($context.enableKeyShareOnInvite))
            } footer: {
                Text("When inviting a user to an encrypted room that has history visibility set to \"shared\", share encrypted history with that user, and accept encrypted history when you are invited to such a room.")
                Text("WARNING: this feature is EXPERIMENTAL and not all security precautions are implemented. Do not enable on production accounts.")
            }

            Section {
                ListRow(label: .default(title: "Element Call remote URL override",
                                        icon: ColoredIcon(symbol: .phone, color: .green)),
                        kind: .textField(text: $elementCallURLOverrideString))
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .foregroundColor(URL(string: elementCallURLOverrideString) == nil ? .red : .primary)
                    .submitLabel(.done)
                    .onSubmit {
                        if elementCallURLOverrideString.isEmpty {
                            context.elementCallBaseURLOverride = nil
                        } else if let url = URL(string: elementCallURLOverrideString) {
                            context.elementCallBaseURLOverride = url
                        }
                    }
            }
            
            Section("Notifications") {
                ListRow(label: .default(title: "Hide quiet alerts",
                                        description: "The badge count will still be updated",
                                        icon: ColoredIcon(symbol: .bellSlash, color: .orange)),
                        kind: .toggle($context.hideQuietNotificationAlerts))
                
                ListRow(label: .default(title: "Focus event on notification tap",
                                        icon: ColoredIcon(symbol: .target, color: .blue)),
                        kind: .toggle($context.focusEventOnNotificationTap))
            }
            
            Section {
                ListRow(label: .action(title: "Celebrate",
                                       icon: ColoredIcon(symbol: .partyPopper, color: .yellow)),
                        kind: .button {
                            showConfetti = true
                        })
            }

            Section {
                ListRow(label: .action(title: "Clear cache",
                                       icon: ColoredIcon(symbol: .trash, color: .red),
                                       role: .destructive),
                        kind: .button {
                            context.send(viewAction: .clearCache)
                        })
            }
        }
        .overlay(effectsView)
        .compoundList()
        .navigationTitle(L10n.commonDeveloperOptions)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .observeThemeChanges() // Synchronous update for immediate response
    }

    @ViewBuilder
    private var effectsView: some View {
        if showConfetti {
            EffectsView(effect: .confetti)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .task { await removeConfettiAfterDelay() }
        }
    }

    private func removeConfettiAfterDelay() async {
        try? await Task.sleep(for: .seconds(4))
        showConfetti = false
    }
    
    /// Allows the picker to work with associated values
    private var logLevels: [LogLevel] {
        [.error, .warn, .info, .debug, .trace]
    }
    
    private var chevronIconView: some View {
        CompoundIcon(\.chevronDown, size: .small, relativeTo: .compound.bodyLG)
            .foregroundStyle(.compound.iconTertiary)
            .rotationEffect(.degrees(isSDKTracePacksExpanded ? 180 : 0))
    }
}

private extension Set<TraceLogPack> {
    /// A custom subscript that allows binding a toggle to add/remove a pack from the array.
    subscript(pack: TraceLogPack) -> Bool {
        get { contains(pack) }
        set {
            if newValue {
                insert(pack)
            } else {
                remove(pack)
            }
        }
    }
}

// MARK: - Colored Icon View

private struct ColoredIcon: View {
    let symbol: SFSymbol
    let color: Color
    
    var body: some View {
        Image(systemSymbol: symbol)
            .renderingMode(.template)
            .foregroundColor(color)
    }
}

// MARK: - Previews

struct DeveloperOptionsScreen_Previews: PreviewProvider {
    static let viewModel = DeveloperOptionsScreenViewModel(developerOptions: ServiceLocator.shared.settings,
                                                           elementCallBaseURL: ServiceLocator.shared.settings.elementCallBaseURL)
    static var previews: some View {
        NavigationStack {
            DeveloperOptionsScreen(context: viewModel.context)
        }
    }
}

//
//  NibbleTestAppApp.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 18.03.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct NibbleTestAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: PlayerFeature.State()) {
                PlayerFeature()
            })
        }
    }
}

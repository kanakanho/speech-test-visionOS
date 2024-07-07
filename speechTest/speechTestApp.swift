//
//  speechTestApp.swift
//  speechTest
//
//  Created by blue ken on 2024/07/07.
//

import SwiftUI

@main
struct speechTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}

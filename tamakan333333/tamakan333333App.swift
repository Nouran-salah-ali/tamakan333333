//
//  tamakan333333App.swift
//  tamakan333333
//
//  Created by nouransalah on 10/06/1447 AH.
//

import SwiftUI
import SwiftData
@main
struct tamakan333333App: App {
    @StateObject private var recViewModel = RecViewModel()

    var body: some Scene {
        WindowGroup {
            recView()
                .environmentObject(recViewModel)
        }.modelContainer(for: RecordingModel.self)
    }
}

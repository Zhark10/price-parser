//
//  calc_aiApp.swift
//  calc ai
//
//  Created by Дмитрий Мухин on 12.05.2025.
//

import SwiftUI

@main
struct calc_aiApp: App {
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            MainCameraView()
                .environmentObject(viewModel)                 
        }
    }
}
